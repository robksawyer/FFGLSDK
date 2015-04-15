#ifndef FFGLBarshift_H
#define FFGLBarshift_H

#include "../FFGLPluginSDK.h"

#define MINSAMPLESIZE		0.01f
#define MAXSAMPLESIZE		0.1f
#define MAXAMOUNT			12

class FFGLBarshift :
public CFreeFrameGLPlugin
{
public:
	FFGLBarshift();
	~FFGLBarshift() {}

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
  	*ppOutInstance = new FFGLBarshift();
	  if (*ppOutInstance != NULL)
      return FF_SUCCESS;
	  return FF_FAIL;
  }


protected:	
	// Parameters
	float m_Frequency;
	float m_iFrequency;
	float m_Hamount;
	float m_Vamount;

	int m_h;	//actual v & h counts
	int m_v;
	double t0;
	double m_time;
	double m_lasttime;
	float m_vpos[MAXAMOUNT];	//draw positions
	float m_hpos[MAXAMOUNT];
	float m_vsize[MAXAMOUNT];	//draw sizes
	float m_hsize[MAXAMOUNT];
	float m_vsamplepos[MAXAMOUNT];	//sample positions
	float m_hsamplepos[MAXAMOUNT];
	float m_vsamplesize[MAXAMOUNT];	//sample sizes
	float m_hsamplesize[MAXAMOUNT];
	float maxsize;
	bool m_swap;
	int m_initResources;
	char m_DisplayValue[15];	//buffer for parameter display value
};


#endif
