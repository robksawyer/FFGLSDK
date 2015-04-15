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

unit PluginHost;

interface

uses windows, sysutils, ffstructs;

const
  FF_SUCCESS=$0;
  FF_FAIL=$FFFFFFFF;
  FF_TRUE=$1;
  FF_FALSE=$0;
  FF_SUPPORTED=$1;
  FF_UNSUPPORTED=$0;

type
  tPlugMainFunction = function(functionCode: dword; pParam: pointer; InstanceID: dword): pointer; stdcall;

  pdw = ^dword;

  function GetInfo: dword;
  function GetPluginCaps(Param: dword): boolean;
  function GetExtendedInfo: dword;

  function InitialisePlugin: dword;
  function DeInitialisePlugin: dword;
  function ProcessFrame(pFrame: pointer; InstanceID: dword): dword;

  // from old plugin host code
  function ProcessFrameCopy(plugMain: TPlugMainFunction;
                            InputFramesPointerArray: array of pointer;
                            pOutputFrame: pointer;
                            numInputFrames: dword;
                            instanceID: dword): dword;

  function ProcessOpenGL(pProcessOpenGLStruct:pointer;InstanceID:dword):dword;
  function GetNumParameters: dword;
  function GetParameterName(Param: dword): string;
  function GetParameterType(Param:dword):dword;
  function GetParameterDefault(Param: dword): single;
  function GetParameterDisplay(Param: dword; Instance: dword): string;
  function SetParameter(Param: dword; Value: single; Instance: dword): dword;
  function GetParameter(Param: dword; Instance: dword): single;


  function InstantiatePlugin(VideoInfoStruct: TVideoInfoStruct): dword;
  function DeInstantiatePlugin(Instance: dword): dword;

  function InstantiateGLPlugin(GLViewportStruct:TPLuginGLViewportStruct):dword;
  function DeInstantiateGLPlugin(Instance: dword): dword;

  function SetTime(Value:double;Instance:dword):dword;

var
  PluginInfoStruct: TPluginInfoStruct;
  PluginExtendedInfoStruct: TPluginExtendedInfoStruct;

  VideoInfoStruct:TVideoInfoStruct;   

  plugMain:tPlugMainFunction;

  GLViewportStruct:TPLuginGLViewportStruct;

implementation

//------------------------------------------------------------------------------
function GetInfo: dword;
var
  pPluginInfoStruct: pointer;
  pParam: PDword;
  tempPChar: PChar;
  i: integer;
begin
  pPluginInfoStruct:=plugMain(0,nil,0);
  with PluginInfoStruct do begin
    pParam:=pPluginInfoStruct;
    APIMajorVersion:=dword(pParam^);
    inc(pParam);
    APIMinorVersion:=dword(pParam^);
    inc(pParam);
    temppchar:=pchar(pParam);
    for i:=0 to 3 do begin
      PluginUniqueID[i]:=char(tempPchar^);
      inc(temppChar);
    end;
    for i:=0 to 15 do begin
      PluginName[i]:=char(tempPchar^);
      inc(tempPchar);
    end;
    pParam:=pDword(tempPchar);
    PluginType:=dword(pParam^);
  end;
  result:=dword(pPluginInfoStruct);
end;
//------------------------------------------------------------------------------
function GetExtendedInfo: dword;
var
  pPluginExtendedInfoStruct: pointer;
  pParam: pDword;
begin
  pPluginExtendedInfoStruct:=plugMain(13,nil,0);

  if not assigned(pPluginExtendedInfoStruct) or (dword(pPluginExtendedInfoStruct)=$FFFFFFFF) then begin
    result:=$FFFFFFFF;
    exit;
  end;

  with PluginExtendedInfoStruct do begin
    pParam:=pPluginExtendedInfoStruct;
    PluginMajorVersion:=dword(pParam^);
    inc(pParam);
    PluginMinorVersion:=dword(pParam^);
    // text fields not implemented yet here
  end;
  result:=dword(pPluginExtendedInfoStruct);
end;
//------------------------------------------------------------------------------
function GetPluginCaps(Param: dword): boolean;
begin
  result := false;
  case dword(plugMain(10,pointer(Param),0)) of
    0: result:=false;
    1: result:=true;
  end;
end;
//------------------------------------------------------------------------------
function InitialisePlugin: dword;
begin
  result:=dword(plugMain(1,nil,0));
end;
//------------------------------------------------------------------------------
function DeInitialisePlugin: dword;
begin
  try
    result:=dword(plugMain(2,nil,0));
  except
    result:=23;
  end;
end;

function GetNumParameters: dword;
begin
  result:=dword(plugMain(4,nil,0));
