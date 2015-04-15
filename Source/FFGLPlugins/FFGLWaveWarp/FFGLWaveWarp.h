#ifndef FFGLWaveWarp_H
#define FFGLWaveWarp_H

#include <FFGLShader.h>
#include "../FFGLPluginSDK.h"

#define	NUM_MODES	5
#define	MAX_SPEED	25.0

class FFGLWaveWarp :
public CFreeFrameGLPlugin
{
public:
	FFGLWaveWarp();
  virtual ~FFGLWaveWarp() {}

	///////////////////////////////////////////////////
	// FreeFrameGL plugin methods
	///////////////////////////////////////////////////
	
	DWORD ProcessOpenGL(ProcessOpenGLStruct* pGL);
	DWORD InitGL(const FFGLViewportStruct *vp);
	DWORD DeInitGL();
	DWORD SetParameter(const SetParameterStruct* pParam);
	DWORD GetParameter(DWORD dwIndex);
	char* GetParameterDisplay(DWORD dwIndex);
	DWORD SetTime(double time);

	///////////////////////////////////////////////////
	// Factory method
	///////////////////////////////////////////////////

	static DWORD __stdcall CreateInstance(CFreeFrameGLPlugin **ppOutInstance)
  {
  	*ppOutInstance = new FFGLWaveWarp();
	  if (*ppOutInstance != NULL)
      return FF_SUCCESS;
	  return FF_FAIL;
  }

protected:	
	// Parameters
	float m_mode;
	float m_height;
	float m_width;
	float m_angle;
	float m_cosa;
	float m_sina;
	float m_speed;
	float m_pinning_val;
	bool m_pinning;

	float currentshader;
	int m_initResources;
	FFGLExtensions m_extensions;
    FFGLShader m_shader;
	GLint m_cosalocation;
	GLint m_sinalocation;
	GLint m_widthlocation;
	GLint m_heightlocation;
	GLint m_timelocation;
	GLint m_pinninglocation;
	double t0;
	double m_time;
	char* m_modenames[NUM_MODES];
	char m_Displayvalue[15];	//buffer for parameter display value
};


#endif
