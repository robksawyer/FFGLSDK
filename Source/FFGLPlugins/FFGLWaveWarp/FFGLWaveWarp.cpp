#include <FFGL.h>
#include <FFGLLib.h>
#include "../common/opengl/include/glext.h"
#include "FFGLWaveWarp.h"
#include "utilities.h"

#ifdef _WIN32
#include "../common/opengl/include/glut.h"
#define NOMINMAX
#include <windows.h>
#else	//all other platforms
#include <OpenGL/glu.h>
#endif
#ifdef __APPLE__	//OS X
#include <TargetConditionals.h>
#include <Carbon.h>
#endif
#include <stdio.h>
#include <cmath>
#include <algorithm>

#define TWOPI (6.28318531)

#define	FFPARAM_Mode		(0)
#define	FFPARAM_Height		(1)
#define	FFPARAM_Width		(2)
#define FFPARAM_Angle		(3)
#define FFPARAM_Speed		(4)
#define FFPARAM_Pinning		(5)

using namespace std;

bool hastime = false;	//workaround for hosts without Time support

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Plugin information
////////////////////////////////////////////////////////////////////////////////////////////////////

static CFFGLPluginInfo PluginInfo ( 
	FFGLWaveWarp::CreateInstance,	// Create method
	"MWWP",								// Plugin unique ID											
	"Wave Warp",					// Plugin name											
	1,						   			// API major version number 													
	000,								  // API minor version number	
	1,										// Plugin major version number
	100,									// Plugin minor version number
	FF_EFFECT,						// Plugin type
	"Warps the image according to a waveform",	// Plugin description
	"by Matias Wilkman" // About
);

char *vertexShaderCode =
"void main()"
"{"
"  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;"
"  gl_TexCoord[0] = gl_MultiTexCoord0;"
"  gl_FrontColor = gl_Color;"
"}";

char *fragmentShaderSine =
"uniform sampler2D sampler0;"
"uniform float width;"
"uniform float height;"
"uniform float cosa;"
"uniform float sina;"
"uniform float time;"
"uniform bool pinning;"
"float TWOPI = 6.28318531;"
"void main(void)"
"{"
"   vec2 dir = vec2(cosa, sina);"
"   mat2 R = mat2(cosa, sina, -1.0*sina, cosa);"   //column-major order
"	vec2 xy = vec2(gl_TexCoord[0].s, gl_TexCoord[0].t);"
"   gl_FragColor = texture2D(sampler0, "
"      xy);"
"	float sheight = mix(0.0, 0.5, height);"
"   xy -= sheight/2.0*dir;"
"   vec2 rxy = R*xy;"
"   xy += dir*sheight*sin(mod(mix(0.5, 45.0, width)*rxy.y+time, TWOPI));" 
"	if (pinning)"	//OS X workaround
"		xy = clamp(abs(xy), 0.01, 0.99);"
"   gl_FragColor = texture2D(sampler0, "
"      xy);"
"}";

char *fragmentShaderSquare=
"uniform sampler2D sampler0;"
"uniform float width;"
"uniform float height;"
"uniform float cosa;"
"uniform float sina;"
"uniform float time;"
"uniform bool pinning;"
"float TWOPI = 6.28318531;"
"void main(void)"
"{"
"   vec2 dir = vec2(cosa, sina);"
"   mat2 R = mat2(cosa, sina, -1.0*sina, cosa);"   //column-major order
"	vec2 xy = vec2(gl_TexCoord[0].s, gl_TexCoord[0].t);"
"	float sheight = mix(0.0, 0.5, height);"
"   xy -= sheight/2.0*dir;"
"   vec2 rxy = R*xy;"
"   xy += dir*sheight*step(0.5, mod(mix(1.0, 45.0, width)*rxy.y+time, 1.0));" 
"	if (pinning)"	//OS X workaround
"		xy = clamp(abs(xy), 0.01, 0.99);"
"   gl_FragColor = texture2D(sampler0, "
"      xy);"
"}";

