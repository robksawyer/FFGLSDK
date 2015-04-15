#ifndef FFGLPolarCoordinates_H
#define FFGLPolarCoordinates_H

#include <FFGLShader.h>
#include "../FFGLPluginSDK.h"

class FFGLPolarCoordinates :
public CFreeFrameGLPlugin
{
public:
	FFGLPolarCoordinates();
  virtual ~FFGLPolarCoordinates() {}

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
  	*ppOutInstance = new FFGLPolarCoordinates();
	  if (*ppOutInstance != NULL)
      return FF_SUCCESS;
	  return FF_FAIL;
  }

protected:	
	// Parameters
	bool m_cartesiantopolar;
	float m_cartesiantopolar_value;
	float m_amount;

	int m_initResources;
	FFGLExtensions m_extensions;
    FFGLShader m_shader;
	GLint m_amountlocation;
	char m_Displayvalue[15];	//buffer for parameter display value
};


#endif
