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

library PascalSamplePlugin;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }


uses
  SysUtils,
  Classes,
  {$IFDEF LINUX} Types,{$ENDIF}
  {$IFDEF WIN32} windows,{$ENDIF}
  plugin in 'plugin.pas';

{$R *.res}

var
  pPluginInfoStruct: pointer;
  pPluginExtendedInfoStruct: pointer;
  FreeFramePlugin: TFreeFramePlugin;

procedure LoadLibrary;
begin
  // DLL / SO open call ...
  // Do nothing - create object on freeframe initialise plugin
end;

procedure ExitLibrary;
begin
  // Do nothing
end;


{$IFDEF WIN32}
function plugMain(functionCode: dword; pParam: pointer; instanceID: dword): Pointer; stdcall
{$ENDIF}

{$IFDEF LINUX}
procedure plugMain(var Result: Pointer; functionCode: dword; pParam: pointer; instanceID: dword); cdecl;
{$ENDIF}

var
  PluginInstance:TFreeFramePlugin;
  NewPluginInstance:TFreeFramePlugin;
  i: integer;

begin

  PluginInstance:= pointer(instanceID);
  case functionCode of
    0: begin
      // Get Info
      result:=GetInfo;
    end;
    1: begin
      // Plugin Initislise
      result:=InitilisePlugin;
    end;
    2: begin
      // Plugin DeInitislise
      result:=DeInitilisePlugin;
    end;
    3: begin
      // processFrame
      result:=pointer($FFFFFFFF);   // since this is a FFGL plugin
    end;
    4: begin
      // getNumParameters
      result:=GetNumParameters(pParam);
    end;
    5: begin
      // getParametersName
      result:=GetParameterName(pParam);
    end;
    6: begin
      // getParametersDefault
      // IN: parameterIndex
      // OUT: default value
      result:=GetParameterDefault(pParam);
    end;
    7: begin
      // getParametersDisplay
      if assigned(PluginInstance) then result:=PluginInstance.GetParameterDisplay(pParam)
      else result:=pointer($FFFFFFFF);
    end;
    8: begin
      // setParameter(value)
      if assigned(PluginInstance) then result:=PluginInstance.SetParameter(pParam)
      else result:=pointer($FFFFFFFF);
    end;
    9: begin
      // getParameter(value)
      if assigned(PluginInstance) then result:=PluginInstance.GetParameter(pParam)
      else result:=pointer($FFFFFFFF);
    end;
    10: begin
      result:=GetPluginCaps(pParam);
    end;
    11: begin
      // Instantiate FF Plugin
      result:=pointer($FFFFFFFF);
      try
        NewPluginInstance:=TFreeFramePlugin.create;
        if integer(NewPluginInstance.InitialiseInstance(pParam))=0 then begin
          result:=pointer(NewPluginInstance);
        end else begin
          NewPluginInstance.Free;
          result:=pointer($FFFFFFFF);
        end;
      except
        NewPluginInstance.Free;
        result:=pointer($FFFFFFFF);
      end;
    end;
    12: begin
      // deInstantiate Plugin Instance
      // IN: none
      // OUT: Success/error code
      result:=pointer($FFFFFFFF);
      try
        if assigned(PluginInstance) then begin
          PluginInstance.DeInitialiseInstance;
          PluginInstance.destroy;
        end;
        result:=pointer(0);
      except
        result:=pointer($FFFFFFFF);
      end;
    end;
    13: begin
      // GetExtendedInfo
      // IN:  Nothing
      // OUT: Pointer to PluginExtendedInfoStruct
      result:=GetExtendedInfo;
    end;
    14: begin
      // ProcessFrameCopy
      // IN: Pointer to ProcessFrameCopyStruct
      // OUT: Success/Error Code
      if assigned(PluginInstance) then result:=PluginInstance.ProcessFrame(pParam)
      else result:=pointer($FFFFFFFF);
    end;
    15: begin
      // GetParamaterType
      // IN: ParameterNumber
      // OUT: Parameter Type
      result:=pointer(10); // all parameters on this plugin will be 'standard' for the moment
    end;
    16: begin
      // GetInputStatus
      // IN: InputChannel
      // OUT: InputStatus
    end;
    17: begin
      // processOpenGL
      // IN: pointer to ProcessOpenGLStruct
      // OUT: Success/error code
      if assigned(PluginInstance) then result:=PluginInstance.ProcessOpenGL(pParam)
      else result:=pointer($FFFFFFFF);
    end;
    18: begin
      //instantiate GL
      // IN: pointer to FFGLViewportStruct
      // OUT: InstanceIdentifier
      result:=pointer($FFFFFFFF);
      try
        NewPluginInstance:=TFreeFramePlugin.create;
        if integer(NewPluginInstance.InitialiseGLInstance(pParam))=0 then result:=pointer(NewPluginInstance)
        else begin
          NewPluginInstance.Free;
          result:=pointer($FFFFFFFF);
        end;
      except
        NewPluginInstance.Free;
        result:=pointer($FFFFFFFF);
      end;

    end;
    19: begin
      //deInstantiateGL
      // IN: none
      // OUT: Success/error code
      result:=pointer($FFFFFFFF);
      try
        if assigned(PluginInstance) then begin
          PluginInstance.DeInitialiseGLInstance;
          PluginInstance.destroy;
        end;
        result:=pointer(0);
      except
        result:=pointer($FFFFFFFF);
      end;
    end;
    20: begin
      // setTime
      // IN: time (in seconds - 64bit float)
      // OUT: Success/error code
      if assigned(PluginInstance) then result:=PluginInstance.SetTime(pParam)
      else result:=pointer($FFFFFFFF);
    end;
  else
    result:=pointer($FFFFFFFF);

  end;
end;

exports
  plugMain;

begin
  LoadLibrary;
  ExitProc:=@ExitLibrary;

end.
