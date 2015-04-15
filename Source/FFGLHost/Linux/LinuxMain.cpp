#include <math.h>
#include <GL/glut.h>

#include "FFGLFBO.h"

#include "../FFDebugMessage.h"
#include "../FFGLPluginInstance.h"
#include "../Timer.h"

//this defines the size of the window when it is first opened
int WINDOWWIDTH = 640;
int WINDOWHEIGHT = 480;

//these classes assist with handling the loading/unloading, and calling of plugins
FFGLPluginInstance *plugin1 = NULL;
FFGLPluginInstance *plugin2 = NULL;

//these are the default filenames used to load into the above plugin handlers
const char *FFGLBrightnessFile = "../../FFGLPlugins/Linux/FFGLBrightness.so";
const char *FFGLLumaKeyFile     = "../../FFGLPlugins/Linux/FFGLLumaKey.so";
const char *FFGLTileFile       = "../../FFGLPlugins/Linux/FFGLTile.so";
const char *FFGLHeatFile       = "../../FFGLPlugins/Linux/FFGLHeat.so";


//this represents the texture (in main system/CPU memory) that we feed to the plugins
//it is generated procedurally, a clever algorithm from Gabor Papp's minimal
//FreeFrame host for linux
unsigned char *inputImage = NULL;

//this represents the texture (on the GPU) that we feed to the plugins 
FFGLTextureStruct inputTexture;

//this is a function to allocate the above inputTexture and inputImage
void AllocateInputTexture(int textureWidth, int textureHeight);

//this generates the inputImage (in CPU) memory at the
//specified "time" (it is a procedurally generated image), then
//uploads the image to the GPU texture, inputTexture
void UpdateInputTexture(double time);

//OSX supports many more opengl extension directly, by including
//<Opengl/gl_ext.h> - to be more portable to other platforms
//(like Windows, *ahem*), this class (FFGLExtensions) is used
//to provide a defined subset of the GL extensions to all the implementations
//of FFGL plugins / hosts in the FFGL SDK. 
FFGLExtensions glExtensions;

//this represents a blank canvas on the GPU that we use to store temporary
//results of FFGL processing. the output from plugin #1 (brightness) is rendered
//to this FBO, then the FBO is bound as a texture and fed to plugin #2 (mirror, by default)
FFGLFBO fbo;

//this is a timer used to increment the procedurally generated input image
//smoothly over time (also used to ramp the brightness up and down)
Timer *timer = NULL;

//these are methods provided to GLUT that redraw the window
//and handle when the window is resized
void FFGLHostDisplay();
void FFGLHostReshape(int width, int height);
void FFGLHostMouseMove(int x, int y);

//when the mouse moves, these values are updated according to the
//x/y position of the mosue. (0,0) corresponds to the lower left
//corner of the window, (1,1) corresponds to the upper right. the
//mouse values are then assigned to the plugins each time they draw
//x -> plugin 1 parameter 0
//y -> plugin 2 parameter 0
float mouseX = 0.5;
float mouseY = 0.5;

