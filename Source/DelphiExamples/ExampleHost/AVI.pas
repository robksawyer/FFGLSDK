// FreeFrame Open Video Plugin Test Container
//  and Delphi Host Inclusion Template

// www.freeframe.org
// boblists@brightonart.org

{

Copyright (c) 2002, Russell Blakeborough
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

unit AVI;

interface

uses VFW, pluginHost, winprocs, ffstructs;

var
  AVIfilename: string;
  AVIopen: array [0..1] of boolean;

procedure Init;
procedure DeInit;
function OpenAVI(Filename: string; channel: integer): Tvideoinfostruct;
procedure CloseAVI(channel: integer);
function GetFrame(FrameNumber: integer; channel: integer): pointer;

implementation

uses main, utils;

var
  pAnAviFile: array [0..1] of PAviFile;          // The Avi File
  pVideoStream: array [0..1] of pAviStream;      // Pointer to Video Stream
  AGetframe: array [0..1] of pGetFrame;          // Pointer to GetFrame struct
  HDrawDibDC: HDrawDib;          // HDrawdib

procedure Init;
begin
  AVIfileInit;
end;

procedure DeInit;
begin
  AviFileExit;
end;

function OpenAVI(Filename: string; channel: integer): Tvideoinfostruct;
var
  i: integer;
  pFileInfo: TAviFileInfo;
  pAnAviStream: pAviStream;
  StreamInfo: TAviStreamInfo;
  tempVideoinfostruct: Tvideoinfostruct;
begin
  try
    AVIFileOpen(pAnAviFile[channel], pchar(Filename), OF_READ, Nil);
    AVIFileInfo(pAnAviFile[channel], @pFileInfo, sizeof(TAviFileInfo));
    for i := 0 to pFileInfo.dwstreams -1 do begin
      AVIFileGetStream(pAnAviFile[channel], pAnAviStream, 0, i);
      AVIStreamInfo(pAnAviStream, @StreamInfo, sizeof(TAviStreamInfo));
      if (StreamInfo.fccType = streamtypeVIDEO) then begin
        pVideoStream[channel] := pAnAviStream;
        //fps := round(StreamInfo.dwRate /StreamInfo.dwScale);
        if hDrawDibDC<>0 then DrawDibOpen();
        AGetFrame[channel] := AVIStreamGetFrameOpen(pVideoStream[channel],nil);
        tempVideoInfoStruct.Framewidth:=streaminfo.rcFrame.Right;
        tempVideoInfoStruct.FrameHeight:=streaminfo.rcFrame.Bottom;
        // 1=24bit packed MCI standard
        // 2=32bit video, or 24bit dword aligned for the moment really, with Alpha running at 0
        if VideoInfoStruct.BitDepth=2 then tempVideoInfoStruct.BitDepth:=2 else tempVideoInfoStruct.BitDepth:=1;        // todo: not sure about this any more
        // Set Orientation Upsidedown
        tempVideoInfoStruct.orientation:=2;
        numframes[channel] := AVIStreamEnd(pVideoStream[channel]);
        AVIopen[channel]:=true;
        CurrentFrame[0]:=0;
        result:=tempVideoInfoStruct;
      end;
    end;
  except
  end;
end;

procedure CloseAVI(channel: integer);
begin
  //utils.setdelay(100);
  if AGetframe[channel] <> nil then AVIStreamGetFrameClose(AGetFrame[channel]);
  //utils.setdelay(100);
  if HDrawDibDC <> 0 then DrawDibClose(hDrawDibDC);
  //utils.setdelay(100);
  if pVideoStream[channel] <> nil then AVIStreamRelease(pVideoStream[channel]);
  //utils.setdelay(100);
  if pAnAviFile[channel] <> nil then AviFileRelease(pAnAviFile[channel]);
  AVIopen[channel]:=false;
end;

function GetFrame(FrameNumber: integer; channel: integer): pointer;
begin
  result := AVIStreamGetFrame(AGetframe[channel], FrameNumber);
end;

initialization
  AVIopen[0]:=false;
  AVIopen[1]:=false;

end.
