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

unit UGDBPoint3DArray;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,UGDBOpenArrayOfData,sysutils,uzbtypes,uzbmemman,math,
     uzegeometry;
type
{REGISTEROBJECTTYPE GDBPoint3dArray}
{Export+}
PGDBPoint3dArray=^GDBPoint3dArray;
GDBPoint3dArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                function onpoint(p:gdbvertex;closed:GDBBoolean):gdbboolean;
                function onmouse(const mf:ClipArray;const closed:GDBBoolean):GDBBoolean;virtual;
                function CalcTrueInFrustum(frustum:ClipArray):TInBoundingVolume;virtual;
                procedure DrawGeometry;virtual;
                procedure DrawGeometry2;virtual;
                procedure DrawGeometryWClosed(closed:GDBBoolean);virtual;
                function getoutbound:TBoundingBox;virtual;
             end;
{Export-}
implementation
uses uzgloglstatemanager;
function GDBPoint3DArray.getoutbound;
var
    t,b,l,r,n,f:GDBDouble;
    ptv:pgdbvertex;
    ir:itrec;
begin
  l:=Infinity;
  b:=Infinity;
  n:=Infinity;
  r:=NegInfinity;
  t:=NegInfinity;
  f:=NegInfinity;
  ptv:=beginiterate(ir);
  if ptv<>nil then
  begin
  repeat
        if ptv.x<l then
                 l:=ptv.x;
        if ptv.x>r then
                 r:=ptv.x;
        if ptv.y<b then
                 b:=ptv.y;
        if ptv.y>t then
                 t:=ptv.y;
        if ptv.z<n then
                 n:=ptv.z;
        if ptv.z>f then
                 f:=ptv.z;
        ptv:=iterate(ir);
  until ptv=nil;
  result.LBN:=CreateVertex(l,B,n);
  result.RTF:=CreateVertex(r,T,f);

  end
              else
  begin
  result.LBN:=CreateVertex(-1,-1,-1);
  result.RTF:=CreateVertex(1,1,1);
  end;
end;

procedure GDBPoint3DArray.drawgeometry;
var p:PGDBVertex;
    i:GDBInteger;
begin
  if count<2 then exit;
  p:=parray;
  oglsm.myglbegin(GL_LINES{_STRIP});
  oglsm.myglVertex3dV(@p^);
  inc(p);
  for i:=0 to count-3 do
  begin
     oglsm.myglVertex3dV(@p^);
     oglsm.myglVertex3dV(@p^);

     inc(p);
  end;
  oglsm.myglVertex3dV(@p^);
  oglsm.myglend;
end;
procedure GDBPoint3DArray.drawgeometry2;
var p:PGDBVertex;
    i:GDBInteger;
begin
  if count<2 then exit;
  p:=parray;
  oglsm.myglbegin(GL_LINE_STRIP);
  oglsm.myglVertex3dV(@p^);
  inc(p);
  for i:=0 to count-3 do
  begin
     oglsm.myglVertex3dV(@p^);
     //oglsm.myglVertex3dV(@p^);

     inc(p);
  end;
  oglsm.myglVertex3dV(@p^);
  oglsm.myglend;
end;
procedure GDBPoint3DArray.DrawGeometryWClosed(closed:GDBBoolean);
var p:PGDBVertex;
    i:GDBInteger;
begin
  if closed then
  begin
  if count<2 then exit;
  p:=parray;
  oglsm.myglbegin(GL_LINES{_STRIP});
  oglsm.myglVertex3dV(@p^);
  inc(p);
  for i:=0 to count-3 do
  begin
     oglsm.myglVertex3dV(@p^);
     oglsm.myglVertex3dV(@p^);

     inc(p);
  end;
  oglsm.myglVertex3dV(@p^);
  oglsm.myglVertex3dV(@p^);
  oglsm.myglVertex3dV(@parray^);

  oglsm.myglend;
  end
     else drawgeometry;
end;
function GDBPoint3DArray.CalcTrueInFrustum;
var i,{counter,}emptycount:GDBInteger;
//    d:GDBDouble;
    ptpv0,ptpv1:PGDBVertex;
    subresult:TInBoundingVolume;
begin
   //result:=IREmpty;
   emptycount:=0;
   ptpv0:=parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   i:=0;
   while i<(count-1) do
   begin
     subresult:=uzegeometry.CalcTrueInFrustum (ptpv0^,ptpv1^,frustum);
    if subresult=IREmpty then
                            begin
                                 inc(emptycount);
                            end;
     if subresult=IRPartially then
                                  begin
                                       result:=IRPartially;
                                       exit;
                                  end;
     if (subresult=IRFully)and(emptycount>0) then
                                  begin
                                       result:=IRPartially;
                                       exit;
                                  end;

      inc(i);
      inc(ptpv1);
      inc(ptpv0);
   end;
     if emptycount=0 then
                       result:=IRFully
                     else
                       result:=IREmpty;
end;
function GDBPoint3DArray.onmouse;
var i{,counter}:GDBInteger;
//    d:GDBDouble;
    ptpv0,ptpv1:PGDBVertex;
begin
  result:=false;
   ptpv0:=parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   i:=0;
   while i<(count-1) do
   begin
     if uzegeometry.CalcTrueInFrustum (ptpv0^,ptpv1^,mf)<>IREmpty
                                                                          then
                                                                              result:=true
                                                                          else
                                                                              result:=false;
     if result then
     begin
          exit;
     end;
     begin
                            inc(i);
                            inc(ptpv1);
                            inc(ptpv0);
                       end;
   end;
   if closed then
   begin
        ptpv1:=parray;
   if uzegeometry.CalcTrueInFrustum (ptpv0^,ptpv1^,mf)<>IREmpty
                                                                        then
                                                                            result:=true
                                                                        else
                                                                            result:=false;
   end;
end;

function GDBPoint3DArray.onpoint(p:gdbvertex;closed:GDBBoolean):gdbboolean;
var i{,counter}:GDBInteger;
    d:GDBDouble;
    ptpv0,ptpv1:PGDBVertex;
    a,b:integer;
begin
   result:=false;
   ptpv0:=parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   i:=0;
   if closed then
                 a:=count
             else
                 a:=count-1;
   b:=count-1;
   while i<a do
   begin
     d:=SQRdist_Point_to_Segment(p,ptpv0^,ptpv1^);
     if d<=bigeps then
     begin
          result:=true;
          exit;
     end;
     begin
                            inc(i);
                            inc(ptpv1);
                            inc(ptpv0);
                            if i=b then
                                       ptpv1:=parray;
     end;
   end;
end;
constructor GDBPoint3DArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(gdbvertex));
end;
constructor GDBPoint3DArray.initnul;
begin
  inherited initnul;
  size:=sizeof(gdbvertex);
end;
begin
end.

