#include <FFGL.h>
#include <FFGLLib.h>
#include <stdio.h>
#include "FFGLStroboscopeEffect.h"
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

#define FFPARAM_Frequency	(0)
#define FFPARAM_Hue1		(1)
#define FFPARAM_Saturation1	(2)
#define FFPARAM_Brightness1	(3)
#define FFPARAM_Alpha1		(4)

bool hastime = false;	//workaround for hosts without Time support

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Plugin information
////////////////////////////////////////////////////////////////////////////////////////////////////

static CFFGLPluginInfo PluginInfo ( 
	FFGLStroboscopeEffect::CreateInstance,	// Create method
	"MSTX",								// Plugin unique ID											
	"Strobe",							// Plugin name											
	1,						   			// API major version number 													
	000,								  // API minor version number	
	1,										// Plugin major version number
	000,									// Plugin minor version number
	FF_EFFECT,						// Plugin type
	"Stroboscope effect. Cycles between video frame and specified color.",	// Plugin description
	"by Matias Wilkman" // About
);

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Constructor and destructor
////////////////////////////////////////////////////////////////////////////////////////////////////

FFGLStroboscopeEffect::FFGLStroboscopeEffect()
:CFreeFrameGLPlugin(),
 m_initResources(1)
{
	// Input properties
	SetMinInputs(1);
	SetMaxInputs(1);
	SetTimeSupported(true);

	init_time(&t0);
	// Parameters
	SetParamInfo(FFPARAM_Frequency, "Frequency", FF_TYPE_STANDARD, 0.5f);
	m_iFrequency = 1.0f - m_Frequency;
	m_Frequency = 0.5f;
	m_lasttime = 0.0f;
	m_swap = false;

	SetParamInfo(FFPARAM_Hue1, "Hue 1", FF_TYPE_STANDARD, 0.0f);	//Frame one color - default is white
	m_HSBA[0][0] = 0.0f;
	SetParamInfo(FFPARAM_Saturation1, "Saturation 1", FF_TYPE_STANDARD, 0.0f);
	m_HSBA[0][1] = 0.0f;
	SetParamInfo(FFPARAM_Brightness1, "Brightness 1", FF_TYPE_STANDARD, 0.0f);
	m_HSBA[0][2] = 0.0f;
	SetParamInfo(FFPARAM_Alpha1, "Alpha 1", FF_TYPE_STANDARD, 0.0f);
	m_HSBA[0][3] = 0.0f;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Methods
////////////////////////////////////////////////////////////////////////////////////////////////////

DWORD FFGLStroboscopeEffect::InitGL(const FFGLViewportStruct *vp)
{
	return FF_SUCCESS;
}

DWORD FFGLStroboscopeEffect::DeInitGL()
{
	return FF_SUCCESS;
}

DWORD FFGLStroboscopeEffect::SetTime(double time)
{
	m_time = time;
	hastime = true;
	return FF_SUCCESS;
}

DWORD FFGLStroboscopeEffect::ProcessOpenGL(ProcessOpenGLStruct *pGL)
{
	if (pGL->numInputTextures<1) return FF_FAIL;
	if (pGL->inputTextures[0]==NULL) return FF_FAIL;

	FFGLTextureStruct &Texture = *(pGL->inputTextures[0]);
	FFGLTexCoords maxCoords = GetMaxGLTexCoords(Texture);

	// If no calls to SetTime have been made, the host probably
	// doesn't support Time, so we'll update m_time manually
	if (!hastime)	
	{
		update_time(&m_time, t0);
	}

	float rgba1[4]; 
	HSVtoRGB(m_HSBA[0][0], m_HSBA[0][1], m_HSBA[0][2], &(rgba1[0]), &(rgba1[1]), &(rgba1[2]));
	rgba1[3] = m_HSBA[0][3];	//alpha

	if (m_time >= m_lasttime + m_iFrequency)
	{
		m_lasttime = m_time;
		m_swap = !m_swap;
	}
	if (m_swap)	//color frame
		glColor4fv(rgba1);
	else	//original frame
	{
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, Texture.Handle);
	}
	glBegin(GL_QUADS);
		//lower left
		glTexCoord2f(0, 0);
		glVertex2i(-1,-1);
		//upper left
		glTexCoord2f(0, 1.0f);
		glVertex2i(-1,1);
		//upper right
		glTexCoord2f(1.0f, 1.0f);
		glVertex2i(1,1);
		//lower right
		glTexCoord2f(1.0f, 0);
		glVertex2i(1,-1);
	glEnd();
    
	return FF_SUCCESS;
}

DWORD FFGLStroboscopeEffect::GetParameter(DWORD dwIndex)
{
	DWORD dwRet;

	switch (dwIndex) {
		case FFPARAM_Frequency:
			*((float *)&dwRet) = m_Frequency;
			return dwRet;			
		case FFPARAM_Hue1:
			*((float *)&dwRet) = m_HSBA[0][0];
			return dwRet;			
		case FFPARAM_Saturation1:
			*((float *)&dwRet) = m_HSBA[0][1];
			return dwRet;
		case FFPARAM_Brightness1:
			*((float *)&dwRet) = m_HSBA[0][2];
			return dwRet;
		case FFPARAM_Alpha1:
			*((float *)&dwRet) = m_HSBA[0][3];
			return dwRet;
		default:
			return FF_FAIL;
	}
}

DWORD FFGLStroboscopeEffect::SetParameter(const SetParameterStruct* pParam)
{
	if (pParam != NULL) {
		float value = *((float *)&(pParam->NewParameterValue));
		switch (pParam->ParameterNumber) {
			case FFPARAM_Frequency:
				m_Frequency = value;
				m_iFrequency = 1.0f - m_Frequency;
				if (m_iFrequency <= 0.04f) 
					m_iFrequency = 0.04f;	//frequency range of [1..25]Hz
				break;				
			case FFPARAM_Hue1:
	//we need to make sure the hue doesn't reach 1.0f, otherwise the result will be pink and not red how it should be
				m_HSBA[0][0] = (value > 0.99) ? 0.99 : value;
				break;
			case FFPARAM_Saturation1:
				m_HSBA[0][1] = value;
				break;
			case FFPARAM_Brightness1:
				m_HSBA[0][2] = value;
				break;
			case FFPARAM_Alpha1:
				m_HSBA[0][3] = value;
				break;
			default:
				return FF_FAIL;
		}
		return FF_SUCCESS;
	}
	return FF_FAIL;
}


char* FFGLStroboscopeEffect::GetParameterDisplay(DWORD dwIndex) 
{	
	memset(m_DisplayValue, 0, 15);
	
	switch (dwIndex) {
		case FFPARAM_Frequency:
		{
			//m_Frequency is guaranteed to be non-zero by SetParameter
			sprintf(m_DisplayValue, "%.1f %s", (1.0f/m_iFrequency), "Hz");
			return m_DisplayValue;
		}
		case FFPARAM_Hue1:
		case FFPARAM_Saturation1:
		case FFPARAM_Brightness1:
		case FFPARAM_Alpha1:
		{
			float value = m_HSBA[0][dwIndex - 1];
			sprintf(m_DisplayValue, "%.1f", value );
			return m_DisplayValue;
		}
		default:
			return m_DisplayValue;
	}
	
	return NULL;
}