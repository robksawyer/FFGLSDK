---------------
FreeFrameGL SDK
---------------

Host and Plugin Samples for Windows and OSX by
  Trey Harrison - www.harrisondigitalmedia.com

Host and Plugin Samples converted for Linux, based on Trey's OSX code by
  Gabor Papp - www.mndl.hu

FFGLHeat and FFGLTile Plugins by
  Edwin De Konig - www.resolume.com

Delphi Host and Plugins by
  John Day - www.vjamm.com

Many .h and .cpp's were taken from the FreeFrame SDK by Gualtiero Volpe (Gualtiero.Volpe@unige.it) and extended / modified to support the new functions for OpenGL effects processing.

-------------
Specification
-------------

The Specification.html file documents the functions, values, and structures used by FreeFrameGL hosts and plugins. 

--------------------------
Windows C/C++ Instructions
--------------------------

Projects for MSVC .NET 2003 are found in the 'MSVC' sub-folders.

Projects for MSVC 2005 are in the 'MSVC8' sub-folders.

To test the FFGL host and sample plugins, go to the Binaries folder and run FFGLHost.exe.

You can also drag-and-drop a FFGL .dll onto FFGLHost.exe for testing your own DLL's.

Mouse movement is used to assign values to plugin #1 parameter #0 and plugin #2 parameter #0.

---------------------------
Windows Delphi Instructions
---------------------------

Developed in Delphi 6.

To test the FFGL host and sample plugins, navigate to the trunk/binaries/win32/delphihost folder, and run the FreeFrameDelphiHost.exe  .

Plugins need to be within the 'plugins' folder.

0. Select an avi file to use as source material
1. Select a plugin from the dropdown list
2. Press the 'Play and Process' button

It is possible to leave the application running and hotswap the current plugin as you work on it, by using the 'Reload Plugin' button.

Parameter control is via the lower right panel, select a parameter from the list of available and use the slider below.


----------------
OSX Instructions
----------------

The source code was written and compiled with XCode 2.4 and XCode 3.0. Older versions of XCode probably won't work.

To test the FFGL host and sample plugins, launch the Binaries/OSX/FFGLHost executable.

Mouse movement is used to assign values to plugin #1 parameter #0 and plugin #2 parameter #0.

------------------
Linux Instructions
------------------

The code is based on the OSX source files and it was compiled with gcc 4.1.1.

To compile the sample plugins, open a terminal window, navigate to the Projects/FFGLPlugins/Linux folder and type make. 

To test the FFGL host go to the Projects/FFGLHost/Linux folder, type make and run ./FFGLHost.

Mouse movement is used to assign values to plugin #1 parameter #0 and plugin #2 parameter #0.

------------
SDK Contents
------------

Specification.html
  Official FreeFrameGL specification document

Binaries/

  OSX/
    Sample host and plugin files ready to run on OSX

  Win32/
    Sample host and plugin files (from C/C++ source) ready to run on Windows

  Win32/DelphiHost
    Sample host and plugin files (from Delphi source) ready to run on Windows


Include/

  FreeFrame.h
    Slightly modified FreeFrame.h to compile nicely on Win & Mac (no FFGL info in here)

  FFGL.h
    FFGL header

  FFGLExtensions
    Cross-platform OpenGL extension access

  FFGLFbo.h
    Cross-platform Frame Buffer Objects (requires FFGLExtensions)

  FFGLShader.h
    Cross-platform GLSL shader objects (requires FFGLExtensions)


Source/

  Common/

    FFGLExtensions.cpp
    FFGLFBO.cpp
    FFGLShader.cpp
      Implementations of the cross-platform FFGL* helper classes


  FFGLHost/

    FFGLPluginInstance.h/.cpp
      Shared base class for loading and working with FFGL plugin instances

    Timer.h
      Shared base class for accurate timing

    FFDebugMessage.h
      Shared method for sending messages to the debugger

    OSX/
      Files specific to OSX implementation of the host

    Win32/
      Files specific to Win32 implementation of the host
      
    Linux/
      Files specific to GNU/Linux implementation of the host   


  FFGLPlugins/

    FFGLPluginSDK.h
      Header used by sample plugins to simplify plugin development

    FFGL.cpp
      plugMain handler

    FFGLPluginInfo.h/.cpp
    FFGLPluginInfoData.h/.cpp
    FFGLPluginManager.h/.cpp
      Helper classes adapted from Gualtiero Volpe's SDK


    FFGLBrightness/
    FFGLMirror/
    FFGLTile/
    FFGLHeat/
    FFGLGradients/
      Source code for sample plugins

  DelphiExamples/
    Delphi source code and project files for sample host and plugins


Projects/

  FFGLHost/

    XCode/
      XCode project files for FFGLHost

    MSVC/
      MSVC 2003 project files for FFGLHost

    MSVC8/
      MSVC 2005 project files for FFGLHost

    Linux/
      GCC makefile for FFGLHost
      

  FFGLPlugins/

    MSVC/
      MSVC 2003 project files for FFGLPlugins

    MSVC8/
      MSVC 2005 project files for FFGLPlugins

    XCode/
      XCode project files for FFGLPlugins

    Linux/
      GCC makefile for FFGLPlugins

Readme.txt
  This file (did you really read this far?)
