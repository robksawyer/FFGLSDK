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


unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, inifiles, GL,glu, FFStructs;

type
  TParams=record
    name:string;
    t:dword;              // type
    default:string;
    displayvalue:string;
    actualvalue:single;
  end;

  TfmMain = class(TForm)
    odAVI: TOpenDialog;
    tPlay: TTimer;
    lAPIversion: TLabel;
    previewpanel: TPanel;
    ebAVIFilename: TEdit;
    bBrowse: TButton;
    GroupBox2: TGroupBox;
    lVideoWidth: TLabel;
    lVideoHeight: TLabel;
    lBitDepth: TLabel;
    lOrientation: TLabel;
    pnInfo: TPanel;
    lProfile: TLabel;
    Label3: TLabel;
    cbPlugins: TComboBox;
    bProcessFrame: TButton;
    bPlayAndProcess: TButton;
    cbPluginProcessFrames: TCheckBox;
    bDeInitPlugin: TButton;
    bStop: TButton;
    Memo1: TMemo;
    lbParams: TListBox;
    sbParam: TScrollBar;
    lbpname: TLabel;
    lbpvalue: TLabel;
    Label2: TLabel;
    btnReload: TButton;
    Panel1: TPanel;
    Label1: TLabel;
    cbVerify: TCheckBox;
    cbTest32Bit: TCheckBox;
    cbCheckers: TCheckBox;
    btnGrabFrame: TButton;
    Panel2: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel3: TPanel;
    PaintBox1: TPaintBox;
    Panel4: TPanel;
    glpanel: TPanel;
    Panel5: TPanel;
    pbRGB: TPaintBox;
    Panel6: TPanel;
    pbAlpha: TPaintBox;
    Memo2: TMemo;
    lbAviStatus: TLabel;
    Label7: TLabel;
    sbTime: TScrollBar;
    lbTime: TLabel;
    sbATime: TScrollBar;
    Label8: TLabel;
    Label9: TLabel;
    cbATime: TCheckBox;
    Memo3: TMemo;

    procedure ebAVIFilenameChange(Sender: TObject);

    procedure bProcessFrameClick(Sender: TObject);
    procedure cbPluginsChange(Sender: TObject);

    procedure bBrowseClick(Sender: TObject);
    procedure bPlayAndProcessClick(Sender: TObject);
    procedure tPlayTimer(Sender: TObject);
    procedure bStopClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure sbParamChange(Sender: TObject);
    procedure lbParamsClick(Sender: TObject);
    procedure cbVerifyClick(Sender: TObject);
    procedure cbTest32BitClick(Sender: TObject);
    procedure cbCheckersClick(Sender: TObject);
    procedure btnGrabFrameClick(Sender: TObject);
    procedure btnReloadClick(Sender: TObject);
    procedure bDeInitPluginClick(Sender: TObject);
    procedure sbTimeChange(Sender: TObject);

  private
    exepath:string;
    lpBitmapInfoHeader: pBitmapInfoHeader;

    CurrentPlug:thandle;
    PluginInstance:dword;    // Plugin Instance Identifier
    InstanceReady:boolean;

    currentParam:integer;
    Params: array of TParams;

    skipdefaults:boolean;
    //skiptypes:boolean;

    verifyParam:boolean;

    NumParams: dword;
    PluginLoaded: boolean;
    glplugin:boolean;
    supportstime:boolean;

    // gl vars
    glinit:boolean;
    framestore:pointer;

    DC:HDC;
    RC:HGLRC;
    tpot:integer;
    tex24bit:gluint;           // frame texture
    tex32bit:gluint;

    checks:gluint;        // background image for checking alpha layer
    checksangle:integer;
    checksenabled:boolean;
    test32bit:boolean;

    framedump:TMemoryStream;

    absoluteTime:double;  // in secs
    timeAccel:single;

    procedure GetPlugins;
    procedure LoadAVI;
    procedure LoadPlugin;
    procedure collectInfo;

    procedure CollectParamNames;
    procedure CollectParamTypes;
    function  paramTypeString(t:dword):string;
    procedure CollectParamDefaults;
    procedure CollectParamValues;
    procedure CollectParamDisplay;

    function  initplugin:dword;
    procedure DeInitPlugin;

    procedure DisplayFrame(lpbitmapinfoheader: pbitmapinfoheader; channel: integer);
    procedure Process;
    procedure ProfileAndProcessFrame(pFrame: pointer; PluginInstance: dword);     // This is the main frame processing procedure
    procedure ProfileAndProcessGLFrame(pFrame: pointer; PluginInstance: dword);

    function  setupPixelFormat(DC:HDC):boolean;
    procedure InitGL;
    procedure InitTexture(w,h:integer);
    procedure RefreshGLDisplay;
    procedure UploadFrame(bits:pointer;w,h:integer);
  public
    AHDC: HDC;                   // Handle
  end;

const
  AppVersion: string='2.03';
  APIversion: string='1.5';

var
  fmMain: TfmMain;

  CurrentFrame: array [0..1] of integer;
  NumFrames: array [0..1] of integer;

  bits: pointer;
  lpBitmapInfoHeader: pBitmapInfoHeader;


implementation

uses pluginHost, avi, utils;

var
  p32bitFrame: pointer;

{$R *.DFM}

procedure TfmMain.FormCreate(Sender: TObject);
var
  inifile: TInifile;
  tempFilename: string;
  tempPluginname:string;
  index:integer;
