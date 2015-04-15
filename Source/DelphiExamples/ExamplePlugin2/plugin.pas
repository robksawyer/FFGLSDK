// FreeFrame Open Video Plugin GL Example
// www.freeframe.org
// johnday@camart.co.uk

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

unit plugin;

interface

uses
  sysutils,syncobjs,classes,
  gl,glu, ffstructs,
{$IFDEF LINUX} Types;{$ENDIF}
{$IFDEF WIN32} windows;{$ENDIF}

const
  NumberOfParameters=0;

type

  pdw = ^Dword;
  pw = ^word;
  pb = ^byte;

type

  TFreeFramePlugin = class(TObject)
  private
    // standard FreeFrame
    VideoInfoStruct: TVideoInfoStruct;

    // openGL FreeFrame
    ViewPortStruct:TPLuginGLViewportStruct;
    ProcessOpenGLStruct:TProcessOpenGLStruct;

    // Plugin Parameters
    ParameterArray: array [0..NumberOfParameters] of single;
    ParameterDisplayValue: array [0..NumberOfParameters,0..15] of char;

    // this plugins local vars
    Perspective:single;

    prevtime:double;
    absoluteTime:double;

  protected
  public
    constructor Create;
    destructor Destroy;

    // functions that are instance specific
    function InitialiseInstance(pParam: pointer): pointer;
    function DeInitialiseInstance: pointer;

    function InitialiseGLInstance(pParam: pointer):pointer;
    function DeInitialiseGLInstance: pointer;

    function GetParameterDisplay(pParam: pointer): pointer;
    function SetParameter(pParam: pointer): pointer;
    function GetParameter(pParam: pointer): pointer;

    function ProcessFrame(pParam: pointer): pointer;
    function ProcessOpenGl(pParam:pointer):pointer;

    function SetTime(pParam:pointer):pointer;
  end;

// Global functions that are not instance specific ...

function InitilisePlugin:pointer;
function DeInitilisePlugin:pointer;
function GetInfo:pointer;
function GetExtendedInfo:pointer;
function GetNumParameters(pParam: pointer): pointer;
function GetParameterName(pParam: pointer): pointer;
function GetParameterType(pParam: pointer): pointer;
function GetParameterDefault(pParam: pointer): pointer;
function GetPluginCaps(pParam: pointer): pointer;

var
  PluginInfoStruct: TPluginInfoStruct;
  PluginExtendedInfoStruct: TPluginExtendedInfoStruct;

  ParameterNames: array [0..NumberOfParameters,0..15] of char;
  ParameterDefaults: array [0..NumberOfParameters] of single;
  ParameterTypes: array [0..NumberOfParameters] of dword;

implementation

//------------------------------------------------------------------------------
//
// GLOBAL FUNCTIONS
//
//------------------------------------------------------------------------------

function InitilisePlugin:pointer;
begin
  //ParameterNames[0]:='Block Count    ';    // MUST be 15 chars
  //ParameterTypes[0]:=10;
  //ParameterDefaults[0]:=0.3;
  result:=pointer(0);
end;

function DeInitilisePlugin:pointer;
begin
  result:=pointer(0);
end;

//------------------------------------------------------------------------------
function GetInfo:pointer;
begin
  with PluginInfoStruct do begin
    APIMajorVersion:=1;
    APIMinorVersion:=0;
    PluginUniqueID:='GLX2';
    PluginName:='JD-RenderSpin';
    PluginType:=0;   // 0 = effect - 1 = source
  end;
  result:=@PluginInfoStruct;
end;
//------------------------------------------------------------------------------
function GetExtendedInfo:pointer;
begin
  with PluginExtendedInfoStruct do begin
    PluginMajorVersion:=1;
    PluginMinorVersion:=0;
    pDescription:= nil;
    pAbout:= nil;
    FreeFrameExtendedDataSize:= 0;
    FreeFrameExtendedDataBlock:= nil;
  end;
  result:=@pluginExtendedInfoStruct;