int main(int argc, char **argv)
{
  //init first plugin
  plugin1 = FFGLPluginInstance::New();
  if (plugin1->Load(FFGLBrightnessFile)==FF_FAIL)
  {
    FFDebugMessage("Couldn't open plugin 1");
    return 0;
  }

  //init second plugin
  plugin2 = FFGLPluginInstance::New();
  if (plugin2->Load(FFGLTileFile)==FF_FAIL)
  {
    FFDebugMessage("Couldn't open plugin 2");
    return 0;
  }

  //init OpenGL/GLUT
  glutInit(&argc, argv);
  glutInitWindowSize(WINDOWWIDTH, WINDOWHEIGHT);
  glutInitDisplayString("double rgb depth");
  glutCreateWindow("FFGLHost");
  glutReshapeFunc(FFGLHostReshape);
  glutPassiveMotionFunc(FFGLHostMouseMove);
  
  //this allocates the CPU inputImage and GPU inputTexture
  //(they must be the same size)
  AllocateInputTexture(320,240);
  
  if (inputTexture.Handle==0 || inputImage==NULL)
  {
    FFDebugMessage("Texture allocation failed");
    return 0;
  }
  
  //init gl extensions
  glExtensions.Initialize();
  if (glExtensions.EXT_framebuffer_object==0)
  {
    FFDebugMessage("FBO not detected, cannot continue");
    return 0;
  }

  //allocate fbo, same size as window
  if (!fbo.Create(WINDOWWIDTH, WINDOWHEIGHT, glExtensions))
  {
    FFDebugMessage("Framebuffer Object Init Failed");
    return 0;
  }
  
  //tell GLUT about our display functions
  glutDisplayFunc(FFGLHostDisplay);
  
  //start the timer and the glut main loop
  timer = Timer::New();
  glutMainLoop();

  //when the main loop exits, free up what we allocated
  plugin1->Unload();
  delete plugin1;

  plugin2->Unload();
  delete plugin2;
  
  delete [] inputImage;
  
  delete timer;
  
  //...GL texture is left allocated?
  return 0;
}