begin
  exepath:=extractfilepath(application.exename);

  CurrentPlug:=0;
  CurrentParam:=0;
  setlength(params,0);

  PluginLoaded:=false;
  verifyParam:=true;

  fmMain.Caption:='FreeFrame Plugin Tester v'+AppVersion;
  lAPIversion.Caption:='for FreeFrame API v'+APIversion;

  // collect application setings from freeframe.ini
  inifile:=Tinifile.Create(exepath+'FreeFrame.ini');
  with inifile do begin
    tempFilename:=ReadString('Filenames','CurrentAVI','');
    tempPluginname:=ReadString('Filenames','CurrentDll','');
  end;
  inifile.Free;

  // setup gl
  checks:=0;
  checksenabled:=false;
  test32bit:=false;

  InitGL;

  // autoload avi if possible
  if fileExists(tempFilename) then begin
    ebAVIfilename.Text:=tempFilename;
    loadAVI;
  end;

  PluginInstance:=0;
  getPlugins;

  // autoload plugin if possible
  currentPlug:=0;
  if (cbPlugins.Items.Count>0) then begin
      if not avi.AVIopen[0] then begin
        showmessage('Sorry, Unable to Load Plugin, until a Avi File has successfully loaded');
        exit;
      end else begin
        currentPlug:=0;
        if tempPluginname<>'' then begin
          if not fileExists(exepath+'plugins\'+tempPluginname) then begin
            showmessage('Sorry, Unable to find '+tempPluginname+', loading first plugin in list');
          end else begin
            index:=cbPlugins.Items.IndexOf(tempPluginname);
            if index>-1 then begin
              cbPlugins.OnChange:=nil;
              cbPlugins.ItemIndex:=index;
              cbPlugins.OnChange:=cbPLuginsChange;
            end;
          end;
        end;
        LoadPlugin;
      end;
  end;

  framedump:=TMemoryStream.Create;
  framedump.SetSize(glpanel.Width*glpanel.Height*4);

end;
//------------------------------------------------------------------------------
procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  inifile: TInifile;
begin
  // stop playing ...
  if tPlay.Enabled then tPlay.Enabled:=false;
  // Free the 32 bit framebuffer if we're in 32 bit mode ...
  if VideoInfoStruct.bitdepth=2 then utils.free32bitBuffer(p32bitFrame, VideoInfoStruct);
  // free plugin
  if pluginloaded then begin
    deinitPlugin;
  end;
  // Save Settings ...
  inifile:=Tinifile.Create(exepath+'FreeFrame.ini');
  inifile.WriteString('Filenames','CurrentDll',cbPlugins.items[cbPlugins.itemindex]);
  inifile.Free;

  framedump.Free;

  if avi.AVIopen[0] then avi.CloseAVI(0);
  CanClose:=true;
end;

//------------------------------------------------------------------------------
procedure TfmMain.GetPlugins;
  function checkValid(name: string):boolean;
  const
    functionName = 'plugMain';
  var
    h: thandle;
    proc: pointer;
  begin
    result:=false;
    if not (compareText(copy(name,length(name)-3,4),'.dll')=0) then exit; //findfirst returns filenames containing dll, not just ending
    h := LoadLibrary(pchar(name));
    if h <> 0 then begin //its a dll!
      Proc := GetProcAddress(h, functionName);
      if Proc <> nil then result:=true;
      FreeLibrary(h);
    end;
  end;
var
  plugins: string;
  t: TSearchRec;
begin
  cbPlugins.OnChange:=nil;
  cbPlugins.items.clear;
  plugins := exepath+'plugins\';
  if findfirst(plugins+'*.dll', faAnyFile, t) = 0 then begin
    if checkValid(plugins+t.name) then cbPlugins.items.add(t.name);
    while findnext(t) = 0 do if checkValid(plugins+t.name) then cbPlugins.items.add(t.name);
    findclose(t);
  end;
  if cbPlugins.Items.Count>0 then cbPlugins.ItemIndex:=0;
  cbPlugins.OnChange:=fmMain.cbPluginsChange;

end;

//------------------------------------------------------------------------------
procedure TfmMain.LoadAVI;
begin
  if tPlay.Enabled then tPlay.Enabled:=false;
  deinitplugin;

  if AVIopen[0] then DeInit;

  lbAvistatus.Caption:='Avi Status: Loading';
  // InitAVI ....
  AVI.Init;
  CurrentFrame[0]:=0;
  // OpenAVI ....
  PluginHost.VideoInfoStruct:=AVI.OpenAVI(ebAVIfilename.text,0);
  if AVIopen[0] then begin
    lVideoWidth.caption:=inttostr(PluginHost.VideoInfoStruct.FrameWidth);
    lVideoHeight.caption:=inttostr(PluginHost.VideoInfoStruct.FrameHeight);
    case PluginHost.VideoInfoStruct.BitDepth of
      0: lBitDepth.Caption:='16 bit';
      1: lBitDepth.Caption:='24 bit';
      2: lBitDepth.Caption:='32 bit';
    end;
    case VideoInfoStruct.orientation of
      1: lOrientation.caption:='Right Way Up';
      2: lOrientation.caption:='Upside Down';
    end;

    // GetFrame ....
    inc(currentFrame[0]);
    lpbitmapinfoheader:=AVI.GetFrame(currentFrame[0],0);
    displayframe(lpbitmapinfoheader,0);

    lbAvistatus.Caption:='Avi Status: Ready';
  end;
end;

//------------------------------------------------------------------------------
// we make a copy so developers can continue coding plugin and leave this application running
procedure TfmMain.LoadPlugin;
var
  filename:pchar;
begin
  // Stop Playing AVI
  tPlay.Enabled:=false;
  deinitplugin;

  if cbPlugins.itemindex<0 then exit;

  plugMain:=nil;
  if currentPlug<>0 then freeLibrary(currentPlug);

  try
    filename:=pchar(exepath+'plugins\'+cbPlugins.items[cbPlugins.itemindex]);
    copyfile(filename,pchar(exepath+'tempplugincopy.dll'),false);
    currentPlug := LoadLibrary(pchar(exepath+'tempplugincopy.dll'));
    if currentPlug <> 0 then begin //its a dll!
      try
        plugMain := GetProcAddress(currentPlug, 'plugMain');
        if @plugMain = nil then begin
          FreeLibrary(currentPlug);
          currentPlug:=0;
        end;
      except
        memo1.Lines.Add('** Exception during while discovering plugMain');
      end;
    end;
    if not assigned(plugMain) then begin
      showmessage('Sorry, Failed to find procAddress for plugMain');
      exit;
    end;
  except
    memo1.Lines.Add('** Exception during while loading plugin');
  end;

  skipdefaults:=false;

  if initplugin=0 then PluginLoaded:=true;

end;
//------------------------------------------------------------------------------
procedure TfmMain.collectInfo;
var
  pc16,pc24,pc32:integer;
  i: integer;
  result,names,defaults:dword;
  text:string;
begin
  memo1.Clear;

  // Get PluginInfoStruct and display its data
  memo1.Lines.Add('[ PluginInfoStruct ]');
  memo1.Lines.Add(' ');

  result:=PluginHost.GetInfo;
  if result=FF_FAIL then begin
    memo1.Lines.Add('ERROR');
  end else begin
    memo1.Lines.Add('API MajorVersion: '+inttostr(PluginHost.PluginInfoStruct.APIMajorVersion));
    memo1.Lines.Add('API Minor Version: '+inttostr(PluginHost.PluginInfoStruct.APIMinorVersion));
    memo1.Lines.Add('Unique ID: '+PluginHost.PluginInfoStruct.PluginUniqueID);
    memo1.Lines.Add('Name : '+PluginHost.PluginInfoStruct.PluginName);
    case PluginHost.PluginInfoStruct.PluginType of
    0: memo1.Lines.Add('Type: Effect');
    1: memo1.Lines.Add('Type: Source');
    end;
  end;
  memo1.Lines.Add(' ');

  // Call GetPluginCaps to see which bitdepths it can manage      todo: make use of this data to decide what to do on process frame etc.
  memo1.Lines.Add('[ Plugin Capabilities ]');
  memo1.Lines.Add(' ');

  result:=integer(PluginHost.GetPluginCaps(0));
  if result=FF_FAIL then memo1.lines.add('16bit: ERROR')
  else if result=0 then memo1.lines.add('16bit: No') else memo1.lines.add('16bit: Yes');
  pc16:=result;

  result:=integer(PluginHost.GetPluginCaps(1));
  if result=FF_FAIL then memo1.lines.add('24bit: ERROR')
  else if result=0 then memo1.lines.add('24bit: No') else memo1.lines.add('24bit: Yes');
  pc24:=result;

  result:=integer(PluginHost.GetPluginCaps(2));
  if result=FF_FAIL then memo1.lines.add('32bit: ERROR')
  else if result=0 then memo1.lines.add('32bit: No') else memo1.lines.add('32bit: Yes');
  pc32:=result;

  if (pc24=0) and (pc32=1) then begin
    VideoInfoStruct.BitDepth:=2;
    lBitDepth.Caption:='32 bit';
  end;
  // going to always have a 32bit buffer ( for use in gl upload)
  p32bitFrame:=Utils.Make32bitBuffer(VideoInfoStruct);
  //end;

  result:=integer(PluginHost.GetPluginCaps(3));
  if result=FF_FAIL then memo1.lines.add('ProcessFrameCopy: Error')
  else if result=0 then memo1.lines.add('ProcessFrameCopy: No') else memo1.lines.add('ProcessFrameCopy: Yes');

  glplugin:=false;
  result:=integer(PluginHost.GetPluginCaps(4));
  if result=FF_FAIL then memo1.lines.add('ProcessOpenGL: Error')
  else if result=0 then begin
    memo1.lines.add('ProcessOpenGL: No');
  end else begin
    memo1.lines.add('ProcessOpenGL: Yes');
    glplugin:=true;
  end;

  if glplugin then begin
    if ((pc16<>0) or (pc24<>0) or (pc32<>0)) then memo1.lines.add('* WARNING: Plugin SHOULD NOT report 16/24/32bit caps *');
  end else begin
    if ((pc16=0) and (pc24=0) and (pc32=0)) then memo1.lines.add('* ERROR: Plugin IS NOT reporting 16/24/32bit caps *');
  end;

  supportstime:=false;
  result:=integer(PluginHost.GetPluginCaps(5));
  if result=FF_FAIL then memo1.lines.add('Supports SetTime: Error')
  else if result=0 then begin
    memo1.lines.add('Supports SetTime: No');
    lbTime.Visible:=false;
    sbTime.Visible:=false;
    cbATime.Visible:=false;
    sbATime.Visible:=false;
  end else begin
    memo1.lines.add('Supports SetTime: Yes');
    supportstime:=true;
    timeAccel:=1.0;
    lbTime.Visible:=true;
    sbTime.Visible:=true;
    sbTime.Position:=0;
    cbATime.Checked:=false;
    cbATime.Visible:=true;
    sbATime.Visible:=true;
  end;

  result:=integer(PluginHost.GetPluginCaps(10));
  if result=FF_FAIL then memo1.lines.add('Min InputFrames: Error')
  else memo1.lines.add('Min InputFrames: '+inttostr(result));

  result:=integer(PluginHost.GetPluginCaps(11));
  if result=FF_FAIL then memo1.lines.add('Max InputFrames: Error')
  else memo1.lines.add('Max InputFrames: '+inttostr(result));

  result:=integer(PluginHost.GetPluginCaps(15));
  if result=FF_FAIL then memo1.lines.add('Optimization: Error')
  else begin
    case result of
    0: memo1.lines.add('Optimization: FF_CAP_PREFER_NONE');
    1: memo1.lines.add('Optimization: FF_CAP_PREFER_INPLACE');
    2: memo1.lines.add('Optimization: FF_CAP_PREFER_COPY');
    3: memo1.lines.add('Optimization: FF_CAP_PREFER_BOTH');
    end;
  end;

  memo1.Lines.Add(' ');

  // Set Video orientation to upside down (VFW)
  VideoInfoStruct.orientation:=2;
  lOrientation.caption:='Upside Down';

  // Get PluginExtendedInfoStruct and display its data
  memo1.Lines.Add('[ ExtendedInfoStruct ]');
  memo1.Lines.Add(' ');

  result:=PluginHost.getExtendedInfo;
  if result=FF_FAIL then begin
    memo1.Lines.Add('ERROR');
  end else begin
    memo1.lines.add('Plugin Major Version: '+inttostr(PluginHost.PluginExtendedInfoStruct.PluginMajorVersion));
    memo1.lines.add('Plugin Minor Version: '+inttostr(PluginHost.PluginExtendedInfoStruct.PluginMinorVersion));
  end;
  memo1.Lines.Add(' ');

  memo1.Lines.Add('[ Parameters ]');
  memo1.Lines.Add(' ');

  setlength(params,0);
  sbParam.Enabled:=false;

  NumParams:=PluginHost.GetNumParameters;
  if NumParams=FF_FAIL then begin
    memo1.Lines.Add('GetNumParameters: ERROR');
    NumParams:=0;
    exit;
  end else begin
    memo1.Lines.Add('Num Parameters: '+inttostr(NumParams));

    if NumParams>0 then begin
      setlength(params,NumParams);
      for i:=0 to NumParams-1 do begin
        Params[i].name:='Unknown';
        Params[i].default:='UnKnown';
        Params[i].displayvalue:='Unknown';
        Params[i].actualvalue:=0;
        Params[i].t:=9999;
      end;

      names:=0;
      try
        text:=PluginHost.GetParameterName(0);
      except
        names:=FF_FAIL;
      end;
      if names=FF_FAIL then memo1.Lines.Add('GetParameterName: ERROR (might not be global)')
      else CollectParamNames;

      try
        result:=PluginHost.GetParameterType(0);
      except
        result:=FF_FAIL;
      end;
      if result=FF_FAIL then memo1.Lines.Add('GetParameterType: ERROR (might not be global)')
      else CollectParamTypes;

      defaults:=0;
      try
        PluginHost.GetParameterDefault(0);
      except
        defaults:=FF_FAIL;
      end;
      if defaults=FF_FAIL then begin
        memo1.Lines.Add('GetParameterDefault: ERROR (might not be global)');
        //skipdefaults:=true;
      end else CollectParamDefaults;
      //memo1.Lines.Add('GetParameterDefault ** Looks like NOBODY ever implemented this - skipping it **');
      //skipdefaults:=true;

      if ((names=0) or (defaults=0)) then begin
        memo1.Lines.Add(' ');
        memo1.Lines.Add('Parameter Details discovered before Instantiating');

        for i:=0 to NumParams-1 do begin
          text:=Params[i].name;
          text:=text+'  t('+paramTypeString(Params[i].t)+')';
          text:=text+'  d('+Params[i].default+')';
          memo1.Lines.Add(text);
        end;

      end;
    end;

  end;
  memo1.Lines.Add(' ');
end;
//------------------------------------------------------------------------------
procedure TfmMain.CollectParamNames;
var
  i:integer;
  text:string;
begin
  memo1.Lines.Add('GetParameter Names');
  for i:=0 to NumParams-1 do begin
    try
      text:=PluginHost.GetParameterName(i);
      Params[i].name:=text;
    except
      memo1.Lines.Add('** Exception during GetParameterName **');
      Params[i].name:='ERROR';
    end;
  end;
end;
//------------------------------------------------------------------------------
procedure TfmMain.CollectParamTypes;
var
  i:integer;
  result:dword;
begin
  memo1.Lines.Add('GetParameter Types');
  for i:=0 to NumParams-1 do begin
    try
      result:=PluginHost.GetParameterType(i);
      Params[i].t:=result;
    except
      memo1.Lines.Add('** Exception during GetParameterType **');
      Params[i].t:=FF_FAIL;
    end;
  end;
end;
function TfmMain.paramTypeString(t:dword):string;
begin
  result:='Unknown';
  case t of
  0: result:='Boolean';
  1: result:='Event';
  2: result:='Red';
  3: result:='Green';
  4: result:='Blue';
  5: result:='XPos';
  6: result:='YPos';
  10: result:='Stanard';
  11: result:='Alpha';
  100: result:='Text';
  FF_FAIL: result:='ERROR';
  end;
end;
//------------------------------------------------------------------------------
procedure TfmMain.CollectParamDefaults;
var
  i:integer;
  s:single;
begin
  memo1.Lines.Add('GetParameter Defaults');
  for i:=0 to NumParams-1 do begin
    try
      if not skipdefaults then begin
        s:=PluginHost.GetParameterDefault(i);
        Params[i].default:=floattostr(s);
      end else begin
        Params[i].default:='no default';
      end;
    except
      memo1.Lines.Add('** Exception during GetParameterDefault **');
      Params[i].default:='ERROR';
    end;
  end;
end;
//------------------------------------------------------------------------------
procedure TfmMain.CollectParamValues;
var
  i:integer;
  s:single;
begin
  memo1.Lines.Add('GetParameter Values');
  for i:=0 to NumParams-1 do begin
    try
      s:=PluginHost.GetParameter(i,PluginInstance);
      Params[i].actualvalue:=s;
    except
      memo1.Lines.Add('** Exception during GetParameter '+inttostr(currentparam)+' **');
      Params[i].actualvalue:=0;
    end;
  end;
end;
//------------------------------------------------------------------------------
procedure TfmMain.CollectParamDisplay;
var
  i:integer;
  text:string;
begin
  memo1.Lines.Add('GetParameterDisplay Values');
  for i:=0 to NumParams-1 do begin
    try
      text:=PluginHost.GetParameterDisplay(i,PluginInstance);
      Params[i].displayvalue:=text;
    except
      memo1.Lines.Add('** Exception during GetParameterDisplay '+inttostr(currentparam)+' **');
      Params[i].displayvalue:='ERROR';
    end;
  end;
end;

//------------------------------------------------------------------------------
function TfmMain.initplugin:dword;
var
  i:integer;
  text:string;
begin
  memo1.Lines.Add('[ Initialsing Plugin ]');
  memo1.Lines.Add(' ');

  result:=PluginHost.InitialisePlugin;
  if result=FF_FAIL then begin
    memo1.Lines.Add('ERROR');
    exit;
  end;
  memo1.Lines.Add('OK');
  memo1.Lines.Add(' ');

  collectInfo;

  memo1.Lines.Add('[ Instantiating a plugin instance ]');
  memo1.Lines.Add(' ');

  if not glplugin then begin
    try
      PluginInstance:=PluginHost.InstantiatePlugin(VideoInfoStruct);
    except
    end;
    if PluginInstance=0 then begin
      memo1.Lines.Add('InstantiatePlugin FAILED');
      exit;
    end;
  end else begin
    InitGL;
    InitTexture(VideoInfoStruct.FrameWidth,VideoInfoStruct.FrameHeight);

    GLViewportStruct.X:=0;
    GLViewportStruct.Y:=0;
    GLViewportStruct.Width:=glPanel.Width;
    GLViewportStruct.Height:=glPanel.Height;

    try
      PluginInstance:=PluginHost.InstantiateGLPlugin(GLViewportStruct);
    except
    end;
    if PluginInstance=0 then begin
      memo1.Lines.Add('InstantiateGLPlugin FAILED');
      exit;
    end;
  end;

  InstanceReady:=true;

  // enable params
  collectParamNames;
  collectParamTypes;
  collectParamDefaults;
  collectParamValues;
  CollectParamDisplay;

  memo1.Lines.Add(' ');
  memo1.Lines.Add('Parameter Details discovered after Instantiating');
  for i:=0 to NumParams-1 do begin
    text:=Params[i].name;
    text:=text+'  t('+paramTypeString(Params[i].t)+')';
    text:=text+'  d('+Params[i].default+')';
    memo1.Lines.Add(text);
  end;
  memo1.Lines.Add(' ');

  lbParams.Clear;
  if NumParams>0 then begin
    currentparam:=0;
    for i:=0 to NumParams-1 do begin
      lbParams.Items.Strings[i]:=Params[i].name+' = '+floattostr(params[i].actualvalue)+'  ('+params[i].displayvalue+')';
    end;
    sbparam.Position:=round(Params[0].actualvalue*100);
    sbparam.Enabled:=true;
    lbpname.Caption:=Params[0].name;
    lbpvalue.Caption:=floattostr(Params[0].actualvalue);
  end;  

  result:=0;
end;
//------------------------------------------------------------------------------
procedure TfmMain.DeInitPlugin;
var
  result:dword;
begin
  if not PluginLoaded then exit;

  // Run down our one instance of this plugin
  if PluginInstance>0 then begin
    try
      result:=PluginHost.DeInstantiatePlugin(PluginInstance);
      if result=FF_FAIL then memo1.Lines.Add('DeInstantiate Plugin ERROR')
      else memo1.Lines.Add('DeInstantiate Plugin OK');
    except
      memo1.Lines.Add('** Exception during DeInstantiate Plugin');
    end;
  end;

  try
    result:=PluginHost.DeInitialisePlugin;
    if result=FF_FAIL then memo1.Lines.Add('DeInitalise Plugin ERROR')
    else memo1.Lines.Add('DeInitalise Plugin OK');
  except
    memo1.Lines.Add('** Exception during DeInitalise Plugin');
  end;

  memo1.Lines.Add('');
end;
//------------------------------------------------------------------------------

procedure TfmMain.DisplayFrame(lpbitmapinfoheader: pbitmapinfoheader; channel: integer);
type
  pdw = ^dword;
var
  hbmp:thandle;
  bits:pdw;
  tempBitmap: TBitmap;
begin
  AHDC := getdc(fmMain.handle);
  try
    // bits is the pointer to the frame of video - the image data starts immediately after the BitmapInfoHeader in a bitmap
    bits := Pointer(Integer(lpBitmapInfoHeader) + sizeof(TBITMAPINFOHEADER));
    hBmp := CreateDIBitmap(ahdc,                  // handle of device context
               lpBitmapInfoHeader^,               // address of bitmap size and format data
               CBM_INIT,                          // initialization flag
               pointer(bits),                     // address of initialization data
               PBITMAPINFO(lpBitmapInfoHeader)^,  // address of bitmap color-format data
               DIB_RGB_COLORS );                  // color-data usage
    tempBitmap:=TBitmap.create;
    try
      tempBitmap.Handle:=hBmp;
      case channel of
        0: with PaintBox1 do Canvas.StretchDraw(rect(0,0,width,height),tempBitmap);
        //1: with PaintBox2 do Canvas.StretchDraw(rect(0,0,width,height),tempBitmap);
      end;  
    finally
      tempBitmap.free;
    end;
  finally
    releaseDC(fmMain.handle,AHDC);
  end;
end;

//------------------------------------------------------------------------------
procedure TfmMain.ProfileAndProcessFrame(pFrame: pointer; PluginInstance: dword);     // This is the main frame processing procedure
var
  before: integer;
  pFrameToProcess: pointer;
  result:dword;
begin

  pFrameToProcess:=pFrame;

  // Convert to 32bit if plugin only does 32bit
  if VideoInfoStruct.BitDepth=2 then begin
    Utils.Convert24to32(pFrameToProcess, p32bitFrame, VideoInfoStruct);
    pFrameToProcess:=p32bitFrame;
  end;

  // Profile Process the Frame ...
  before:=gettickcount;
  result:=0;
  try
    PluginHost.ProcessFrame(pFrameToProcess, PluginInstance); // lpbitmapinfoheader is the current decompressed frame from the mci in the host app
  except
    memo1.Lines.Add('Exception during ProcessFrame');
    result:=FF_FAIL;
  end;
  if result=FF_FAIL then begin
    memo1.Lines.Add('ProcessFrame FAILED');
    if tPlay.Enabled then tplay.Enabled:=false;
  end;
  lProfile.Caption:=inttostr(gettickcount-before)+' msec/frame';

  // Convert it back again if we're running in 32bit plugin
  if VideoInfoStruct.BitDepth=2 then Utils.Convert32to24(p32bitFrame, pFrame, VideoInfoStruct);

end;
//------------------------------------------------------------------------------
procedure TfmMain.ProfileAndProcessGLFrame(pFrame: pointer; PluginInstance: dword);
var
  before: integer;
  pFrameToProcess: pointer;
  ProcessOpenGLStruct:TProcessOpenGLStruct;

  inputTex1:TPluginGLTextureStruct;

  inputTexs:array[0..1] of pointer;
  result:dword;
begin
  pFrameToProcess:=pFrame;

  UploadFrame(pFrameToProcess,VideoInfoStruct.FrameWidth,VideoInfoStruct.FrameHeight);

  // this test bed is only using sq textures (therfore video frame size is same as texture size)
  // and only one input texture

  inputTex1.Width:=tpot;//VideoInfoStruct[0].FrameWidth;
  inputTex1.Height:=tpot;//VideoInfoStruct[0].FrameHeight;
  //inputTex1.Depth:=VideoInfoStruct[0].BitDepth;
  inputTex1.HardwareWidth:=tpot;
  inputTex1.HardwareHeight:=tpot;
  if test32bit then begin
    //inputTex1.HardwareDepth:=4;
    inputTex1.Handle:=tex32bit;
  end else begin
    //inputTex1.HardwareDepth:=3;
    inputTex1.Handle:=tex24bit;
  end;
  
  inputTexs[0]:=@inputTex1;

  ProcessOpenGLStruct.numInputTextures:=1;
  ProcessOpenGLStruct.ppInputTextures:=dword(@inputTexs);
  ProcessOpenGLStruct.HostFBO:=0;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  // Profile Process the Frame ...
  before:=gettickcount;
  try
    result:=PluginHost.ProcessOpenGL(@ProcessOpenGLStruct, PluginInstance);
  except
    memo1.Lines.Add('Exception during ProcessOpenGL');
    result:=FF_FAIL;
  end;
  if result=FF_FAIL then begin
    memo1.Lines.Add('ProcessOpenGL FAILED');
    if tPlay.Enabled then tplay.Enabled:=false;
  end;
  lProfile.Caption:=inttostr(gettickcount-before)+' msec/frame';

end;
//------------------------------------------------------------------------------
// yuk! but does the job for now
procedure TfmMain.tPlayTimer(Sender: TObject);
begin
  if not AVI.AVIopen[0] then exit;
  if not PluginLoaded then exit;
  if not InstanceReady then exit;

  Process;
end;
//------------------------------------------------------------------------------
procedure TfmMain.Process;
var
  pFrameToProcess, pBits: pointer;
  now:double;
  result:dword;
begin
  if InstanceReady then begin

    // if uses setTime then - progress time and tell plugin
    if supportstime then begin
      if cbATime.Checked then begin
        now:=sbATime.Position/1000;
      end else begin
        absoluteTime:=absoluteTime+(40*timeAccel);  // 40msecs= 1frame of 25fps
        now:=absoluteTime/1000;
      end;
      try
        result:=PluginHost.SetTime(now, PluginInstance);
      except
        memo1.Lines.Add('Exception during SetTime');
        bStop.Click;
        exit;
      end;
    end;

    // Get frame from AVI if effect - if source just pass on pointer to framebuffer ...
    inc(currentFrame[0]);
    if currentFrame[0]>(numFrames[0]-1) then currentFrame[0]:=1;
    case plugininfostruct.PluginType of
      0: begin // effect
        lpbitmapinfoheader:=AVI.GetFrame(currentFrame[0],0);
        pBits:=Pointer(Integer(lpBitmapInfoHeader) + sizeof(TBITMAPINFOHEADER));
        pFrameToProcess:=pBits;
      end;
      1: begin // source
        pBits:=Pointer(Integer(lpBitmapInfoHeader) + sizeof(TBITMAPINFOHEADER));
        pFrameToProcess:=pBits;
      end;
    end;

    if not glplugin then begin
      // Process frame through plugin
      if cbPluginProcessFrames.Checked then ProfileAndProcessFrame(pFrameToProcess, PluginInstance);
    end else begin
      // host should set gl to default states
      RefreshGLDisplay;
      ProfileAndProcessGLFrame(pFrameToProcess,PluginInstance);
      SwapBuffers(DC);
    end;

    // Display the frame
    DisplayFrame(lpbitmapinfoheader,0);

  end;

end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function TfmMain.setupPixelFormat(DC:HDC):boolean;
const
   pfd:TPIXELFORMATDESCRIPTOR = (
        nSize:sizeof(TPIXELFORMATDESCRIPTOR);	// size
        nVersion:1;			// version
        dwFlags:PFD_SUPPORT_OPENGL or PFD_DRAW_TO_WINDOW or
                PFD_DOUBLEBUFFER;	// support double-buffering
        iPixelType:PFD_TYPE_RGBA;	// color type
        cColorBits:24;			// preferred color depth
        cRedBits:0; cRedShift:0;	// color bits (ignored)
        cGreenBits:0;  cGreenShift:0;
        cBlueBits:0; cBlueShift:0;
        cAlphaBits:8;  cAlphaShift:0;   // changed to having a alpha buffer
        cAccumBits: 0;
        cAccumRedBits: 0;  		// no accumulation buffer,
        cAccumGreenBits: 0;     	// accum bits (ignored)
        cAccumBlueBits: 0;
        cAccumAlphaBits: 0;
        cDepthBits:24;			// depth buffer
        cStencilBits:0;			// no stencil buffer
        cAuxBuffers:0;			// no auxiliary buffers
        iLayerType:PFD_MAIN_PLANE;  	// main layer
   bReserved: 0;
   dwLayerMask: 0;
   dwVisibleMask: 0;
   dwDamageMask: 0;                    // no layer, visible, damage masks
   );
var pixelFormat:integer;
begin
  result:=false;
  pixelFormat := ChoosePixelFormat(DC, @pfd);
  if (pixelFormat = 0) then exit;
  if (SetPixelFormat(DC, pixelFormat, @pfd) <> TRUE) then exit;
  result:=true;
end;
//------------------------------------------------------------------------------
procedure TfmMain.InitGL;
var
  bmp:TBitmap;
  mem,dst:pointer;
  y:integer;
begin
  DC:=GetDC(glPanel.Handle);        //Actually, you can use any windowed control here
  if not SetupPixelFormat(DC) then begin showmessage('FAILED to create openGL surface');exit;end;
  RC:=wglCreateContext(DC); //makes OpenGL window out of DC
  WglMakeCurrent(DC, RC);

  glViewport(0,0,glPanel.Width,glPanel.Height);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(65,glPanel.Width/glPanel.Height,1.0,-1.0);
  glReadBuffer(GL_BACK);

  glClearColor(0,0,0,0);

  // load and set up background (checks) texture
  if fileexists(exepath+'checks.bmp') then begin
    bmp:=TBitmap.Create;
    try
      bmp.LoadFromFile(exepath+'checks.bmp');
      // copy bits to a temp memory block
      getmem(mem,32*32*3);
      dst:=mem;
      for y:=0 to 31 do begin
        copymemory(dst,bmp.ScanLine[y],32*3);
        dst:=pointer(integer(dst)+(32*3));
      end;
      glGenTextures(1,@checks);
      glBindTexture(GL_TEXTURE_2D,checks);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, 32,32, GL_BGR_EXT, GL_UNSIGNED_BYTE, mem);
    finally
      bmp.Free;
    end;
  end;

  glinit:=true;
end;
//------------------------------------------------------------------------------
// only using nearest POT (power of two) texture sizes
procedure TfmMain.InitTexture(w,h:integer);
begin
  glDeleteTextures(1,@tex24bit);
  glDeleteTextures(1,@tex32bit);

  tpot:=32;         // another global var
  if w>h then begin
    while h>(tpot*2) do tpot:=tpot*2;
  end else begin
    while w>(tpot*2) do tpot:=tpot*2;
  end;

  if assigned(framestore) then freemem(framestore);
  getmem(framestore,tpot*tpot*4);

  glGenTextures(1,@tex24bit);
  glBindTexture(GL_TEXTURE_2D,tex24bit);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, tpot, tpot, GL_BGR_EXT, GL_UNSIGNED_BYTE, framestore);

  glGenTextures(1,@tex32bit);
  glBindTexture(GL_TEXTURE_2D,tex32bit);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, tpot, tpot, GL_BGRA_EXT, GL_UNSIGNED_BYTE, framestore);