end;
//------------------------------------------------------------------------------
function GetPluginCaps(pParam: pointer): pointer;
begin
  case integer(pParam) of
    0: result:=pointer(0);   // 0=16bit - not yet supported in this sample plugin
    1: result:=pointer(0);   // 1=24bit - supported
    2: result:=pointer(0);   // 2=32bit
    3: result:=pointer(0);   // this plugin dosen't support copy yet
    4: result:=pointer(1);   // is an opengl plugin
    5: result:=pointer(1);   // this plugin supports setTime
    10: result:=pointer(1);  // minimum number of inputs
    11: result:=pointer(1);  // maximum number of inputs
    15: result:=pointer(0);  // optimization
                             // 0 (FF_CAP_PREFER_NONE) = no preference (GL plugins must return 0)
                             // 1 (FF_CAP_PREFER_INPLACE) = InPlace processing is faster
                             // 2 (FF_CAP_PREFER_COPY) = Copy processing is faster
                             // 3 (FF_CAP_PREFER_BOTH) = Both are optimized
    else result:=pointer($FFFFFFFF)   // unknown PluginCapsIndex
  end;
end;
//------------------------------------------------------------------------------
function GetNumParameters(pParam: pointer): pointer;
begin
  result:=pointer(NumberOfParameters);
end;
//------------------------------------------------------------------------------
function GetParameterName(pParam: pointer): pointer;
begin
  if integer(pParam)<NumberOfParameters then result:=@ParameterNames[integer(pParam)][0]
  else result:=pointer($FFFFFFFF);
end;
//------------------------------------------------------------------------------
function GetParameterType(pParam: pointer): pointer;
begin
  if integer(pParam)<NumberOfParameters then result:=@ParameterTypes[integer(pParam)]
  else result:=pointer($FFFFFFFF);
end;
//------------------------------------------------------------------------------
function GetParameterDefault(pParam: pointer): pointer;
begin
  if integer(pParam)<NumberOfParameters then result:=@ParameterDefaults[integer(pParam)]
  else result:=pointer($FFFFFFFF);
end;


//------------------------------------------------------------------------------
//
// INSTANCE FUNCTIONS
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
constructor TFreeFramePlugin.Create;
begin
  absoluteTime:=0;
end;

destructor TFreeFramePlugin.Destroy;
begin
  //
end;


//------------------------------------------------------------------------------
function TFreeFramePlugin.InitialiseInstance(pParam: pointer):pointer;
begin
  result:=pointer($FFFFFFFF);          // this is an opengl plugin so return error
end;
//------------------------------------------------------------------------------
function TFreeFramePlugin.DeInitialiseInstance: pointer;
begin
  result:=pointer($FFFFFFFF);          // this is an opengl plugin so return error
end;
//------------------------------------------------------------------------------
function TFreeFramePlugin.InitialiseGLInstance(pParam: pointer):pointer;
var
  tempPointer: pDw;
  i:integer;
begin
  tempPointer:=pDw(pParam);
  ViewPortStruct.x:=tempPointer^;       // x
  inc(tempPointer);
  ViewPortStruct.y:=tempPointer^;       // y
  inc(tempPointer);
  ViewPortStruct.Width:=tempPointer^;   // width
  inc(tempPointer);
  ViewPortStruct.Height:=tempPointer^;  // height

  Perspective:=ViewPortStruct.width/ViewPortStruct.height;

  // load parameters with defaults here
  for i:=0 to NumberOfParameters-1 do ParameterArray[i]:=ParameterDefaults[i];

  // not going to update these in this example
  //ParameterDisplayValue[0]:='Block Count    ';   // MUST be 15 chars
  prevtime:=0;

  result:=pointer(0);
end;
//------------------------------------------------------------------------------
function TFreeFramePlugin.DeInitialiseGLInstance: pointer;
begin
  result:=pointer(0);
end;

//------------------------------------------------------------------------------
function TFreeFramePlugin.GetParameterDisplay(pParam: pointer): pointer;
var
  paramindex:dword;
