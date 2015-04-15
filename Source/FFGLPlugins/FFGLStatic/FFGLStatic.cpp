#include <FFGL.h>
#include <FFGLLib.h>
#include <stdio.h>
#include <cstdlib>
#include <cmath>
#include "FFGLStatic.h"
#include "utilities.h"

#ifdef _WIN32
#include "../common/opengl/include/glut.h"
#include <windows.h>
#else	//all other platforms
#include <OpenGL/glu.h>
#include <sys/time.h>
#endif
#ifdef __APPLE__	//OS X
#include <Carbon.h>
#endif

#define	FFPARAM_Mode	(0)

bool hastime = false;	//workaround for hosts without Time support

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Plugin information
////////////////////////////////////////////////////////////////////////////////////////////////////

static CFFGLPluginInfo PluginInfo ( 
	FFGLStatic::CreateInstance,	// Create method
	"MSTF",								// Plugin unique ID											
	"Static",					// Plugin name											
	1,						   			// API major version number 													
	000,								  // API minor version number	
	1,										// Plugin major version number
	100,									// Plugin minor version number
	FF_EFFECT,						// Plugin type
	"Static effect",	// Plugin description
	"by Matias Wilkman" // About
);

char *vertexShaderCode =
"void main()"
"{"
"  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;"
"  gl_TexCoord[0] = gl_MultiTexCoord0;"
"  gl_FrontColor = gl_Color;"
"}";

char *fragmentShaderCode =
"float rand(vec2 co){"
"        return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);"
"}"
"uniform float time;"
"uniform bool twotone;"
"uniform bool grayscale;"
"uniform sampler2D sampler0;"
"void main(void)"
"{"
"	vec2 texCoord = gl_TexCoord[0].xy;"
"	vec4 c_out = texture2D(sampler0, texCoord);"
"	texCoord.s += 8.64 * fract(texCoord.t + time);"
"	texCoord.t += 4.57 * fract(texCoord.s + time);"
"	if (grayscale && !twotone)"	//grayscale
"		c_out.rgb = vec3(mod(time+rand(vec2(texCoord.s+2.34*time, texCoord.t+3.14*time)), 1.0));"
"	if (!grayscale && !twotone)"	//full color
"		c_out.rgb = vec3(mod(time+rand(texCoord+vec2(time)), 1.0), mod(time+rand(texCoord+vec2(2.0*time)), 1.0), mod(time+rand(texCoord+vec2(3.0*time)), 1.0));"
"	if (twotone)"	//twotone
"		if (mod(time+rand(texCoord + vec2(time)), 1.0) > 0.5)"
"			c_out.rgb = vec3(1.0);"
"		else"
"			c_out.rgb = vec3(0.0);"
"	gl_FragColor = c_out;"
"}";

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Constructor and destructor
////////////////////////////////////////////////////////////////////////////////////////////////////

FFGLStatic::FFGLStatic()
:CFreeFrameGLPlugin(),
 m_initResources(1)
{
	// Input properties
	SetMinInputs(1);
	SetMaxInputs(1);
	SetTimeSupported(true);

	init_time(&t0);
#ifdef _WIN32
	srand(GetTickCount());
#else
	srand(time(NULL));
#endif

	// parameters:
	SetParamInfo(FFPARAM_Mode, "Mode", FF_TYPE_STANDARD, 0.5f);	
	m_mode = 0.5f;
}