end;
//------------------------------------------------------------------------------
// just an quick and DIRTY example (crops to nearest pot)
procedure TfmMain.UploadFrame(bits:pointer;w,h:integer);
var
  src,dst:pointer;
  x,y:integer;
  r,g,b,a:byte;
begin
  // trim it to texture
  if not test32bit then begin
    dst:=framestore;
    for y:=0 to tpot-1 do begin
      src:=pointer(integer(bits)+((w*3)*y));
      copymemory(dst,src,tpot*3);
      dst:=pointer(integer(dst)+tpot*3);
    end;
    glBindTexture(GL_TEXTURE_2D, tex24bit);
    glTexSubImage2D(GL_TEXTURE_2D,0,0,0,tpot,tpot,GL_BGR_EXT,GL_UNSIGNED_BYTE,framestore);
  end else begin
    // insert alpha layer
    dst:=framestore;
    for y:=0 to tpot-1 do begin
      src:=pointer(integer(bits)+((w*3)*y));
      for x:=0 to tpot-1 do begin
        r:=byte(src^);src:=pointer(integer(src)+1);
        g:=byte(src^);src:=pointer(integer(src)+1);
        b:=byte(src^);src:=pointer(integer(src)+1);
        if (x mod 16)<8 then a:=255 else a:=0;
        integer(dst^):=(a shl 24)+(b shl 16)+(g shl 8)+(r);
        dst:=pointer(integer(dst)+4);
      end;
    end;
    glBindTexture(GL_TEXTURE_2D, tex32bit);
    glTexSubImage2D(GL_TEXTURE_2D,0,0,0,tpot,tpot,GL_BGRA_EXT,GL_UNSIGNED_BYTE,framestore);
  end;
