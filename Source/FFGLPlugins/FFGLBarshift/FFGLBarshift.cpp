#ifdef _WIN32
#include "../common/opengl/include/glut.h"
#define NOMINMAX
#include <windows.h>
#else	//all other platforms
#include <OpenGL/glu.h>
#include <sys/time.h>
#endif
#ifdef __APPLE__	//OS X
#include <TargetConditionals.h>
#endif
#include <FFGL.h>
#include <FFGLLib.h>
#include <stdio.h>
#include <cstdlib>
#include <cmath>
#include <algorithm>

#include "FFGLBarshift.h"
#include "utilities.h"

#define FFPARAM_Frequency	(0)
#define FFPARAM_Vertical	(1)
#define FFPARAM_Horizontal	(2)
#define FFPARAM_Size		(3)

using namespace std;

bool hastime = false;	//workaround for hosts without Time support

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Plugin information
////////////////////////////////////////////////////////////////////////////////////////////////////

static CFFGLPluginInfo PluginInfo ( 
	FFGLBarshift::CreateInstance,	// Create method
	"MBSH",								// Plugin unique ID											
	"Shift Glitch",					// Plugin name											
	1,						   			// API major version number 													
	000,								  // API minor version number	
	1,										// Plugin major version number
	000,									// Plugin minor version number
	FF_EFFECT,						// Plugin type
	"Shift Glitch effect",	// Plugin description
	"by Matias Wilkman" // About
);

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Constructor and destructor
////////////////////////////////////////////////////////////////////////////////////////////////////

FFGLBarshift::FFGLBarshift()
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
	m_lasttime = 0.0f;
	m_swap = true;
	// Parameters
	SetParamInfo(FFPARAM_Frequency, "Frequency", FF_TYPE_STANDARD, 1.0f);
	m_Frequency = 1.0f;
	m_iFrequency = 1.0f - m_Frequency;

	//Amount of bars that span the y axis
	SetParamInfo(FFPARAM_Vertical, "Vertical", FF_TYPE_STANDARD, 0.0f);	
	m_Vamount = 0.0f;
	m_v = m_Vamount * MAXAMOUNT;

	//Amount of bars that span the x axis
	SetParamInfo(FFPARAM_Horizontal, "Horizontal", FF_TYPE_STANDARD, 0.5f);
	m_Hamount = 0.5f;
	m_h = m_Hamount * MAXAMOUNT;
	
	//maximum size size of bars
	SetParamInfo(FFPARAM_Size, "Size", FF_TYPE_STANDARD, 0.5f);
	maxsize = 0.5f;
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Methods
////////////////////////////////////////////////////////////////////////////////////////////////////

DWORD FFGLBarshift::InitGL(const FFGLViewportStruct *vp)
{
	return FF_SUCCESS;
}

DWORD FFGLBarshift::DeInitGL()
{
	return FF_SUCCESS;
}

DWORD FFGLBarshift::SetTime(double time)
{
	m_time = time;
	hastime = true;
	return FF_SUCCESS;
}

