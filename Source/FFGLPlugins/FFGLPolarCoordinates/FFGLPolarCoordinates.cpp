#include <FFGL.h>
#include <FFGLLib.h>
#include <stdio.h>
#include <cmath>
#include "FFGLPolarCoordinates.h"
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

#define	FFPARAM_Direction	(0)
#define	FFPARAM_Amount		(1)

bool hastime = false;	//workaround for hosts without Time support

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Plugin information
////////////////////////////////////////////////////////////////////////////////////////////////////

static CFFGLPluginInfo PluginInfo ( 
	FFGLPolarCoordinates::CreateInstance,	// Create method
	"MPOL",								// Plugin unique ID											
	"PolarCoordinates",					// Plugin name											
	1,						   			// API major version number 													
	000,								  // API minor version number	
	1,										// Plugin major version number
	100,									// Plugin minor version number
	FF_EFFECT,						// Plugin type
	"Converts between cartesian and polar coordinate systems",	// Plugin description
	"by Matias Wilkman (from code by Matthew Allen)" // About
);

char *vertexShaderCode =
"void main()"
"{"
"  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;"
"  gl_TexCoord[0] = gl_MultiTexCoord0;"
"  gl_FrontColor = gl_Color;"
"}";

/*	The magic numbers in these shaders are offsets
	to make the effect look like it does in 
	Adobe Photoshop.
*/
char *fragmentShaderCartesianToPolar =
"uniform sampler2D sampler0;"
"vec2 cartesian(vec2 coords)"
"{"
"    return coords - vec2(0.5);"
"}"
"vec2 cartToPolar(vec2 coords)"
"{"
"    float mag = length(coords)*2.0;"
"    mag = clamp(mag, 0.0, 1.0);"    // clamp it
"    float angle = atan(coords.y, coords.x);"    // angle = arc tangent of y/x
"    angle = (angle-1.57079633)/6.28319;"	//same offset as photoshop
"    coords.x = angle;"
"    coords.y = -1.0*mag;"
"    return coords;"
"}"
"uniform float amount;"
"void main(void)"
"{"
"	 vec2 coords;"
"    coords = cartesian(gl_TexCoord[0].st);"
"    coords = cartToPolar(coords);"    // do the algebra to get the angle and magnitude
"    coords = mix(gl_TexCoord[0].st, coords, amount);"
"	 coords = fract(coords);"
"    gl_FragColor = texture2D(sampler0, coords);"
"}";

char *fragmentShaderPolarToCartesian =
"uniform sampler2D sampler0;"
"vec2 polar(vec2 coords)"
"{"
"	coords = coords / 2.0;"
"   coords += 0.5;"
"   return coords;"
"}"
"vec2 polarToCart(vec2 coords)"
"{"
"	float mag = coords[1];"
"	float angle = -1.0*coords[0]*6.28319+1.57079633;"
"   coords[0] = mag*cos(angle);"
"   coords[1] = mag*sin(angle);"
"   return coords;"
"}"
"uniform float amount;"
"void main(void)"
"{"
"	 vec2 coords = gl_TexCoord[0].st;"
"	 coords[0] = mix(1.0, 0.0, coords[0]);"
"	 coords[1] = mix(1.0, 0.0, coords[1]);"
"    coords = polarToCart(coords);"    // do the algebra to get the angle and magnitude
"    coords = polar(coords);"
"    coords = mix(gl_TexCoord[0].st, coords, amount);"
"	 coords = fract(coords);"
"    gl_FragColor = texture2D(sampler0, coords);"
"}";

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Constructor and destructor
////////////////////////////////////////////////////////////////////////////////////////////////////

FFGLPolarCoordinates::FFGLPolarCoordinates()
:CFreeFrameGLPlugin(),
 m_initResources(1)
{
	// Input properties
	SetMinInputs(1);
	SetMaxInputs(1);

	// parameters:
	SetParamInfo(FFPARAM_Direction, "Cartesian to Polar", FF_TYPE_BOOLEAN, true);	
	m_cartesiantopolar = true;
	SetParamInfo(FFPARAM_Amount, "Amount", FF_TYPE_STANDARD, 1.0f);	
	m_amount = 1.0f;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Methods
////////////////////////////////////////////////////////////////////////////////////////////////////

DWORD FFGLPolarCoordinates::InitGL(const FFGLViewportStruct *vp)
{
	//initialize gl extensions and
	//make sure required features are supported
	m_extensions.Initialize();
	if (m_extensions.ARB_shader_objects==0)
		return FF_FAIL;
    
  //initialize gl shader
	m_shader.SetExtensions(&m_extensions);
	if (!m_shader.Compile(vertexShaderCode,fragmentShaderCartesianToPolar))
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

DWORD FFGLPolarCoordinates::DeInitGL()
{
  m_shader.FreeGLResources();
  return FF_SUCCESS;
}

DWORD FFGLPolarCoordinates::ProcessOpenGL(ProcessOpenGLStruct *pGL)
{
	if (pGL->numInputTextures<1) return FF_FAIL;
	if (pGL->inputTextures[0]==NULL) return FF_FAIL;

	FFGLTextureStruct &Texture = *(pGL->inputTextures[0]);
	FFGLTexCoords maxCoords = GetMaxGLTexCoords(Texture);

	if (m_cartesiantopolar)
	{
		if (!m_shader.Compile(vertexShaderCode, fragmentShaderCartesianToPolar))
			return FF_FAIL;
	} else
	{
		if (!m_shader.Compile(vertexShaderCode, fragmentShaderPolarToCartesian))
			return FF_FAIL;
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
	m_amountlocation = m_shader.FindUniform("amount");
	m_extensions.glUniform1fARB(m_amountlocation, m_amount);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, Texture.Handle);
	
	//Store current parameters:
	GLint wraps, wrapt;
	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, &wraps);
	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, &wrapt);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
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

DWORD FFGLPolarCoordinates::GetParameter(DWORD dwIndex)
{
	DWORD dwRet;
	switch (dwIndex) {
	case FFPARAM_Direction:
		*((float *)(unsigned)&dwRet) = m_cartesiantopolar_value;
		return dwRet;
	case FFPARAM_Amount:
		*((float *)(unsigned)&dwRet) = m_amount;
		return dwRet;
	default:
		return FF_FAIL;
	}
}

char* FFGLPolarCoordinates::GetParameterDisplay(DWORD dwIndex)
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
			case FFPARAM_Direction:
				sprintf(m_Displayvalue, "%s", m_cartesiantopolar?"Cartesian>Polar":"Polar>Cartesian");
				break;
			case FFPARAM_Amount:
				sprintf(m_Displayvalue, "%.1f", m_amount);
				break;
			default:
				return NULL;
			}
			return m_Displayvalue;
		}
	}
	return NULL;
}

DWORD FFGLPolarCoordinates::SetParameter(const SetParameterStruct* pParam)
{
	if (pParam != NULL) {
		switch (pParam->ParameterNumber) {
		case FFPARAM_Direction:
			m_cartesiantopolar_value = *((float *)&(pParam->NewParameterValue));
			m_cartesiantopolar = (m_cartesiantopolar_value > 0.5f);
			break;
		case FFPARAM_Amount:
			m_amount = *((float *)&(pParam->NewParameterValue));
			break;
		default:
			return FF_FAIL;
		}
		return FF_SUCCESS;
	}
	return FF_FAIL;
}