end;

//------------------------------------------------------------------------------
procedure TfmMain.RefreshGLDisplay;
begin
  inc(checksangle);if checksangle=360 then checksangle:=0;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  //glOrtho(-1,-1,1,1,1.0,-1.0);  // default?

  // set gl to default states (hmm.. anymore to do? note: this is a simple host so maybe not)
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity;

  glDisable(GL_ALPHA_TEST);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_CULL_FACE);
  glDisable(GL_BLEND);

  glColor4f(1,1,1,1);

  if ((checks>0) and (checksenabled)) then begin
    glTranslatef(0.5,0.5,0.0);
    glRotatef(checksangle,0,0,1);
    glTranslatef(-0.5,-0.5,0.0);
    glBindTexture(GL_TEXTURE_2D,checks);
    glEnable(GL_TEXTURE_2D);
    glBegin(GL_QUADS);
      glTexCoord2f(0,0); glVertex2f(-1,-1);
      glTexCoord2f(1,0); glVertex2f(1,-1);
      glTexCoord2f(1,1); glVertex2f(1,1);
      glTexCoord2f(0,1); glVertex2f(-1,1);
    glEnd();
    glDisable(GL_TEXTURE_2D);
    glLoadIdentity;
  end else begin
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  end;
end;

//------------------------------------------------------------------------------
// GUI EVENTS
//------------------------------------------------------------------------------

