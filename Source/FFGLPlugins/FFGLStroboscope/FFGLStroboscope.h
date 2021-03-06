#ifndef FFGLStroboscope_H
#define FFGLStroboscope_H

#include "../FFGLPluginSDK.h"

class FFGLStroboscope :
public CFreeFrameGLPlugin
{
public:
	FFGLStroboscope();
	~FFGLStroboscope() {}

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
  	*ppOutInstance = new FFGLStroboscope();
	  if (*ppOutInstance != NULL)
      return FF_SUCCESS;
	  return FF_FAIL;
  }


protected:	
	// Parameters
	float m_HSBA[2][4];
	float m_Frequency;
	float m_Distance;

	float m_iFrequency;
	double t0;
	double m_time;
	double m_lasttime;
	bool m_swap;
	int m_initResources;
	char m_DisplayValue[15];	//buffer for parameter display value
};


#endif
