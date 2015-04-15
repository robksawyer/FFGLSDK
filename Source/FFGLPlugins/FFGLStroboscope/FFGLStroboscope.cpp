#include <FFGL.h>
#include <FFGLLib.h>
#include <stdio.h>
#include "FFGLStroboscope.h"
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
#define FFPARAM_Hue2		(5)
#define FFPARAM_Saturation2	(6)
#define FFPARAM_Brightness2	(7)
#define FFPARAM_Alpha2		(8)

bool hastime = false;	//workaround for hosts without Time support

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Plugin information
////////////////////////////////////////////////////////////////////////////////////////////////////

static CFFGLPluginInfo PluginInfo ( 
	FFGLStroboscope::CreateInstance,	// Create method
	"MSTR",								// Plugin unique ID											
	"Stroboscope",					// Plugin name											
	1,						   			// API major version number 													
	000,								  // API minor version number	
	1,										// Plugin major version number
	000,									// Plugin minor version number
	FF_SOURCE,						// Plugin type
	"Stroboscope source",	// Plugin description
	"by Matias Wilkman" // About
);

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Constructor and destructor
////////////////////////////////////////////////////////////////////////////////////////////////////

FFGLStroboscope::FFGLStroboscope()
:CFreeFrameGLPlugin(),
 m_initResources(1)
{
	// Input properties
	SetMinInputs(0);
	SetMaxInputs(0);
	SetTimeSupported(true);

	init_time(&t0);
	// Parameters
	SetParamInfo(FFPARAM_Frequency, "Frequency", FF_TYPE_STANDARD, 0.5f);
	m_Frequency = 0.5f;
	m_iFrequency = 1.0f - m_Frequency;
	m_lasttime = 0.0f;
	m_swap = false;

	SetParamInfo(FFPARAM_Hue1, "Hue 1", FF_TYPE_STANDARD, 0.0f);	//Frame one color - default is white
	m_HSBA[0][0] = 0.0f;
	SetParamInfo(FFPARAM_Saturation1, "Saturation 1", FF_TYPE_STANDARD, 0.0f);
	m_HSBA[0][1] = 0.0f;
	SetParamInfo(FFPARAM_Brightness1, "Brightness 1", FF_TYPE_STANDARD, 1.0f);
	m_HSBA[0][2] = 1.0f;
	SetParamInfo(FFPARAM_Alpha1, "Alpha 1", FF_TYPE_STANDARD, 1.0f);
	m_HSBA[0][3] = 1.0f;

	SetParamInfo(FFPARAM_Hue2, "Hue 2", FF_TYPE_STANDARD, 0.0f);	//Frame two color - default is black
	m_HSBA[1][0] = 0.0f;
	SetParamInfo(FFPARAM_Saturation2, "Saturation 2", FF_TYPE_STANDARD, 0.0f);
	m_HSBA[1][1] = 0.0f;
	SetParamInfo(FFPARAM_Brightness2, "Brightness 2", FF_TYPE_STANDARD, 0.0f);
	m_HSBA[1][2] = 0.0f;
	SetParamInfo(FFPARAM_Alpha2, "Alpha 2", FF_TYPE_STANDARD, 1.0f);
	m_HSBA[1][3] = 1.0f;

}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Methods
////////////////////////////////////////////////////////////////////////////////////////////////////

DWORD FFGLStroboscope::InitGL(const FFGLViewportStruct *vp)
{
	return FF_SUCCESS;
}

DWORD FFGLStroboscope::DeInitGL()
{
	return FF_SUCCESS;
}

DWORD FFGLStroboscope::SetTime(double time)
{
	m_time = time;
	hastime = true;
	return FF_SUCCESS;
}

DWORD FFGLStroboscope::ProcessOpenGL(ProcessOpenGLStruct *pGL)
{
	// If no calls to SetTime have been made, the host probably
	// doesn't support Time, so we'll update m_time manually
	if (!hastime)	
	{
		update_time(&m_time, t0);
	}

	float rgba1[4]; 
	float rgba2[4];
	HSVtoRGB(m_HSBA[0][0], m_HSBA[0][1], m_HSBA[0][2], &(rgba1[0]), &(rgba1[1]), &(rgba1[2]));
	HSVtoRGB(m_HSBA[1][0], m_HSBA[1][1], m_HSBA[1][2], &(rgba2[0]), &(rgba2[1]), &(rgba2[2]));
	rgba1[3] = m_HSBA[0][3];	//alpha
	rgba2[3] = m_HSBA[1][3];

	if (m_time >= m_lasttime + m_iFrequency)
	{
		m_lasttime = m_time;
		m_swap = !m_swap;
	}
	if (m_swap)
		glColor4fv(rgba1);
	else
		glColor4fv(rgba2);
	glBegin(GL_QUADS);
		glVertex2i(-1,-1); 	//lower left
		glVertex2i(-1,1);	//upper left
		glVertex2i(1,1);	//upper right
		glVertex2i(1,-1);	//lower right
	glEnd();
    
	return FF_SUCCESS;
}

DWORD FFGLStroboscope::GetParameter(DWORD dwIndex)
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
		case FFPARAM_Hue2:
			*((float *)&dwRet) = m_HSBA[1][0];
			return dwRet;			
		case FFPARAM_Saturation2:
			*((float *)&dwRet) = m_HSBA[1][1];
			return dwRet;
		case FFPARAM_Brightness2:
			*((float *)&dwRet) = m_HSBA[1][2];
			return dwRet;
		case FFPARAM_Alpha2:
			*((float *)&dwRet) = m_HSBA[1][3];
			return dwRet;
		default:
			return FF_FAIL;
	}
}

DWORD FFGLStroboscope::SetParameter(const SetParameterStruct* pParam)
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
			case FFPARAM_Hue2:
	//we need to make sure the hue doesn't reach 1.0f, otherwise the result will be pink and not red how it should be
				m_HSBA[1][0] = (value > 0.99) ? 0.99 : value;
				break;
			case FFPARAM_Saturation2:
				m_HSBA[1][1] = value;
				break;
			case FFPARAM_Brightness2:
				m_HSBA[1][2] = value;
				break;
			case FFPARAM_Alpha2:
				m_HSBA[1][3] = value;
				break;
			default:
				return FF_FAIL;
		}
		return FF_SUCCESS;
	}
	return FF_FAIL;
}


char* FFGLStroboscope::GetParameterDisplay(DWORD dwIndex) 
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
			sprintf(m_DisplayValue, "%f", value );
			return m_DisplayValue;
		}
		case FFPARAM_Hue2:
		case FFPARAM_Saturation2:
		case FFPARAM_Brightness2:
		case FFPARAM_Alpha2:
		{
			float value = m_HSBA[1][dwIndex - 4 - 1];
			sprintf(m_DisplayValue, "%f", value );
			return m_DisplayValue;
		}
		default:
			return m_DisplayValue;
	}
	
	return NULL;
}