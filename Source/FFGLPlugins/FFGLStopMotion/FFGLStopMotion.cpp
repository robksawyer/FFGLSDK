#include <FFGL.h>
#include <FFGLLib.h>
#include <cstdio>
#include <cmath>
#include <algorithm>
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

#include "FFGLStopMotion.h"
#include "utilities.h"

#define FFPARAM_Frequency	(0)
#define FFPARAM_Frames		(1)

#define		MAX_FRAMES	50

bool hastime = false;	//workaround for hosts without Time support

using namespace std;

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Plugin information
////////////////////////////////////////////////////////////////////////////////////////////////////

static CFFGLPluginInfo PluginInfo ( 
	FFGLStopMotion::CreateInstance,	// Create method
	"MSTP",								// Plugin unique ID											
	"Stop Motion",					// Plugin name											
	1,						   			// API major version number 													
	000,								  // API minor version number	
	1,										// Plugin major version number
	000,									// Plugin minor version number
	FF_EFFECT,						// Plugin type
	"Stop Motion effect",	// Plugin description
	"by Matias Wilkman" // About
);

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Constructor and destructor
////////////////////////////////////////////////////////////////////////////////////////////////////

FFGLStopMotion::FFGLStopMotion()
:CFreeFrameGLPlugin(),
 m_initResources(1)
{
	// Input properties
	SetMinInputs(1);
	SetMaxInputs(1);
	SetTimeSupported(true);

	init_time(&t0);
	m_lasttime = 0.0f;
	m_swap = true;
	texture = NULL;

	// Parameters
	SetParamInfo(FFPARAM_Frequency, "Frequency", FF_TYPE_STANDARD, 0.5f);
	m_Frequency = 0.5f;
	m_iFrequency = 1.0f - m_Frequency;
	SetParamInfo(FFPARAM_Frames, "Frame Count", FF_TYPE_STANDARD, 0.0f);
	m_frames = 0.0;
	m_framecount = 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Methods
////////////////////////////////////////////////////////////////////////////////////////////////////

DWORD FFGLStopMotion::InitGL(const FFGLViewportStruct *vp)
{
	glEnable(GL_TEXTURE_2D);
	glGenTextures(1, &m_tid);
	glBindTexture(GL_TEXTURE_2D, m_tid);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	orig_vp = *vp;
	return FF_SUCCESS;
}

DWORD FFGLStopMotion::DeInitGL()
{
	delete []texture;
	return FF_SUCCESS;
}

DWORD FFGLStopMotion::SetTime(double time)
{
	m_time = time;
	hastime = true;
	return FF_SUCCESS;
}

DWORD FFGLStopMotion::ProcessOpenGL(ProcessOpenGLStruct *pGL)
{
	if (pGL->numInputTextures<1) return FF_FAIL;
	if (pGL->inputTextures[0]==NULL) return FF_FAIL;

	FFGLTextureStruct &Texture = *(pGL->inputTextures[0]);
	FFGLTexCoords maxCoords = GetMaxGLTexCoords(Texture);
	glEnable(GL_TEXTURE_2D);

	glBindTexture(GL_TEXTURE_2D, m_tid);
	//initialize to nearest higher POT size
	if (texture == NULL)
	{
		GLint maxSize;
		glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxSize);
		//log2(x) = ln(x)/ln(2)
		double exp = ceil(log((double)max(Texture.HardwareHeight, Texture.HardwareWidth))/log(2.0));
		texsize = min(pow(2, exp), (double)maxSize);
		texture = new GLubyte[4*texsize*texsize*sizeof(GLubyte)];	//RGB * x * y
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texsize, texsize, 0, GL_RGBA,
	       GL_UNSIGNED_BYTE, texture);
	}

	// If no calls to SetTime have been made, the host probably
	// doesn't support Time, so we'll update m_time manually
	if (!hastime)	
	{
		update_time(&m_time, t0);	
	}

	if (m_time >= m_lasttime + m_iFrequency && m_swap == false)
	{
		m_lasttime = m_time;
		m_framecount = 0;
		m_swap = true;
	}
	if (m_swap)
	{
		//define a viewport adapted to the texture 
		glViewport(0, 0, texsize, texsize);

		//draw the original frame 1:1 into the (larger) texture
		float ymax = min(2.0f*((float)Texture.HardwareHeight/(float)texsize) - 1.0f, 1.0f);	//clamping is for cards with
		float xmax = min(2.0f*((float)Texture.HardwareWidth/(float)texsize) - 1.0f, 1.0f);	//smaller max hardware texture than the current frame size
		glBindTexture(GL_TEXTURE_2D, Texture.Handle);
		//original
		glBegin(GL_QUADS);
			//lower left
			glTexCoord2f(0, 0);
			glVertex2f(-1.0, -1.0);
			//upper left
			glTexCoord2f(0, maxCoords.t);
			glVertex2f(-1.0, ymax);
			//upper right
			glTexCoord2f(maxCoords.s, maxCoords.t);
			glVertex2f(xmax, ymax);
			//lower right
			glTexCoord2f(maxCoords.s, 0);
			glVertex2f(xmax, -1.0);
		glEnd();
		glBindTexture(GL_TEXTURE_2D, m_tid);
		//copy buffer to texture
		glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, texsize, texsize, 0);
		//restore original viewport
		glViewport(orig_vp.x, orig_vp.y, orig_vp.width, orig_vp.height);
		m_framecount++;
		if (m_framecount >= (int)(m_frames*MAX_FRAMES) + 1)	//let frames pass through for the specified amount of time
		{
			m_swap = false;
			m_lasttime = m_time;
		}
	}

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);

	//sample only the area that was previously written
	float x1 = min(((float)Texture.HardwareWidth/(float)texsize), 1.0f);	//don't sample out of bounds
	float y1 = min(((float)Texture.HardwareHeight/(float)texsize), 1.0f);
	glBindTexture(GL_TEXTURE_2D, m_tid);
	glBegin(GL_QUADS);
		//lower left
		glTexCoord2f(0, 0);
		glVertex2i(-1,-1);
		//upper left
		glTexCoord2f(0, y1);
		glVertex2i(-1,1);
		//upper right
		glTexCoord2f(x1, y1);
		glVertex2i(1,1);
		//lower right
		glTexCoord2f(x1, 0);
		glVertex2i(1,-1);
	glEnd();

	return FF_SUCCESS;
}

