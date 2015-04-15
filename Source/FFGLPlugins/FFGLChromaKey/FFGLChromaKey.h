#ifndef FFGLChromaKey_H
#define FFGLChromaKey_H

#include <FFGLShader.h>
#include "../FFGLPluginSDK.h"

class FFGLChromaKey :
public CFreeFrameGLPlugin
{
public:
	FFGLChromaKey();
  virtual ~FFGLChromaKey() {}

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
  	*ppOutInstance = new FFGLChromaKey();
	  if (*ppOutInstance != NULL)
      return FF_SUCCESS;
	  return FF_FAIL;
  }

protected:	
	// Parameters
	float m_tolerance;
	float m_feather;
	float m_key[3];
	float m_key_rgb[3];	
	bool m_linear;
	float m_linearvalue;
	float m_ramp;

	int m_initResources;
	FFGLExtensions m_extensions;
    FFGLShader m_shader;
	GLint m_kernellocation;
	GLint m_tcoffsetlocation;
	GLint m_featherlocation;
	GLint m_tolerancelocation;
	GLint m_keylocation;
	GLint m_linearlocation;
	GLint m_ramplocation;
	char m_Displayvalue[15];	//buffer for parameter display value
};

#endif
