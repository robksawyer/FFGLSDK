#include <FFGL.h>
#include <FFGLLib.h>
#include <stdio.h>
#include <cmath>
#include "FFGLEdgeDetection.h"
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

#define MAXMULTIPLIER	5.0f

#define	FFPARAM_Mode		(0)
#define	FFPARAM_Multiplier	(1)

GLfloat texCoordOffsets[2*3*3];	//use a 3*3 kernel - xy offsets for each

bool hastime = false;	//workaround for hosts without Time support

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Plugin information
////////////////////////////////////////////////////////////////////////////////////////////////////

static CFFGLPluginInfo PluginInfo ( 
	FFGLEdgeDetection::CreateInstance,	// Create method
	"MEDG",								// Plugin unique ID											
	"Edge Detection",					// Plugin name											
	1,						   			// API major version number 													
	000,								  // API minor version number	
	1,										// Plugin major version number
	100,									// Plugin minor version number
	FF_EFFECT,						// Plugin type
	"Detects edges in an image",	// Plugin description
	"by Matias Wilkman (based on code from the OpenGL Superbible)" // About
);

char *vertexShaderCode =
"void main()"
"{"
"  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;"
"  gl_TexCoord[0] = gl_MultiTexCoord0;"
"  gl_FrontColor = gl_Color;"
"}";

char *fragmentShaderSobel =
"uniform sampler2D sampler0;"
"uniform vec2 tc_offset[9];"
"uniform float mult;"
"void main(void)"
"{"
"	vec4 sample[9];"
"	vec4 rgba = texture2D(sampler0, gl_TexCoord[0].st);"
"	sample[0] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[0]);"
"	sample[1] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[1]);"
"	sample[2] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[2]);"
"	sample[3] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[3]);"
"	sample[4] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[4]);"
"	sample[5] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[5]);"
"	sample[6] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[6]);"
"	sample[7] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[7]);"
"	sample[8] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[8]);"
//    -1 -2 -1       1 0 -1 
// H = 0  0  0   V = 2 0 -2
//     1  2  1       1 0 -1
//
// result = sqrt(H^2 + V^2)
"	vec4 horizEdge = sample[2] + (2.0*sample[5]) + sample[8] -"
"		(sample[0] + (2.0*sample[3]) + sample[6]);"
"	vec4 vertEdge = sample[0] + (2.0*sample[1]) + sample[2] -"
"		(sample[6] + (2.0*sample[7]) + sample[8]);"
"	gl_FragColor.rgb = sqrt((horizEdge.rgb * horizEdge.rgb) + "
"		(vertEdge.rgb * vertEdge.rgb));"
"	gl_FragColor.a = rgba.a;"
"}";

char *fragmentShaderLaplace =
"uniform sampler2D sampler0;"
"uniform vec2 tc_offset[9];"
"uniform float mult;"
"void main(void)"
"{"
"	 vec4 rgba = texture2D(sampler0, gl_TexCoord[0].st);"
"	 vec4 sample[9];"
"	 sample[0] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[0]);"
"	 sample[1] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[1]);"
"	 sample[2] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[2]);"
"	 sample[3] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[3]);"
"	 sample[4] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[4]);"
"	 sample[5] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[5]);"
"	 sample[6] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[6]);"
"	 sample[7] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[7]);"
"	 sample[8] = mult*texture2D(sampler0, gl_TexCoord[0].st + tc_offset[8]);"
//   -1 -1 -1
//   -1  8 -1
//   -1 -1 -1
"    gl_FragColor = (sample[4] * 8.0) - "
"                    (sample[0] + sample[1] + sample[2] + "
"                     sample[3] + sample[5] + "
"                     sample[6] + sample[7] + sample[8]);"
"	 gl_FragColor.a = rgba.a;"
"}";

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Constructor and destructor
////////////////////////////////////////////////////////////////////////////////////////////////////

