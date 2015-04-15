#ifndef FFGLStatic_H
#define FFGLStatic_H

#include <FFGLShader.h>
#include "../FFGLPluginSDK.h"

class FFGLStatic :
public CFreeFrameGLPlugin
{
public:
	FFGLStatic();
  virtual ~FFGLStatic() {}

	///////////////////////////////////////////////////
	// FreeFrameGL plugin methods
	///////////////////////////////////////////////////
	
	DWORD ProcessOpenGL(ProcessOpenGLStruct* pGL);
	DWORD InitGL(const FFGLViewportStruct *vp);
	DWORD DeInitGL();
	DWORD SetTime(double time);
	DWORD SetParameter(const SetParameterStruct* pParam);
	DWORD GetParameter(DWORD dwIndex);
	char* GetParameterDisplay(DWORD dwIndex);

	///////////////////////////////////////////////////
	// Factory method
	///////////////////////////////////////////////////

	static DWORD __stdcall CreateInstance(CFreeFrameGLPlugin **ppOutInstance)
  {
  	*ppOutInstance = new FFGLStatic();
	  if (*ppOutInstance != NULL)
      return FF_SUCCESS;
	  return FF_FAIL;
  }

protected:	
	// Parameters
	float m_mode;

	int m_initResources;
	double m_time;
	double t0;
	FFGLExtensions m_extensions;
    FFGLShader m_shader;
	GLint m_timeLocation;
	GLint m_grayscaleLocation;
	GLint m_twotoneLocation;
	char m_Displayvalue[15];	//buffer for parameter display value
};


#endif