DWORD FFGLBarshift::ProcessOpenGL(ProcessOpenGLStruct *pGL)
{
	// If no calls to SetTime have been made, the host probably
	// doesn't support Time, so we'll update m_time manually
	if (!hastime)	
	{
		update_time(&m_time, t0);	
	}
	if (pGL->numInputTextures<1) return FF_FAIL;
	if (pGL->inputTextures[0]==NULL) return FF_FAIL;

	FFGLTextureStruct &Texture = *(pGL->inputTextures[0]);
	glBindTexture(GL_TEXTURE_2D, Texture.Handle);
	glEnable(GL_TEXTURE_2D);
	//get the max s,t that correspond to the 
	//width,height of the used portion of the allocated texture space
	FFGLTexCoords maxCoords = GetMaxGLTexCoords(Texture);
	glMatrixMode(GL_TEXTURE);
	glPushMatrix();
	glLoadIdentity(); 
	glScalef(maxCoords.s, maxCoords.t, 1.0); 
	glMatrixMode(GL_MODELVIEW);
	
	//Store current texture parameters:
	GLint minfilter, maxfilter, wraps, wrapt;
	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, &minfilter);
	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, &maxfilter);
	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, &wraps);
	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, &wrapt);
	
	//Set minification, magnification & wrap modes:
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);


	if (m_time >= m_lasttime + m_iFrequency)
	{
		m_lasttime = m_time;
		m_swap = true;
	}
	if (m_swap)
	{
	// randomize shift positions
		//vertical
		for (int i = 0; i < MAXAMOUNT; i++)
		{
			//draw position:
			m_vpos[i] = (float(rand()%100)/100.0f)*2.0f - 1.0f;	//height = 2.0f
			//draw size:
			m_vsize[i] = (float(rand()%100)/100.0f)*maxsize;
			//sample position:
			m_vsamplepos[i] = (float(rand()%100)/100.0f)*1.0f; 
			//sample size:
			m_vsamplesize[i] = (MINSAMPLESIZE + (float(rand()%100)/100.0f)*(MAXSAMPLESIZE-MINSAMPLESIZE))*1.0f;	
			m_vsamplepos[i] = min(m_vsamplepos[i], (float)(1.0f - m_vsamplesize[i]));	//protect from sampling over the border
		}
		//horizontal
		for (int i = 0; i < MAXAMOUNT; i++)
		{
			//draw position:
			m_hpos[i] = (float(rand()%100)/100.0f)*2.0f - 1.0f;	//height = 2.0f
			//draw size:
			m_hsize[i] = (float(rand()%100)/100.0f)*maxsize;
			//sample position:
			m_hsamplepos[i] = (float(rand()%100)/100.0f)*1.0f; 
			//sample size:
			m_hsamplesize[i] = (MINSAMPLESIZE + (float(rand()%100)/100.0f)*(MAXSAMPLESIZE-MINSAMPLESIZE))*1.0f;	
			m_hsamplepos[i] = min(m_hsamplepos[i], (float)(1.0f - m_hsamplesize[i]));	//protect from sampling over the border
		}
		m_swap = false;
	}
	//original
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

	glBegin(GL_QUADS);
		//hshifts
		float	y_0, y_1,
				vy_0, vy_1,
				vx_0, vx_1,
				x_0, x_1;
		int i = 0;
		for (i = 0; i < m_h; i++)
		{
			y_0 = m_hpos[i];
			y_1 = y_0 + m_hsize[i];
			vy_0 = m_hsamplepos[i];
			vy_1 = vy_0 + m_hsamplesize[i];
			//lower left
			glTexCoord2f(0, vy_0);
			glVertex2f(-1, y_0);
			//upper left
			glTexCoord2f(0, vy_1);
			glVertex2f(-1, y_1);
			//upper right
			glTexCoord2f(1.0f, vy_1);
			glVertex2f(1, y_1);
			//lower right
			glTexCoord2f(1.0f, vy_0);
			glVertex2f(1, y_0);
			//vshift
			if (i < m_v)
			{
				x_0 = m_vpos[i];
				x_1 = x_0 + m_vsize[i];
				vx_0 = m_vsamplepos[i];
				vx_1 = vx_0 + m_vsamplesize[i];
				//lower left
				glTexCoord2f(vx_0, 0.0);
				glVertex2f(x_0, -1.0);
				//upper left
				glTexCoord2f(vx_0, 1.0);
				glVertex2f(x_0, 1.0);
				//upper right
				glTexCoord2f(vx_1, 1.0f);
				glVertex2f(x_1, 1.0);
				//lower right
				glTexCoord2f(vx_1, 0.0);
				glVertex2f(x_1, -1.0);
			}
		}
		//remaining vshifts
		while (i < m_v)
		{
			x_0 = m_vpos[i];
			x_1 = x_0 + m_vsize[i];
			vx_0 = m_vsamplepos[i];
			vx_1 = vx_0 + m_vsamplesize[i];
			//lower left
			glTexCoord2f(vx_0, 0.0);
			glVertex2f(x_0, -1.0);
			//upper left
			glTexCoord2f(vx_0, 1.0f);
			glVertex2f(x_0, 1.0);
			//upper right
			glTexCoord2f(vx_1, 1.0f);
			glVertex2f(x_1, 1.0);
			//lower right
			glTexCoord2f(vx_1, 0.0);
			glVertex2f(x_1, -1.0);
			i++;
		}
	glEnd();

	//Restore old texture parameters:
	glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, &minfilter);
	glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, &maxfilter);
	glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, &wraps);
	glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, &wrapt);

	glMatrixMode(GL_TEXTURE);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	return FF_SUCCESS;
}

DWORD FFGLBarshift::GetParameter(DWORD dwIndex)
{
	DWORD dwRet;

	switch (dwIndex) {
		case FFPARAM_Frequency:
			*((float *)&dwRet) = m_Frequency;
			return dwRet;			
		case FFPARAM_Horizontal:
			*((float *)&dwRet) = m_Hamount;
			return dwRet;			
		case FFPARAM_Vertical:
			*((float *)&dwRet) = m_Vamount;
			return dwRet;
		case FFPARAM_Size:
			*((float *)&dwRet) = maxsize;
			return dwRet;			
		default:
			return FF_FAIL;
	}
}

DWORD FFGLBarshift::SetParameter(const SetParameterStruct* pParam)
{
	if (pParam != NULL) {
		float value = *((float *)&(pParam->NewParameterValue));
		switch (pParam->ParameterNumber) {
			case FFPARAM_Frequency:
				m_Frequency = value;
				m_iFrequency = 1.0f - m_Frequency;
				if (m_iFrequency <= 0.04f) 
					m_iFrequency = 0.04f;
				break;				
			case FFPARAM_Horizontal:
				m_Hamount = value;
				m_h = ceil(m_Hamount * MAXAMOUNT);
				break;
			case FFPARAM_Vertical:
				m_Vamount = value;
				m_v = ceil(m_Vamount * MAXAMOUNT);
				break;
			case FFPARAM_Size:
				maxsize = value;
				break;				
			default:
				return FF_FAIL;
		}
		return FF_SUCCESS;
	}
	return FF_FAIL;
}


char* FFGLBarshift::GetParameterDisplay(DWORD dwIndex) 
{	
	memset(m_DisplayValue, 0, 15);
	
	switch (dwIndex) {
		case FFPARAM_Frequency:
		{
			//m_Frequency is guaranteed to be non-zero by SetParameter
			sprintf(m_DisplayValue, "%.1f %s", (1.0f/m_iFrequency), "Hz");
			return m_DisplayValue;
		}
		case FFPARAM_Horizontal:
		{
			sprintf(m_DisplayValue, "%d", m_h);
			return m_DisplayValue;
		}
		case FFPARAM_Vertical:
		{
			sprintf(m_DisplayValue, "%d", m_v);
			return m_DisplayValue;
		}
		case FFPARAM_Size:
		{
			sprintf(m_DisplayValue, "%.1f", maxsize);
			return m_DisplayValue;
		}
		default:
			return m_DisplayValue;
	}
	return NULL;
}