char *fragmentShaderSawtooth =
"uniform sampler2D sampler0;"
"uniform float width;"
"uniform float height;"
"uniform float cosa;"
"uniform float sina;"
"uniform float time;"
"uniform bool pinning;"
"float TWOPI = 6.28318531;"
"void main(void)"
"{"
"   vec2 dir = vec2(cosa, sina);"
"   mat2 R = mat2(cosa, sina, -1.0*sina, cosa);"   //column-major order
"	vec2 xy = vec2(gl_TexCoord[0].s, gl_TexCoord[0].t);"
"	float sheight = mix(0.0, 0.5, height);"
"   xy -= sheight/2.0*dir;"
"   vec2 rxy = R*xy;"
"   xy += dir*sheight*mod(mix(1.0, 45.0, width)*rxy.y+time, 1.0);" 
"	if (pinning)"	//OS X workaround
"		xy = clamp(abs(xy), 0.01, 0.99);"
"   gl_FragColor = texture2D(sampler0, "
"      xy);"
"}";

char *fragmentShaderTriangle=
"uniform sampler2D sampler0;"
"uniform float width;"
"uniform float height;"
"uniform float cosa;"
"uniform float sina;"
"uniform float time;"
"uniform bool pinning;"
"float TWOPI = 6.28318531;"
"void main(void)"
"{"
"   vec2 dir = vec2(cosa, sina);"
"   mat2 R = mat2(cosa, sina, -1.0*sina, cosa);"   //column-major order
"	vec2 xy = vec2(gl_TexCoord[0].s, gl_TexCoord[0].t);"
"	float sheight = mix(0.0, 0.5, height);"
"   xy -= sheight/2.0*dir;"
"   vec2 rxy = R*xy;"
"   xy += dir*sheight*abs(2.0*mod(mix(1.0, 45.0, width)*rxy.y+time, 1.0)-1.0);" 
"	if (pinning)"	//OS X workaround
"		xy = clamp(abs(xy), 0.01, 0.99);"
"   gl_FragColor = texture2D(sampler0, "
"      xy);"
"}";

char *fragmentShaderNoise =
"float rand(vec2 co){"
"        return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);"
"}"
"uniform sampler2D sampler0;"
"uniform vec2 maxCoords;"
"uniform float width;"
"uniform float height;"
"uniform float cosa;"
"uniform float sina;"
"uniform float time;"
"uniform bool pinning;"
"float TWOPI = 6.28318531;"
"void main(void)"
"{"
"   vec2 dir = vec2(cosa, sina);"
"   mat2 R = mat2(cosa, sina, -1.0*sina, cosa);"   //column-major order
"	vec2 xy = vec2(gl_TexCoord[0].s, gl_TexCoord[0].t);"
"	float sheight = mix(0.0, 0.1, height);"
"   xy -= sheight/2.0*dir;"
"   vec2 rxy = R*xy;"
"	float swidth = width + 0.1;"
"	float scale = 200.0;"
"   xy += dir*sheight*rand(vec2(rxy.y*swidth*scale-fract(rxy.y*swidth*scale)+time));" 
"	if (pinning)"	//OS X workaround
"		xy = clamp(abs(xy), 0.01, 0.99);"
"   gl_FragColor = texture2D(sampler0, "
"      xy);"
"}";

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Constructor and destructor
////////////////////////////////////////////////////////////////////////////////////////////////////

