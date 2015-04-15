#ifndef FFGLColorWrapMixer_H
#define FFGLColorWrapMixer_H

#include <FFGLShader.h>
#include "../FFGLPluginSDK.h"

class FFGLColorWrapMixer :
public CFreeFrameGLPlugin
{
public:
	FFGLColorWrapMixer();
  virtual ~FFGLColorWrapMixer() {}

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
  	*ppOutInstance = new FFGLColorWrapMixer();
	  if (*ppOutInstance != NULL)
      return FF_SUCCESS;
	  return FF_FAIL;
  }

protected:	
	// Parameters
	float m_blend;

	int m_initResources;
	FFGLExtensions m_extensions;
    FFGLShader m_shader;
	GLint m_sampler0location;
	GLint m_blendlocation;
	GLint m_sampler1location;
	char m_Displayvalue[15];	//buffer for parameter display value
};


#endif
