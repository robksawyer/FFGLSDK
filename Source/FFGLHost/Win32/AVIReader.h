#ifndef AVIREADER_H
#define AVIREADER_H

#define WIN32_LEAN_AND_MEAN
#include <vfw.h>

class Win32AVIFile
{
public:
  Win32AVIFile()
  {
    m_aviFile = NULL;
    getFrame = NULL;
    streamVid = NULL;
    width = 0;
    height = 0;
    num_frames = 0;
    dwRate = 0;
    dwScale = 0;
  }

  int LoadAVI(const char *filename)
  {
    HRESULT res = AVIFileOpen(&m_aviFile, filename, OF_READ, NULL);
    if (res!=AVIERR_OK)
      return 0;

    res = AVIFileGetStream(m_aviFile, &streamVid, streamtypeVIDEO, 0);
    if (res!=AVIERR_OK)
    {
      AVIFileRelease(m_aviFile);
      m_aviFile = NULL;
      streamVid = NULL;
      return 0;
    }

    LONG format_length = 0;

    AVIStreamReadFormat(streamVid,
                        0, 
                        NULL,
                        &format_length);

    //if format_data is not a reasonable size, fail
    if (format_length>128)
      return 0;

    //make room for at least 128 bytes, sizeof(int) aligned
    int format_data[(128/sizeof(int)) + 1];

    AVIStreamReadFormat(streamVid,
                        0,
                        format_data,
                        &format_length);
        
    BITMAPINFOHEADER *bi = (BITMAPINFOHEADER *)format_data;

    //only 24 bit output is supported
    if (bi->biBitCount!=24)
      return 0;
    
    // Create the PGETFRAME
    getFrame = AVIStreamGetFrameOpen(streamVid,NULL);
	
    //unable to decode the .avi?
    if (getFrame==NULL)
    {
      OutputDebugString("AVIStreamGetFrameOpen returned NULL");
      return 0;
    }
        
    // Define the length of the video ( necessary for loop reading)
		// and its size.
		num_frames = AVIStreamLength(streamVid);
      
    if (num_frames<1)
      return 0;

    AVISTREAMINFO psi;
    AVIStreamInfo(streamVid, &psi, sizeof(AVISTREAMINFO));
		
    width  = psi.rcFrame.right - psi.rcFrame.left;
		height = psi.rcFrame.bottom - psi.rcFrame.top;
		
    dwRate = psi.dwRate;
    dwScale = psi.dwScale;

    return 1;
  }  

  int GetWidth() { return width; }

  int GetHeight() { return height; }
  
  double GetFramerate() { return (double)dwRate / (double)dwScale; }

  int GetNumFrames()
  {
    return num_frames;
  }

  void *GetFrameData(int frame_num)
  {
    if (num_frames<=0)
      return NULL;

    if (frame_num<0)
      frame_num = (frame_num % num_frames) + num_frames;
    else
      if (frame_num>=num_frames)
        frame_num = frame_num % num_frames;

  	LPBITMAPINFOHEADER lpbi = NULL;
	
		lpbi = (LPBITMAPINFOHEADER)AVIStreamGetFrame(getFrame, frame_num);
									
  	if (lpbi)
	  {
      //frame pixel data is 40 bytes past the bitmapinfoheader
      void *bitmap = ((unsigned char *)lpbi) + 40; 

      return bitmap;
    }

    return NULL;
  }

  void ReleaseAVI()
  {
    if (getFrame != NULL)
    {
      try
      {
        AVIStreamGetFrameClose(getFrame);
      }
      catch (...)
      {
        OutputDebugString("AVIStreamGetFrameClose error");
      }

      getFrame = NULL;
	  }

    if (streamVid != NULL)
    {
      try
      {
        AVIStreamRelease(streamVid);
      }
      catch (...)
      {
        OutputDebugString("AVIStreamRelease error");
      }

      streamVid = NULL;
    }

    if (m_aviFile!=NULL)
    {
      try
      {
        AVIFileRelease(m_aviFile);
      }
      catch (...)
      {
        OutputDebugString("AVIFileRelease error");
      }

      m_aviFile = NULL;
    }
  }

  ~Win32AVIFile()
  {    
    ReleaseAVI();
  }

protected:
  PAVIFILE m_aviFile;
  PAVISTREAM streamVid;
  PGETFRAME getFrame;
  
  int width, height;
  int num_frames; 
  
  DWORD dwRate;
  DWORD dwScale;
};

#endif