begin
  paramindex:=dword(pParam);
  if paramIndex<NumberOfParameters then begin
    result:=@ParameterDisplayValue[paramindex];
  end else begin
    result:=pointer($FFFFFFFF);
  end;
end;
//------------------------------------------------------------------------------
function TFreeFramePlugin.SetParameter(pParam: pointer): pointer;
var
  paramIndex:dword;
  prevblockcount:integer;
begin
  paramIndex:=dword(pParam^);
  if paramIndex<NumberOfParameters then begin
    result:=pointer(0);
  end else
    result:=pointer($FFFFFFFF);
end;
//------------------------------------------------------------------------------
function TFreeFramePlugin.GetParameter(pParam: pointer): pointer;
var
  tempSingle: single;
begin
  tempSingle:=ParameterArray[integer(pParam)];
  result:=pointer(tempSingle);
end;
//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
function TFreeFramePlugin.ProcessFrame(pParam: pointer): pointer;
begin
  result:=pointer($FFFFFFFF);  // gl plugin so return false
end;
//------------------------------------------------------------------------------
function TFreeFramePlugin.ProcessOpenGl(pParam:pointer):pointer;
var
  tempPointer,pInTex: pDw;
  pInTexArray:pointer;

  InputTexture:TPluginGLTextureStruct; // just one texture input for this plugin
  numInputTextures:dword;
  hostFBO:dword;

  now:double;
  u2,v2:single;

begin
  tempPointer:=pDw(pParam);

  numInputTextures:=tempPointer^;
  if numInputTextures<1 then begin       // must have at least one input texture
    result:=pointer($FFFFFFFF);
    exit;
  end;
  inc(tempPointer);

  pInTexArray:=pointer(tempPointer^);      // 32-bit pointer to array of pointers to FFGLTextureStruct
  inc(tempPointer);

  HostFBO:=tempPointer^;                   // if you are using any fbo's reattach this at the end of function

  // possible loop if using more then 1 input texture
    pInTex:=pDw(pInTexArray^);
    InputTexture.Width:=pInTex^;
    inc(pInTex);
    InputTexture.Height:=pInTex^;
    inc(pInTex);
    InputTexture.HardwareWidth:=pInTex^;
    inc(pInTex);
    InputTexture.HardwareHeight:=pInTex^;
    inc(pInTex);
    InputTexture.Handle:=pInTex^; // (GLuint)
  //

  // use timebased controls, allows effect to stay in time even if host slow frames
  now:=absoluteTime*1000;// convert from secs to msecs

  // update texture cords, since these may change frame to frame,
  u2:=InputTexture.HardwareWidth/InputTexture.Width;
  v2:=InputTexture.HardwareHeight/InputTexture.Height;

  // gl should have been set to default state by host before this point

  // setup required projection (host will not know what you want so set it up yourself)
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluperspective(65,Perspective,1,-1);

  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D,InputTexture.Handle);

  // shouldn't really blend (but for this testbed does)
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(0,0,-5);
  glRotatef(now/90,0,1,0);    // rotation position based on absolute time

  glColor4f(1.0,1.0,1.0,1.0);
  glBegin(GL_QUADS);
    glTexCoord2f(0,0); glVertex3f(-3.5,-3.5,0);
    glTexCoord2f(u2,0); glVertex3f(3.5,-3.5,0);
    glTexCoord2f(u2,v2); glVertex3f(3.5,3.5,0);
    glTexCoord2f(0,v2); glVertex3f(-3.5,3.5,0);
  glEnd();

  result:=pointer(0);

  // reset gl to default state here (possible missing or incomplete at mo)
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;

  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D,0);
  glColor4f(1.0,1.0,1.0,1.0);
end;
//------------------------------------------------------------------------------

function TFreeFramePlugin.SetTime(pParam:pointer):pointer;
begin
  absoluteTime:=double(pParam^);
  if absoluteTime=0 then prevtime:=0;
  result:=pointer(0);
end;
//------------------------------------------------------------------------------

end.
