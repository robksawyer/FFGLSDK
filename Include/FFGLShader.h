#ifndef FFGLShader_H
#define FFGLShader_H

#include <FFGL.h>
#include <FFGLExtensions.h>

class FFGLShader
{
public:
  FFGLShader();
  virtual ~FFGLShader();

  void SetExtensions(FFGLExtensions *e);
  
  int IsReady() { return (m_glProgram!=0 && m_glVertexShader!=0 && m_glFragmentShader!=0 && m_linkStatus==1); }
  
  int Compile(const char *vtxProgram, const char *fragProgram);

  GLuint FindUniform(const char *name);
  
  int BindShader();
  int UnbindShader();

  void FreeGLResources();

private:
  FFGLExtensions *m_extensions;
#ifdef __APPLE__
    void * m_glProgram;
    void * m_glVertexShader;
    void * m_glFragmentShader;
    GLuint m_linkStatus;
#else
    GLenum m_glProgram;
    GLenum m_glVertexShader;
    GLenum m_glFragmentShader;
    GLuint m_linkStatus;
#endif
  
  void CreateGLResources();
};

#endif