FFGLWaveWarp::FFGLWaveWarp()
:CFreeFrameGLPlugin(),
 m_initResources(1)
{
	// Input properties
	SetMinInputs(1);
	SetMaxInputs(1);
	SetTimeSupported(true);
	init_time(&t0);

	// parameters:
	SetParamInfo(FFPARAM_Mode, "Mode", FF_TYPE_STANDARD, 0.0f);	
	m_mode = 0.0f;
	m_modenames[0] = "Sine";
	m_modenames[1] = "Square";
	m_modenames[2] = "Sawtooth";
	m_modenames[3] = "Triangle";
	m_modenames[4] = "Noise";
	currentshader = currentshader = min((int)(m_mode*NUM_MODES), NUM_MODES-1);
	SetParamInfo(FFPARAM_Height, "Height", FF_TYPE_STANDARD, 0.2f);	
	m_height = 0.2f;
	SetParamInfo(FFPARAM_Width, "Width", FF_TYPE_STANDARD, 0.2f);	
	m_width = 0.2f;
	SetParamInfo(FFPARAM_Angle, "Angle", FF_TYPE_STANDARD, 1.0f);	
	m_angle = 1.0f;
	SetParamInfo(FFPARAM_Speed, "Speed", FF_TYPE_STANDARD, 0.5f);	
	m_speed = 0.5f;
	SetParamInfo(FFPARAM_Pinning, "Pin edges?", FF_TYPE_BOOLEAN, true);	
	m_pinning_val = 1.0f;
	m_pinning = true;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Methods
////////////////////////////////////////////////////////////////////////////////////////////////////

DWORD FFGLWaveWarp::InitGL(const FFGLViewportStruct *vp)
{
	//initialize gl extensions and
	//make sure required features are supported
	m_extensions.Initialize();
	if (m_extensions.ARB_shader_objects==0)
		return FF_FAIL;
    
  //initialize gl shader
	m_shader.SetExtensions(&m_extensions);
	if (!m_shader.Compile(vertexShaderCode,fragmentShaderSine))
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
	m_shader.UnbindShader();

	return FF_SUCCESS;
}

DWORD FFGLWaveWarp::DeInitGL()
{
  m_shader.FreeGLResources();
  return FF_SUCCESS;
}

DWORD FFGLWaveWarp::SetTime(double time)
{
	m_time = time;
	hastime = true;
	return FF_SUCCESS;
}

DWORD FFGLWaveWarp::ProcessOpenGL(ProcessOpenGLStruct *pGL)
{
	if (pGL->numInputTextures<1) return FF_FAIL;
	if (pGL->inputTextures[0]==NULL) return FF_FAIL;
	
	// If no calls to SetTime have been made, the host probably
	// doesn't support Time, so we'll update m_time manually
	if (!hastime)	
	{
		update_time(&m_time, t0);
	}

	FFGLTextureStruct &Texture = *(pGL->inputTextures[0]);
	FFGLTexCoords maxCoords = GetMaxGLTexCoords(Texture);

	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, Texture.Handle);

	//Store current parameters:
	GLint wraps, wrapt;
	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, &wraps);
	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, &wrapt);

	//Does not work on NVidia 9400M under OS X :(
	if (m_pinning) {
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}
	else {
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
	}

	if (min((int)(m_mode*NUM_MODES), NUM_MODES-1) != currentshader) {
		switch (min((int)(m_mode*NUM_MODES), NUM_MODES-1))	//min avoids special case of 1.0
		{
			case 0:	//sine
				if (!m_shader.Compile(vertexShaderCode, fragmentShaderSine))
					return FF_FAIL;
				break;
			case 1:	//square
				if (!m_shader.Compile(vertexShaderCode, fragmentShaderSquare))
					return FF_FAIL;
				break;
			case 2:	//sawtooth
				if (!m_shader.Compile(vertexShaderCode, fragmentShaderSawtooth))
					return FF_FAIL;
				break;
			case 3:	//triangle
				if (!m_shader.Compile(vertexShaderCode, fragmentShaderTriangle))
					return FF_FAIL;
				break;
			case 4:	//noise
				if (!m_shader.Compile(vertexShaderCode, fragmentShaderNoise))
					return FF_FAIL;
				break;
			default:
				return FF_FAIL;
		}
		currentshader = min((int)(m_mode*NUM_MODES), NUM_MODES-1);
	}
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
	m_widthlocation = m_shader.FindUniform("width");
	m_heightlocation = m_shader.FindUniform("height");
	m_timelocation = m_shader.FindUniform("time");    
	m_cosalocation = m_shader.FindUniform("cosa");
	m_sinalocation = m_shader.FindUniform("sina");
	m_pinninglocation = m_shader.FindUniform("pinning");

	m_extensions.glUniform1fARB(m_widthlocation, (1.0f-m_width));
	m_extensions.glUniform1fARB(m_heightlocation, m_height);
	m_extensions.glUniform1fARB(m_cosalocation, m_cosa);
	m_extensions.glUniform1fARB(m_sinalocation, m_sina);
	m_extensions.glUniform1fARB(m_timelocation, (float)(m_time*m_speed*MAX_SPEED));
	m_extensions.glUniform1iARB(m_pinninglocation, m_pinning);

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
	//restore original parameters
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wraps);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapt);
	return FF_SUCCESS;
}