DWORD FFGLStatic::SetTime(double time)
{
  m_time = time;
  hastime = true;
  return FF_SUCCESS;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Methods
////////////////////////////////////////////////////////////////////////////////////////////////////

DWORD FFGLStatic::InitGL(const FFGLViewportStruct *vp)
{
  //initialize gl extensions and
  //make sure required features are supported
  m_extensions.Initialize();
  if (m_extensions.ARB_shader_objects==0)
    return FF_FAIL;
    
  //initialize gl shader
  m_shader.SetExtensions(&m_extensions);
  if (!m_shader.Compile(vertexShaderCode,fragmentShaderCode))
	  return FF_FAIL;
 
  //activate our shader
	bool success = false;
  if (m_shader.IsReady())
	  if (m_shader.BindShader())
		  success = true;
  if (!success)
  {
	  printf("Shader binding failed!\n");
	  return FF_FAIL;  
  }
    
  //to assign values to parameters in the shader, we have to lookup
  //the "location" of each value.. then call one of the glUniform* methods
  //to assign a value
  m_timeLocation = m_shader.FindUniform("time");
  m_grayscaleLocation = m_shader.FindUniform("grayscale");
  m_twotoneLocation = m_shader.FindUniform("twotone");
    
  m_shader.UnbindShader();

  return FF_SUCCESS;
}

DWORD FFGLStatic::DeInitGL()
{
  m_shader.FreeGLResources();

  return FF_SUCCESS;
}

DWORD FFGLStatic::ProcessOpenGL(ProcessOpenGLStruct *pGL)
{
// If no calls to SetTime have been made, the host probably
// doesn't support Time, so we'll update m_time manually
	if (!hastime)
	{
		update_time(&m_time, t0);
	}

	FFGLTextureStruct &Texture = *(pGL->inputTextures[0]);
	FFGLTexCoords maxCoords = GetMaxGLTexCoords(Texture);

	//activate our shader
	m_shader.BindShader();
	    
	//get the max s,t that correspond to the 
	//width,height of the used portion of the allocated texture space
	float foo = (m_time+float(rand()%100));
	m_extensions.glUniform1fARB(m_timeLocation, foo);

	m_extensions.glUniform1iARB(m_grayscaleLocation, m_mode>0.33f?true:false);
	m_extensions.glUniform1iARB(m_twotoneLocation, m_mode>0.66f?true:false);

	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, Texture.Handle);
	glBegin(GL_QUADS);
		//lower left
		glTexCoord2f(0, 0);
		glVertex2f(-1.0, -1.0);
		//upper left
		glTexCoord2f(0, maxCoords.t);
		glVertex2f(-1.0, 1.0);
		//upper right
		glTexCoord2f(maxCoords.s, maxCoords.t);
		glVertex2f(1.0, 1.0);
		//lower right
		glTexCoord2f(maxCoords.s, 0);
		glVertex2f(1.0, -1.0);
	glEnd();
   
  //unbind the shader
  m_shader.UnbindShader();
  
  return FF_SUCCESS;
}

DWORD FFGLStatic::GetParameter(DWORD dwIndex)
{
	DWORD dwRet;
	switch (dwIndex) {
	case FFPARAM_Mode:
    *((float *)(unsigned)&dwRet) = m_mode;
		return dwRet;
	default:
		return FF_FAIL;
	}
}

char* FFGLStatic::GetParameterDisplay(DWORD dwIndex)
{
	DWORD dwType = m_pPlugin->GetParamType(dwIndex);
	DWORD dwValue = m_pPlugin->GetParameter(dwIndex);

	if ((dwValue != FF_FAIL) && (dwType != FF_FAIL))
	{
		if (dwType == FF_TYPE_TEXT)
		{
			return (char *)dwValue;
		}
		else
		{
			switch (dwIndex) {
			case FFPARAM_Mode:
				if (m_mode < 0.33)
					sprintf(m_Displayvalue, "%s", "Color");
				else if (m_mode < 0.66)
					sprintf(m_Displayvalue, "%s", "Grayscale");
				else 
					sprintf(m_Displayvalue, "%s", "Two-tone");
				break;
			default:
				return NULL;
			}
			return m_Displayvalue;
		}
	}
	return NULL;
}

DWORD FFGLStatic::SetParameter(const SetParameterStruct* pParam)
{
	if (pParam != NULL) {
		switch (pParam->ParameterNumber) {
		case FFPARAM_Mode:
			m_mode = *((float *)&(pParam->NewParameterValue));
			break;
		default:
			return FF_FAIL;
		}
		return FF_SUCCESS;
	}
	return FF_FAIL;
}