procedure TfmMain.cbPluginsChange(Sender: TObject);     // to do: sort out this vs loadnew plugin
begin
  LoadPlugin;
end;

procedure TfmMain.bBrowseClick(Sender: TObject);
var
  inifile: TInifile;
begin
  tPlay.Enabled:=false;
  if odAVI.Execute then begin
    ebAVIfilename.text:=odAVI.FileName;
    inifile:=Tinifile.Create(exepath+'FreeFrame.ini');
    inifile.WriteString('Filenames','CurrentAVI',odAVI.filename);
    inifile.Free;
    loadAVI;
    LoadPlugin;
  end;
end;

procedure TfmMain.bProcessFrameClick(Sender: TObject);
begin
  Process;
end;

procedure TfmMain.bPlayAndProcessClick(Sender: TObject);
begin
  if not AVI.AVIopen[0] then exit;
  if not PluginLoaded then exit;
  if not InstanceReady then exit;

  currentFrame[0]:=0;
  absoluteTime:=0;
  tPlay.Enabled:=true;
end;


procedure TfmMain.sbParamChange(Sender: TObject);
var
  s: single;
  text:string;
begin
  if PluginInstance>0 then begin
    if currentparam=-1 then exit;

    s:=sbParam.position/100;
    try
      PluginHost.SetParameter(currentparam,s,PluginInstance);
      params[currentparam].actualvalue:=s;
    except
      memo1.Lines.Add('Exception during SetParameter '+inttostr(currentparam)+' ('+floattostr(s)+')');
    end;
    try
      text:=GetParameterDisplay(currentparam,PluginInstance);
      params[currentparam].displayvalue:=text;
    except
      memo1.Lines.Add('Exception during GetParameterDisplay '+inttostr(currentparam));
    end;
    if verifyParam then begin
      try
        s:=pluginHost.GetParameter(currentparam,PluginInstance);
        if params[currentparam].actualvalue<>s then memo1.Lines.Add('get value '+floattostr(s)+' is NOT value set '+floattostr(params[currentparam].actualvalue));
      except
        memo1.Lines.Add('Exception during GetParameter '+inttostr(currentparam));
      end;
    end;

    lbParams.Items.Strings[currentparam]:=Params[currentparam].name+' = '+floattostr(params[currentparam].actualvalue)+'  ('+params[currentparam].displayvalue+')';
    lbpvalue.Caption:=floattostr(Params[currentparam].actualvalue)+'  ('+Params[currentparam].displayvalue+')';
  end;
