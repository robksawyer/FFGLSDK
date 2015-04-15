// FreeFrame Open Video Plugin Test Container
//  and Delphi Host Inclusion Template
// (worked from the original codebase by Russell Blakeborough)

// www.freeframe.org
// johnday@camart.co.uk
// boblists@brightonart.org
{
Copyright (c) 2007 John Day
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.
   * Neither the name of FreeFrame nor the names of its
     contributors may be used to endorse or promote products derived
     from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

}

unit FFStructs;

interface

uses
  windows;

type
  TPluginInfoStruct = record
    APIMajorVersion: dword;
    APIMinorVersion: dword;
    PluginUniqueID: array [0..3] of char;   // 4 characters = 1 dword
    PluginName: array [0..15] of char;      // 16 characters = 4 Dwords
    PluginType: dword;                      //(effect, source)
  end;
  TPluginExtendedInfoStruct = record
    PluginMajorVersion: dword;
    PluginMinorVersion: dword;
    pDescription: pointer;
    pAbout: pointer;
    FreeFrameExtendedDataSize: dword;
    FreeFrameExtendedDataBlock: pointer;
  end;
  TVideoInfoStruct = record
    FrameWidth: dword;
    FrameHeight: dword;
    BitDepth: dword;   // 0=16bit 1=24bit 2=32bit
    orientation: dword;
  end;

  // structures for opengl freeframe plugin
  TPLuginGLViewportStruct=record
     X: dword;
     Y: dword;
     Width: dword;
     Height: dword;
  end;

  TPluginGLTextureStruct=record
    Width: dword;
    Height: dword;
    //Depth: dword;
    HardwareWidth: dword;
    HardwareHeight: dword;
    //HardwareDepth: dword;
    Handle: dword; // (GLuint)
  end;

  TProcessFrameCopyStruct = record
    numInputFrames: dword;
    ppInputFrames: pointer;
    pOutputFrame: pointer;
  end;

  TProcessOpenGLStruct=record
    numInputTextures:dword;
    ppInputTextures:dword; // 32-bit pointer to array of pointers to FFGLTextureStruct
    HostFBO:dword;         // 32-bit unsigned integer (GLuint)
  end;

implementation

end.
