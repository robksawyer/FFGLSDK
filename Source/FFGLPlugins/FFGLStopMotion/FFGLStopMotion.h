#ifndef FFGLStopMotion_H
#define FFGLStopMotion_H

#include "../FFGLPluginSDK.h"

#define MINSAMPLESIZE		0.01f
#define MAXSAMPLESIZE		0.1f
#define MAXAMOUNT			12

class FFGLStopMotion :
public CFreeFrameGLPlugin
{
public:
	FFGLStopMotion();
	~FFGLStopMotion() {}

	///////////////////////////////////////////////////
	// FreeFrame plugin methods
	///////////////////////////////////////////////////
	
	DWORD	SetParameter(const SetParameterStruct* pParam);		
	DWORD	GetParameter(DWORD dwIndex);
	char*	GetParameterDisplay(DWORD dwIndex);
	DWORD	ProcessOpenGL(ProcessOpenGLStruct* pGL);
	DWORD	InitGL(const FFGLViewportStruct *vp);
	DWORD	DeInitGL();
	DWORD	SetTime(double time);

	///////////////////////////////////////////////////
	// Factory method
	///////////////////////////////////////////////////
	static DWORD __stdcall CreateInstance(CFreeFrameGLPlugin **ppOutInstance)
  {
  	*ppOutInstance = new FFGLStopMotion();
	  if (*ppOutInstance != NULL)
      return FF_SUCCESS;
	  return FF_FAIL;
  }


protected:	
	// Parameters
	float m_Frequency;
	float m_iFrequency;
	float m_frames;
	int m_framecount;

	FFGLViewportStruct orig_vp;
	double t0;
	double m_time;
	double m_lasttime;
	unsigned int texsize;
	GLubyte *texture;
	GLuint m_tid;
	bool m_swap;
	int m_initResources;
	char m_DisplayValue[15];	//buffer for parameter display value
};


#endif