void FFGLHostDisplay()
{  
	//whats the current time on the timer?
	double curFrameTime = timer->GetElapsedTime();

	UpdateInputTexture(curFrameTime);
  
	//activate the fbo as our render target
	if (!fbo.BindAsRenderTarget(glExtensions))
	{
	  FFDebugMessage("FBO Bind As Render Target Failed");
	  return;
	}

	//set the gl viewport to equal the size of the FBO
	glViewport(0,0, fbo.GetWidth(), fbo.GetHeight());

	//prepare gl state for rendering the first plugin (brightness)

	//make sure all the matrices are reset
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	//clear the depth and color buffers
	glClearColor(0,0,0,0);
	glClearDepth(1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	//set plugin 1 parameter 0
	plugin1->SetFloatParameter(0, mouseX);
  
	//prepare the structure used to call
	//the plugin's ProcessOpenGL method
	ProcessOpenGLStructTag processStruct;

	//provide the 1 input texture we allocated above
	processStruct.numInputTextures = 1;

	//create the array of OpenGLTextureStruct * to be passed
	//to the plugin
	FFGLTextureStruct *inputTextures[1];
	inputTextures[0] = &inputTexture;

	processStruct.inputTextures = inputTextures;

	//call the plugin's ProcessOpenGL
	if (plugin1->CallProcessOpenGL(processStruct)==FF_SUCCESS)
	{
	  //if the plugin call succeeds, the drawning is complete
	}
	else
	{
	  //the plugin call failed, exit
	  FFDebugMessage("Plugin 1's ProcessOpenGL failed");
	  return;
	}

	//deactivate rendering to the fbo
	//(this re-activates rendering to the window)
	fbo.UnbindAsRenderTarget(glExtensions);

	//set the gl viewport to equal the size of our output window
	glViewport(0, 0, WINDOWWIDTH, WINDOWHEIGHT);

	//prepare to render the 2nd plugin (the mirror effect or the custom plugin)

	//reset all matrices
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	//clear the color and depth buffers
	glClearColor(0,0,0,0);
	glClearDepth(1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	//now pass the contents of the FBO as a texture to the mirror plugin
	FFGLTextureStruct fboTexture = fbo.GetTextureInfo();

	//all we need to change in our processStruct
	//is where texture #0 points to (now it points to the FBO texture)
	inputTextures[0] = &fboTexture;

  //set plugin 2 parameter 0
  plugin2->SetFloatParameter(0, mouseY);
  
	//call the mirror plugin's ProcessOpenGL
	if (plugin2->CallProcessOpenGL(processStruct)==FF_SUCCESS)
	{
	  //if the plugin call succeeds, the drawning is complete
	}
	else
	{
	  //the plugin call failed
	  FFDebugMessage("Plugin 2's ProcessOpenGL failed");
	}

  glutSwapBuffers();
  glutPostRedisplay();
}

void FFGLHostMouseMove(int x, int y)
{
  if (x<0) x=0;
  else
  if (x>WINDOWWIDTH) x = WINDOWWIDTH;
  
  if (y<0) y = 0;
  else
  if (y>WINDOWHEIGHT) y = WINDOWHEIGHT;
  
  mouseX = ((double)x) / (double)WINDOWWIDTH;
  mouseY = 1.0 - ((double)y) / (double)WINDOWHEIGHT;
}

void FFGLHostReshape(int width, int height)
{
  WINDOWWIDTH = width;
  WINDOWHEIGHT = height;
  glViewport(0, 0, width, height);
}

void UpdateInputTexture(double timeInSeconds)
{
  int time = (int)(timeInSeconds*160.0);
  
  unsigned char *p = inputImage;
  
  //this algorithm taken from Gabor Papp's minimal freeframe host for linux
  for (unsigned y=0; y<inputTexture.Height; y++)
  {
    for (unsigned x=0; x<inputTexture.Width; x++)
    {
      int r = ((x^(y+time)) & 0xFF);
	    int g = (((x+time)^y) & 0xFF);
	    int b = ((x^y) & 0xFF);

	    *p = b;
	    *(p+1) = g;
	    *(p+2) = r;

	    p += 4;
    }
  }
  
  //bind the gl texture so we can upload the next video frame
	glBindTexture(inputTexture.Target, inputTexture.Handle);

	//upload it to the gl texture. use subimage because
	//the video frame size is probably smaller than the
	//size of the texture on the gpu hardware
	glTexSubImage2D(
    inputTexture.Target,
    0,
    0, 0,
    inputTexture.Width,
    inputTexture.Height,
    GL_RGBA,
    GL_UNSIGNED_BYTE,
    inputImage);

	//unbind the gl texture
	glBindTexture(inputTexture.Target, 0);
}

void AllocateInputTexture(int textureWidth, int textureHeight)
{
  //first allocate CPU memory (32-bit RGBA)
  //(this MUST be the same size as the texture, otherwise there will probably be an error/crash
  //when it is uploaded to the GPU)
  inputImage = new unsigned char[textureWidth*textureHeight*4];
  if (inputImage==NULL)
    return;
  
  //now allocate the GPU texture

  //find smallest power of two sized
  //texture that can contain the texture  
  int glTextureWidth = 1;
  while (glTextureWidth<textureWidth) glTextureWidth *= 2;

  int glTextureHeight = 1;
  while (glTextureHeight<textureHeight) glTextureHeight *= 2;

  //create and setup the gl texture
  GLuint glTextureHandle = 0;
  glGenTextures(1, &glTextureHandle);

  //bind this new texture so that glTex* calls apply to it
  glBindTexture(GL_TEXTURE_2D, glTextureHandle);
  
  //use bilinear interpolation when the texture is scaled larger
  //than its true size
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  
  //no mipmapping (for when the texture is scaled smaller than its
  //true size)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

  //no wrapping (for when texture coordinates reference outside the
  //bounds of the texture)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

  //this allocates room for the gl texture, but doesn't fill it with any pixels
  //(the NULL would otherwise contain a pointer to the texture data)
  glTexImage2D(GL_TEXTURE_2D,
               0, 4, //we are using a 32bit image, which has 4 bytes per pixel
               glTextureWidth,
               glTextureHeight,
               0, GL_RGBA,
               GL_UNSIGNED_BYTE,
               NULL);

  //unbind the texture
  glBindTexture(GL_TEXTURE_2D, 0);
  
  //fill the inputTexture struct
  FFGLTextureStruct &t = inputTexture;

  t.Handle = glTextureHandle;
  t.Target = GL_TEXTURE_2D;

  t.Width = textureWidth;
  t.Height = textureHeight;
  
  t.HardwareWidth = glTextureWidth;
  t.HardwareHeight = glTextureHeight;

  t.Depth = 1;
  t.HardwareDepth = 1;
}
