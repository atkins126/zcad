{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzglabstractdrawer;
{$INCLUDE def.inc}
interface
uses UGDBOpenArrayOfData,uzgprimitivessarray,OGLSpecFunc,Graphics,gdbase;
type
TZGLAbstractDrawer=class
                        public
                        PVertexBuffer:PGDBOpenArrayOfData;
                        procedure DrawLine(const i1:TLLVertexIndex);virtual;abstract;
                        procedure DrawPoint(const i:TLLVertexIndex);virtual;abstract;
                        procedure startrender;virtual;
                        procedure endrender;virtual;

                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);overload;virtual;abstract;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:single);overload;virtual;abstract;
                        procedure DrawClosedPolyLine2DInDCS(const coords:array of single);overload;virtual;abstract;
                   end;
var
  testrender:TZGLAbstractDrawer;
implementation
uses log;
procedure TZGLAbstractDrawer.startrender;
begin
end;
procedure TZGLAbstractDrawer.endrender;
begin
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('uzglabstractdrawer.initialization');{$ENDIF}
end.