FFGLEdgeDetection::FFGLEdgeDetection()
:CFreeFrameGLPlugin(),
 m_initResources(1)
{
	// Input properties
	SetMinInputs(1);
	SetMaxInputs(1);

	// parameters:
	SetParamInfo(FFPARAM_Mode, "Mode", FF_TYPE_STANDARD, 1.0f);	
	m_mode = 1.0f;
	currentshader = m_mode;
	SetParamInfo(FFPARAM_Multiplier, "Multiplier", FF_TYPE_STANDARD, 1.0f/MAXMULTIPLIER);	
	m_mult = 1.0f/MAXMULTIPLIER;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Methods
////////////////////////////////////////////////////////////////////////////////////////////////////

DWORD FFGLEdgeDetection::InitGL(const FFGLViewportStruct *vp)
{
	//initialize gl extensions and
	//make sure required features are supported
	m_extensions.Initialize();
	if (m_extensions.ARB_shader_objects==0)
		return FF_FAIL;
    
  //initialize gl shader
	m_shader.SetExtensions(&m_extensions);
	if (!m_shader.Compile(vertexShaderCode,fragmentShaderSobel))
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
	m_tcoffsetlocation = m_shader.FindUniform("tc_offset");
	m_multlocation = m_shader.FindUniform("mult");
    
	m_shader.UnbindShader();

	return FF_SUCCESS;
}

DWORD FFGLEdgeDetection::DeInitGL()
{
  m_shader.FreeGLResources();
  return FF_SUCCESS;
}

DWORD FFGLEdgeDetection::ProcessOpenGL(ProcessOpenGLStruct *pGL)
{
	if (pGL->numInputTextures<1) return FF_FAIL;
	if (pGL->inputTextures[0]==NULL) return FF_FAIL;

	FFGLTextureStruct &Texture = *(pGL->inputTextures[0]);
	FFGLTexCoords maxCoords = GetMaxGLTexCoords(Texture);

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
	if (round(m_mode) != currentshader)
	{
		currentshader = round(m_mode);
		if (m_mode >= 0.5)	//>= 0.5 = Sobel, < 0.5 = Laplace
		{
			if (!m_shader.Compile(vertexShaderCode, fragmentShaderSobel))
				return FF_FAIL;
		} 
		else
		{
			if (!m_shader.Compile(vertexShaderCode,fragmentShaderLaplace))
				return FF_FAIL;
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
    
	//to assign values to parameters in the shader, we have to lookup
	//the "location" of each value.. then call one of the glUniform* methods
	//to assign a value
	m_tcoffsetlocation = m_shader.FindUniform("tc_offset");
	m_multlocation = m_shader.FindUniform("mult");
    
	m_extensions.glUniform2fvARB(m_tcoffsetlocation, 9, texCoordOffsets);
	m_extensions.glUniform1fARB(m_multlocation, m_mult*MAXMULTIPLIER);
	//m_extensions.glUniform1iARB(m_modelocation, m_mode > 0.5 ? 1.0 : 0.0);

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

DWORD FFGLEdgeDetection::GetParameter(DWORD dwIndex)
{
	DWORD dwRet;
	switch (dwIndex) {
	case FFPARAM_Mode:
    *((float *)(unsigned)&dwRet) = m_mode;
		return dwRet;
	case FFPARAM_Multiplier:
    *((float *)(unsigned)&dwRet) = m_mult;
		return dwRet;
	default:
		return FF_FAIL;
	}
}

char* FFGLEdgeDetection::GetParameterDisplay(DWORD dwIndex)
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
				if (m_mode <= 0.50)
					sprintf(m_Displayvalue, "%s", "Laplace");
				else
					sprintf(m_Displayvalue, "%s", "Sobel");
				break;
			case FFPARAM_Multiplier:
				sprintf(m_Displayvalue, "%.1f", m_mult*MAXMULTIPLIER);
				break;
			default:
				return NULL;
			}
			return m_Displayvalue;
		}
	}
	return NULL;
}

DWORD FFGLEdgeDetection::SetParameter(const SetParameterStruct* pParam)
{
	if (pParam != NULL) {
		switch (pParam->ParameterNumber) {
		case FFPARAM_Mode:
			m_mode = *((float *)&(pParam->NewParameterValue));
			break;
		case FFPARAM_Multiplier:
			m_mult = *((float *)&(pParam->NewParameterValue));
			break;
		default:
			return FF_FAIL;
		}
		return FF_SUCCESS;
	}
	return FF_FAIL;
}