DWORD FFGLStopMotion::GetParameter(DWORD dwIndex)
{
	DWORD dwRet;

	switch (dwIndex) {
		case FFPARAM_Frequency:
			*((float *)&dwRet) = m_Frequency;
			return dwRet;		
		case FFPARAM_Frames:
			*((float *)&dwRet) = m_frames;
			return dwRet;		
		default:
			return FF_FAIL;
	}
}

DWORD FFGLStopMotion::SetParameter(const SetParameterStruct* pParam)
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
			case FFPARAM_Frames:
				m_frames = value;
				break;
			default:
				return FF_FAIL;
		}
		return FF_SUCCESS;
	}
	return FF_FAIL;
}


char* FFGLStopMotion::GetParameterDisplay(DWORD dwIndex) 
{	
	memset(m_DisplayValue, 0, 15);
	
	switch (dwIndex) {
		case FFPARAM_Frequency:
		{
			//m_Frequency is guaranteed to be non-zero by SetParameter
			sprintf(m_DisplayValue, "%.1f %s", (1.0f/m_iFrequency), "Hz");
			return m_DisplayValue;
		}
		case FFPARAM_Frames:
		{
			sprintf(m_DisplayValue, "%d", ((int)(m_frames*MAX_FRAMES) + 1));
			return m_DisplayValue;
		}
		default:
			return m_DisplayValue;
	}
	return NULL;
}