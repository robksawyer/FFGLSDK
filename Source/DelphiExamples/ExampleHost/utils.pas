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

unit utils;

interface

uses windows, pluginHost, sysutils, forms, ffstructs;

const
  msd=1000*60*60*24;  //miliseconds in a day - useful for timer intervals and tdatetimes

function Make32bitBuffer(VideoInfoStruct: TVideoInfoStruct): pointer;
function Convert24to32(pSourceFrame, pDestFrame: pointer; VideoInfoStruct: TVideoInfoStruct): dword;
function Convert32to24(pSourceFrame, pDestFrame: pointer; VideoInfoStruct: TVideoInfoStruct): dword;
function Free32bitBuffer(pFrame: pointer; VideoInfoStruct: TVideoInfoStruct): dword;
procedure SetDelay(delayTime:integer);

implementation

uses main;

function Make32bitBuffer(VideoInfoStruct: TVideoInfoStruct): pointer;
var
  tempPointer: pointer;
  FrameSize: integer;
begin
  FrameSize:=VideoInfoStruct.FrameWidth*VideoInfoStruct.FrameWidth;
  GetMem(tempPointer,FrameSize*4);
  Result:=tempPointer;
end;

function Convert24to32(pSourceFrame, pDestFrame: pointer; VideoInfoStruct: TVideoInfoStruct): dword;
var
  i: integer;
  pSource, pDest: pByte;
  FrameSize: integer;  // in pixels
begin
  FrameSize:=VideoInfoStruct.FrameWidth*VideoInfoStruct.FrameHeight;
  pSource:=pByte(pSourceFrame);
  pDest:=pByte(pDestFrame);
  for i:=0 to FrameSize-2 do begin
    pDest^:=pSource^;
    inc(pSource);
    inc(pDest);
    pDest^:=pSource^;
    inc(pSource);
    inc(pDest);
    pDest^:=pSource^;
    inc(pSource);
    inc(pDest);
    inc(pDest);
  end;
  Result:=0;
end;

function Convert32to24(pSourceFrame, pDestFrame: pointer; VideoInfoStruct: TVideoInfoStruct): dword;
var
  i: integer;
  pSource, pDest: pByte;
  FrameSize: integer;  // in pixels
begin
  FrameSize:=VideoInfoStruct.FrameWidth*VideoInfoStruct.FrameHeight;
  pSource:=pByte(pSourceFrame);
  pDest:=pByte(pDestFrame);
  for i:=0 to FrameSize-2 do begin
    pDest^:=pSource^;
    inc(pSource);
    inc(pDest);
    pDest^:=pSource^;
    inc(pSource);
    inc(pDest);
    pDest^:=pSource^;
    inc(pSource);
    inc(pDest);
    inc(pSource);
  end;
  Result:=0;
end;

function Free32bitBuffer(pFrame: pointer; VideoInfoStruct: TVideoInfoStruct): dword;
begin
  FreeMem(pFrame,VideoInfoStruct.FrameWidth*VideoInfoStruct.FrameHeight*4);
  Result:=0;
end;

procedure SetDelay(delayTime:integer);
var
  starttime,interval:tdatetime;
begin
  starttime:=now;
  interval:=delaytime/msd;
  while starttime+interval>now do begin
    application.processmessages; // note: only for running on the main thread
    sleep(1);
  end;
end;

end.