end;

procedure TfmMain.bStopClick(Sender: TObject);
begin
  tPlay.Enabled:=false;
end;

//------------------------------------------------------------------------------
procedure TfmMain.ebAVIFilenameChange(Sender: TObject);
begin
  AVI.AVIfilename:=ebAVIfilename.Text;
end;

procedure TfmMain.lbParamsClick(Sender: TObject);
begin
  if ((lbParams.ItemIndex>-1) and (lbParams.ItemIndex<NumParams)) then begin
    currentparam:=lbParams.ItemIndex;
    lbpname.Caption:=Params[currentparam].name;
    lbpvalue.Caption:=floattostr(Params[currentparam].actualvalue)+'  ('+Params[currentparam].displayvalue+')';
    sbparam.Enabled:=false;
    sbparam.Position:=round(Params[currentparam].actualvalue*100);
    sbparam.Enabled:=true;
  end;
end;

procedure TfmMain.cbVerifyClick(Sender: TObject);
begin
  verifyParam:=cbVerify.checked;
end;

procedure TfmMain.cbTest32BitClick(Sender: TObject);
begin
  test32bit:=cbTest32Bit.checked;
end;

procedure TfmMain.cbCheckersClick(Sender: TObject);
begin
  checksenabled:=cbCheckers.Checked;