end;
//------------------------------------------------------------------------------
function GetParameterName(Param: dword): string;
var
  tempParamName: array [0..15] of char;
  tempSourcePointer: pdw;
  tempDestPointer: pdw;
  i: integer;
begin
  tempSourcePointer:=pdw(plugMain(5,pointer(Param),0));
  tempDestPointer:=pdw(@tempParamName);
  for i:=0 to 3 do begin // 4 integers = 4x4bytes = 16 chars
    tempDestPointer^:=tempSourcePointer^;
    inc(tempSourcePointer);
    inc(tempDestPointer);
  end;
  result:=string(tempParamName);
end;
//------------------------------------------------------------------------------
function GetParameterType(Param: dword): dword;
begin
  result:=dword(plugMain(15,pointer(Param),0));
end;
//------------------------------------------------------------------------------
function GetParameterDefault(Param: dword): single;
var
  p:pointer;
begin
  p:=plugMain(6,pointer(Param),0);
  result:=psingle(@p)^;
end;
//------------------------------------------------------------------------------
function GetParameterDisplay(Param: dword; Instance: dword): string;
var
  tempParamDisplay: array [0..15] of char;
  tempSourcePointer: pdw;
  tempDestPointer: pdw;
  i: integer;
begin
  tempSourcePointer:=pdw(plugMain(7,pointer(Param),Instance));
  tempDestPointer:=pdw(@tempParamDisplay);
  for i:=0 to 3 do begin
    tempDestPointer^:=tempSourcePointer^;
    inc(tempSourcePointer);
    inc(tempDestPointer);
  end;
  result:=string(tempParamDisplay);
end;
//------------------------------------------------------------------------------
function SetParameter(Param: dword; Value: single; Instance: dword): dword;
type
  TSetParamStruct = array [0..1] of dword;
var
  SetParamStruct: TSetParamStruct;
  tempPdword: pdw;
begin
  SetParamStruct[0]:=Param;
  tempPdword:=@value;
  SetParamStruct[1]:=tempPdword^;
  result:=dword(plugMain(8,@SetParamStruct, Instance));
end;
//------------------------------------------------------------------------------
function GetParameter(Param: dword; Instance: dword): single;
var
  tempDword: dword;
  tempPdword: pdw;
  tempSingle: single;
  tempPsingle: pointer;
begin
  tempdword:=dword(plugMain(9,pointer(Param),Instance));
  tempPdword:=@tempDword;
  tempPsingle:=@tempSingle;
  copymemory(tempPsingle,tempPdword,4);
  result:=tempSingle;
end;

//------------------------------------------------------------------------------
function InstantiatePlugin(VideoInfoStruct: TVideoInfoStruct): dword;
var
  pVideoInfoStruct: pointer;
begin
  pVideoInfoStruct:=pointer(@VideoInfoStruct);
  result:=dword(plugMain(11,pVideoInfoStruct,0));
end;
//------------------------------------------------------------------------------
function ProcessFrame(pFrame: pointer; InstanceID: dword): dword;
begin
  result:=dword(plugMain(3,pFrame,InstanceID));
end;
//------------------------------------------------------------------------------
// from old plugin host code
function ProcessFrameCopy(plugMain: TPlugMainFunction;
                          InputFramesPointerArray: array of pointer;
                          pOutputFrame: pointer;
                          numInputFrames: dword;
                          instanceID: dword): dword;
var
  ProcessFrameCopyStruct: TProcessFrameCopyStruct;
begin
  ProcessFrameCopyStruct.numInputFrames:=numInputFrames;
  ProcessFrameCopyStruct.ppInputFrames:=@InputFramesPointerArray;
  ProcessFrameCopyStruct.pOutputFrame:=pOutputFrame;
  result:=dword(plugMain(14,pointer(@ProcessFrameCopyStruct),InstanceID));
end;
//------------------------------------------------------------------------------
function DeInstantiatePlugin(Instance: dword): dword;
begin
  result:=dword(plugMain(12,nil,Instance));
end;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
function InstantiateGLPlugin(GLViewportStruct:TPLuginGLViewportStruct):dword;
begin
  result:=dword(plugMain(18,@GLViewportStruct,0));
end;
//------------------------------------------------------------------------------
function ProcessOpenGL(pProcessOpenGLStruct:pointer;InstanceID:dword):dword;
begin
  result:=dword(plugMain(17,pProcessOpenGLStruct,InstanceID));
end;
//------------------------------------------------------------------------------
function DeInstantiateGLPlugin(Instance: dword): dword;
begin
  result:=dword(plugMain(19,nil,Instance));
end;
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
function SetTime(Value:double;Instance: dword): dword;
begin
  result:=dword(plugMain(20,@value,Instance));
end;
//------------------------------------------------------------------------------

end.

