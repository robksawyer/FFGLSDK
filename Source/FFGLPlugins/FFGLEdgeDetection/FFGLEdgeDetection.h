#ifndef FFGLEdgeDetection_H
#define FFGLEdgeDetection_H

#include <FFGLShader.h>
#include "../FFGLPluginSDK.h"

class FFGLEdgeDetection :
public CFreeFrameGLPlugin
{
public:
	FFGLEdgeDetection();
  virtual ~FFGLEdgeDetection() {}

	///////////////////////////////////////////////////
	// FreeFrameGL plugin methods
	///////////////////////////////////////////////////
	
	DWORD ProcessOpenGL(ProcessOpenGLStruct* pGL);
	DWORD InitGL(const FFGLViewportStruct *vp);
	DWORD DeInitGL();
	DWORD SetParameter(const SetParameterStruct* pParam);
	DWORD GetParameter(DWORD dwIndex);
	char* GetParameterDisplay(DWORD dwIndex);

	///////////////////////////////////////////////////
	// Factory method
	///////////////////////////////////////////////////

	static DWORD __stdcall CreateInstance(CFreeFrameGLPlugin **ppOutInstance)
  {
  	*ppOutInstance = new FFGLEdgeDetection();
	  if (*ppOutInstance != NULL)
      return FF_SUCCESS;
	  return FF_FAIL;
  }

protected:	
	// Parameters
	float m_mode;
	float m_mult;

	float currentshader;
	int m_initResources;
	FFGLExtensions m_extensions;
    FFGLShader m_shader;
	GLint m_tcoffsetlocation;
	GLint m_multlocation;
	char m_Displayvalue[15];	//buffer for parameter display value
};


#endif
