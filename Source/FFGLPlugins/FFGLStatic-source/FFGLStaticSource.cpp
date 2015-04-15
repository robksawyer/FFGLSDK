#include <FFGL.h>
#include <FFGLLib.h>
#include <cstdlib>
#include <cmath>
#include <stdio.h>
#include "FFGLStaticSource.h"
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
	FFGLStaticSource::CreateInstance,	// Create method
	"MSTS",								// Plugin unique ID											
	"Static Generator",					// Plugin name											
	1,						   			// API major version number 													
	000,								  // API minor version number	
	1,										// Plugin major version number
	100,									// Plugin minor version number
	FF_SOURCE,						// Plugin type
	"Static Generator",	// Plugin description
	"by Matias Wilkman" // About
);

char *vertexShaderCode =
"void main()"
"{"
"  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;"
"  gl_FrontColor = gl_Color;"
"}";

char *fragmentShaderCode =
"float rand(vec2 co){"
"        return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);"
"}"
"uniform float time;"
"uniform bool twotone;"
"uniform bool grayscale;"
"void main(void)"
"{"
"	vec4 c_out = vec4(0.0, 1.0, 0.0, 1.0);"
"	vec2 texCoord = gl_FragCoord.xy;"
"	texCoord.s += 8.64*fract(texCoord.t + time);"
"	texCoord.t += 4.57*fract(texCoord.s + time);"
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

FFGLStaticSource::FFGLStaticSource()
:CFreeFrameGLPlugin(),
 m_initResources(1)
{
	// Input properties
	SetMinInputs(0);
	SetMaxInputs(0);
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

DWORD FFGLStaticSource::SetTime(double time)
{
  m_time = time;
  hastime = true;
  return FF_SUCCESS;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Methods
////////////////////////////////////////////////////////////////////////////////////////////////////

DWORD FFGLStaticSource::InitGL(const FFGLViewportStruct *vp)
{
  //initialize gl extensions and
  //make sure required features are supported
  m_extensions.Initialize();
  if (m_extensions.ARB_shader_objects==0)
    return FF_FAIL;
    
  //initialize gl shader
  m_shader.SetExtensions(&m_extensions);
  m_shader.Compile(vertexShaderCode,fragmentShaderCode);
 
  //activate our shader
  m_shader.BindShader();
    
  //to assign values to parameters in the shader, we have to lookup
  //the "location" of each value.. then call one of the glUniform* methods
  //to assign a value
  m_timeLocation = m_shader.FindUniform("time");
  m_grayscaleLocation = m_shader.FindUniform("grayscale");
  m_twotoneLocation = m_shader.FindUniform("twotone");
    
  m_shader.UnbindShader();

  return FF_SUCCESS;
}

DWORD FFGLStaticSource::DeInitGL()
{
  m_shader.FreeGLResources();

  return FF_SUCCESS;
}

DWORD FFGLStaticSource::ProcessOpenGL(ProcessOpenGLStruct *pGL)
{
// If no calls to SetTime have been made, the host probably
// doesn't support Time, so we'll update m_time manually
	if (!hastime)
	{
		update_time(&m_time, t0);
	}

	//activate our shader
	m_shader.BindShader();
	    
	//get the max s,t that correspond to the 
	//width,height of the used portion of the allocated texture space
	float foo = (m_time+float(rand()%100));
	m_extensions.glUniform1fARB(m_timeLocation, foo);

	m_extensions.glUniform1iARB(m_grayscaleLocation, m_mode>0.33f?true:false);
	m_extensions.glUniform1iARB(m_twotoneLocation, m_mode>0.66f?true:false);

	//draw the quad that will be painted by the shader/textures
	//note that we are sending texture coordinates to texture unit 0..
	//the vertex shader and fragment shader refer to this when querying for
	//texture coordinates of the inputTexture
	glBegin(GL_QUADS);
		//lower left
		glVertex2f(-1,-1);
		//upper left
		glVertex2f(-1,1);
		//upper right
		glVertex2f(1,1);
		//lower right
		glVertex2f(1,-1);
	glEnd();

   
  //unbind the shader
  m_shader.UnbindShader();
  
  return FF_SUCCESS;
}
DWORD FFGLStaticSource::GetParameter(DWORD dwIndex)
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

char* FFGLStaticSource::GetParameterDisplay(DWORD dwIndex)
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

DWORD FFGLStaticSource::SetParameter(const SetParameterStruct* pParam)
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