DWORD FFGLWaveWarp::GetParameter(DWORD dwIndex)
{
	DWORD dwRet;
	switch (dwIndex) {
	case FFPARAM_Mode:
    *((float *)(unsigned)&dwRet) = m_mode;
		return dwRet;
	case FFPARAM_Height:
    *((float *)(unsigned)&dwRet) = m_height;
		return dwRet;
	case FFPARAM_Width:
    *((float *)(unsigned)&dwRet) = m_width;
		return dwRet;
	case FFPARAM_Angle:
    *((float *)(unsigned)&dwRet) = m_angle;
		return dwRet;
	case FFPARAM_Speed:
    *((float *)(unsigned)&dwRet) = m_speed;
		return dwRet;
	case FFPARAM_Pinning:
    *((float *)(unsigned)&dwRet) = m_pinning_val;
		return dwRet;
	default:
		return FF_FAIL;
	}
}

char* FFGLWaveWarp::GetParameterDisplay(DWORD dwIndex)
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
				sprintf(m_Displayvalue, "%s", m_modenames[min((int)(m_mode*NUM_MODES), NUM_MODES-1)]);	
				break;
			case FFPARAM_Height:
				sprintf(m_Displayvalue, "%.1f", m_height);
				break;
			case FFPARAM_Width:
				sprintf(m_Displayvalue, "%.1f", (1.0f-m_width));
				break;
			case FFPARAM_Angle:
				sprintf(m_Displayvalue, "%.1f %s", (m_angle*TWOPI), "Rad.");
				break;
			case FFPARAM_Speed:
				sprintf(m_Displayvalue, "%.1f", m_speed*MAX_SPEED);
				break;
			case FFPARAM_Pinning:
				sprintf(m_Displayvalue, "%s", m_pinning?"On":"Off");
				break;
			default:
				return NULL;
			}
			return m_Displayvalue;
		}
	}
	return NULL;
}

DWORD FFGLWaveWarp::SetParameter(const SetParameterStruct* pParam)
{
	if (pParam != NULL) {
		switch (pParam->ParameterNumber) {
		case FFPARAM_Mode:
			m_mode = *((float *)&(pParam->NewParameterValue));
			break;
		case FFPARAM_Height:
			m_height = *((float *)&(pParam->NewParameterValue));
			break;
		case FFPARAM_Width:
			m_width = *((float *)&(pParam->NewParameterValue));
			break;
		case FFPARAM_Angle:
			m_angle = *((float *)&(pParam->NewParameterValue));
			m_cosa = cos(m_angle*TWOPI);
			m_sina = sin(m_angle*TWOPI);
			break;
		case FFPARAM_Speed:
			m_speed = *((float *)&(pParam->NewParameterValue));
			break;
		case FFPARAM_Pinning:
			m_pinning_val = *((float *)&(pParam->NewParameterValue));
			m_pinning = (m_pinning_val > 0.5f);
			break;
		default:
			return FF_FAIL;
		}
		return FF_SUCCESS;
	}
	return FF_FAIL;
}