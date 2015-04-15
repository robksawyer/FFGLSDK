#include <FFGL.h>
#include <FFGLLib.h>
#include <stdio.h>
#include <cmath>
#include "FFGLChromaKey.h"
#include "utilities.h"

#ifdef _WIN32
#include "../common/opengl/include/glut.h"
#include <windows.h>
#else	//all other platforms
#include <OpenGL/glu.h>
#endif
#ifdef __APPLE__	//OS X
#include <Carbon.h>
#endif

#define	FFPARAM_Tolerance	(0)
#define	FFPARAM_Feather		(1)
#define	FFPARAM_Hue			(2)
#define	FFPARAM_Saturation 	(3)
#define	FFPARAM_Brightness	(4)
#define	FFPARAM_Linear		(5)
#define	FFPARAM_Ramp		(6)

GLfloat texCoordOffsets[2*3*3];	//use a 3*3 kernel - xy offsets for each

bool hastime = false;	//workaround for hosts without Time support

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Plugin information
////////////////////////////////////////////////////////////////////////////////////////////////////

static CFFGLPluginInfo PluginInfo ( 
	FFGLChromaKey::CreateInstance,	// Create method
	"MCKY",								// Plugin unique ID											
	"Chroma Key",					// Plugin name											
	1,						   			// API major version number 													
	000,								  // API minor version number	
	1,										// Plugin major version number
	100,									// Plugin minor version number
	FF_EFFECT,						// Plugin type
	"Keys out a certain color in an image",	// Plugin description
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
"uniform sampler2D sampler0;"
"uniform vec2 tc_offset[9];"
"uniform float feather;"
"uniform vec3 key;"
"uniform bool linear;"
"uniform float tolerance;"
"uniform float ramp;"
"uniform float kernel[9];"
//"kernel = {1.0/16.0, 2.0/16.0, 1.0/16.0, 2.0/16.0, 4.0/16.0, 2.0/16.0, 1.0/16.0, 2.0/16.0, 1.0/16.0};"	//gaussian blur kernel
"void main(void)"
"{"
"	vec4 sum = vec4(0.0);"
"   vec4 rgba = texture2D(sampler0, gl_TexCoord[0].st);"
"	for (int i = 0; i < 9; i++)"	//blur the alpha channel
"	{"
"		vec4 tmp = texture2D(sampler0, gl_TexCoord[0].st + feather*tc_offset[i]);"
"		float d = distance(tmp.rgb, key);"
"		if (d <= tolerance) {"
"			tmp.a = 0.0;"
"		}"
"		if (linear) {"
"			if (d <= tolerance) {"
"				tmp.a = 0.0;"
"			}"
"			else {"
"				tmp.a = d*ramp;"
"			}"
"		}"
"		sum += tmp * kernel[i];"
"	}"
"	rgba.a = sum.a;"
//"	rgba = vec4(1.0);"
"   gl_FragColor = rgba;"
"}";

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Constructor and destructor
////////////////////////////////////////////////////////////////////////////////////////////////////

FFGLChromaKey::FFGLChromaKey()
:CFreeFrameGLPlugin(),
 m_initResources(1)
{
	// Input properties
	SetMinInputs(1);
	SetMaxInputs(1);

	// parameters:
	SetParamInfo(FFPARAM_Tolerance, "Tolerance", FF_TYPE_STANDARD, 0.2f);	
	m_tolerance = 0.2f;
	SetParamInfo(FFPARAM_Feather, "Feather", FF_TYPE_STANDARD, 0.0f);	
	m_feather = 0.0f;
	SetParamInfo(FFPARAM_Hue, "Hue", FF_TYPE_STANDARD, 0.33f);
	m_key[0] = 0.33f;
	SetParamInfo(FFPARAM_Saturation, "Saturation", FF_TYPE_STANDARD, 1.0f);
	m_key[1] = 1.0f;
	SetParamInfo(FFPARAM_Brightness, "Brightness", FF_TYPE_STANDARD, 1.0f);
	m_key[2] = 1.0f;
	SetParamInfo(FFPARAM_Linear, "Linear", FF_TYPE_BOOLEAN, false);
	m_linearvalue = 0.0f;
	m_linear = false;
	SetParamInfo(FFPARAM_Ramp, "Ramp", FF_TYPE_STANDARD, 0.7f);
	m_ramp = 0.7f;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Methods
////////////////////////////////////////////////////////////////////////////////////////////////////

DWORD FFGLChromaKey::InitGL(const FFGLViewportStruct *vp)
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
	m_kernellocation = m_shader.FindUniform("kernel");
	m_tcoffsetlocation = m_shader.FindUniform("tc_offset");
	m_tolerancelocation = m_shader.FindUniform("tolerance");
	m_featherlocation = m_shader.FindUniform("feather");
	m_keylocation = m_shader.FindUniform("key");
	m_linearlocation = m_shader.FindUniform("linear");
	m_ramplocation = m_shader.FindUniform("ramp");
    
	m_shader.UnbindShader();

	return FF_SUCCESS;
}

DWORD FFGLChromaKey::DeInitGL()
{
  m_shader.FreeGLResources();
  return FF_SUCCESS;
}

DWORD FFGLChromaKey::ProcessOpenGL(ProcessOpenGLStruct *pGL)
{
	if (pGL->numInputTextures<1) return FF_FAIL;
	if (pGL->inputTextures[0]==NULL) return FF_FAIL;

	FFGLTextureStruct &Texture = *(pGL->inputTextures[0]);
	FFGLTexCoords maxCoords = GetMaxGLTexCoords(Texture);

	float kernel[9] = {1.0/16.0, 2.0/16.0, 1.0/16.0, 2.0/16.0, 4.0/16.0, 2.0/16.0, 1.0/16.0, 2.0/16.0, 1.0/16.0};	//gaussian blur kernel
	
	float xInc = maxCoords.s/(GLfloat)Texture.HardwareWidth;
	float yInc = maxCoords.t/(GLfloat)Texture.HardwareHeight;

    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            texCoordOffsets[(((i*3)+j)*2)+0] = (-1.0f * xInc) + ((GLfloat)i * xInc);
            texCoordOffsets[(((i*3)+j)*2)+1] = (-1.0f * yInc) + ((GLfloat)j * yInc);
        }
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
    
	m_extensions.glUniform2fvARB(m_tcoffsetlocation, 9, texCoordOffsets);
	m_extensions.glUniform1fvARB(m_kernellocation, 9, kernel);
	m_extensions.glUniform1fARB(m_featherlocation, m_feather);
	m_extensions.glUniform1fARB(m_tolerancelocation, m_tolerance);
	m_extensions.glUniform3fvARB(m_keylocation, 1, m_key_rgb);
	m_extensions.glUniform1iARB(m_linearlocation, m_linear);
	m_extensions.glUniform1fARB(m_ramplocation, (1.0f+m_ramp));

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

DWORD FFGLChromaKey::GetParameter(DWORD dwIndex)
{
	DWORD dwRet;
	switch (dwIndex) {
	case FFPARAM_Tolerance:
		*((float *)(unsigned)&dwRet) = m_tolerance;
		return dwRet;
	case FFPARAM_Feather:
		*((float *)(unsigned)&dwRet) = m_feather;
		return dwRet;
	case FFPARAM_Hue:
	case FFPARAM_Saturation:
	case FFPARAM_Brightness:
		*((float *)(unsigned)&dwRet) = m_key[dwIndex - FFPARAM_Hue];
		return dwRet;
	case FFPARAM_Linear:
		*((float *)(unsigned)&dwRet) = m_linearvalue;
		return dwRet;
	case FFPARAM_Ramp:
		*((float *)(unsigned)&dwRet) = m_ramp;
		return dwRet;
	default:
		return FF_FAIL;
	}
}

char* FFGLChromaKey::GetParameterDisplay(DWORD dwIndex)
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
			case FFPARAM_Tolerance:
				sprintf(m_Displayvalue, "%.1f", m_tolerance);
				break;
			case FFPARAM_Feather:
				sprintf(m_Displayvalue, "%.1f", m_feather);
				break;
			case FFPARAM_Hue:
			case FFPARAM_Saturation:
			case FFPARAM_Brightness:
				sprintf(m_Displayvalue, "%.1f", m_key[dwIndex - FFPARAM_Hue]);
				break;
			case FFPARAM_Linear:
				sprintf(m_Displayvalue, "%s", m_linear?"On":"Off");
				break;
			case FFPARAM_Ramp:
				sprintf(m_Displayvalue, "%.1f", m_ramp);
				break;
			default:
				return NULL;
			}
			return m_Displayvalue;
		}
	}
	return NULL;
}

DWORD FFGLChromaKey::SetParameter(const SetParameterStruct* pParam)
{
	if (pParam != NULL) {
		switch (pParam->ParameterNumber) {
		case FFPARAM_Tolerance:
			m_tolerance = *((float *)&(pParam->NewParameterValue));
			break;
		case FFPARAM_Feather:
			m_feather = *((float *)&(pParam->NewParameterValue));
			break;
		case FFPARAM_Hue:
		case FFPARAM_Saturation:
		case FFPARAM_Brightness:
			m_key[pParam->ParameterNumber - FFPARAM_Hue] = *((float *)&(pParam->NewParameterValue));
			HSVtoRGB(m_key[0], m_key[1], m_key[2], &m_key_rgb[0], &m_key_rgb[1], &m_key_rgb[2]);	
			break;
		case FFPARAM_Linear:
			m_linearvalue = *((float *)&(pParam->NewParameterValue));
			m_linear = (m_linearvalue > 0.5)?true:false;
			break;
		case FFPARAM_Ramp:
			m_ramp = *((float *)&(pParam->NewParameterValue));
			break;
		default:
			return FF_FAIL;
		}
		return FF_SUCCESS;
	}
	return FF_FAIL;
}