end;

procedure TfmMain.btnGrabFrameClick(Sender: TObject);
var
  x,y:integer;
  c:integer;
  src:pointer;
  wasplaying:boolean;
  r,g,b,a:integer;
begin
  wasplaying:=tplay.Enabled;
  if tplay.Enabled then tplay.Enabled:=false;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(0,glpanel.Width,0,glpanel.Height,1.0,-1.0);  // default?
  
  glReadPixels(0,0,glpanel.Width,glpanel.Height,GL_RGBA,GL_UNSIGNED_BYTE,framedump.Memory);
  //framedump.SaveToFile(exepath+'framegrab'+inttostr(glpanel.Width)+'x'+inttostr(glpanel.Height)+'x4.raw');

  // i know its slow but i dont care
  for y:=0 to glpanel.Height-1 do begin
    src:=pointer(integer(framedump.Memory)+((glpanel.width*4)*y));
    for x:=0 to glpanel.Width-1 do begin
      c:=integer(src^);
      a:=(c and $ff000000);
      b:=(c and $ff0000);
      g:=(c and $ff00);
      r:=(c and $ff);
      c:=r+g+b;
      pbRGB.Canvas.Pixels[x,glpanel.Height-y]:=c;
      pbAlpha.Canvas.Pixels[x,glpanel.Height-y]:=(a shr 8)+(a shr 16)+(a shr 24);
      src:=pointer(integer(src)+4);
    end;
  end;

  tplay.Enabled:=wasplaying;
end;


procedure TfmMain.btnReloadClick(Sender: TObject);
begin
  deinitplugin;
  loadplugin;
end;

procedure TfmMain.bDeInitPluginClick(Sender: TObject);
begin
  deinitplugin;
  PluginLoaded:=false;
end;

procedure TfmMain.sbTimeChange(Sender: TObject);
begin
  if sbTime.Position>=0 then begin
    timeAccel:=1+(sbTime.Position*0.1);
    lbTime.Caption:='Time Acceleration ('+FloatToStrF(timeAccel,ffFixed,7,2)+')';
  end else begin
    timeAccel:=1+(sbTime.Position*0.01);
    lbTime.Caption:='Time Acceleration ('+FloatToStrF(timeAccel,ffFixed,7,2)+')';
  end;
end;

end.
