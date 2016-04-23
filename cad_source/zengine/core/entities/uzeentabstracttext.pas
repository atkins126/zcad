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
unit uzeentabstracttext;
{$INCLUDE def.inc}

interface
uses uzglviewareageneral,uzgldrawcontext,uzeentity,uzecamera,uzctnrvectorpdata,
     uzbstrproc,sysutils,uzeentplainwithox,uzbtypesbase,UGDBSelectedObjArray,uzbtypes,
     uzeconsts,uzegeometry,math;
type
//jstm(*'TopCenter'*)=2,
{EXPORT+}
PGDBTextProp=^GDBTextProp;
GDBTextProp=packed record
                  size:GDBDouble;(*saved_to_shd*)
                  oblique:GDBDouble;(*saved_to_shd*)
                  wfactor:GDBDouble;(*saved_to_shd*)
                  angle:GDBDouble;(*saved_to_shd*)
                  justify:TTextJustify;(*saved_to_shd*)
                  upsidedown:GDBBoolean;
                  backward:GDBBoolean;
            end;
PGDBObjAbstractText=^GDBObjAbstractText;
GDBObjAbstractText={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjPlainWithOX)
                         textprop:GDBTextProp;(*saved_to_shd*)
                         P_drawInOCS:GDBvertex;(*saved_to_shd*)(*oi_readonly*)(*hidden_in_objinsp*)
                         DrawMatrix:DMatrix4D;(*oi_readonly*)(*hidden_in_objinsp*)
                         //Vertex3D_in_WCS_Array:GDBPolyPoint3DArray;(*oi_readonly*)(*hidden_in_objinsp*)
                         procedure CalcObjMatrix;virtual;
                         procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                         procedure SimpleDrawGeometry(var DC:TDrawContext);virtual;
                         procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                         function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble):GDBBoolean;virtual;
                         function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                         function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray;InSubEntry:GDBBoolean):GDBBoolean;virtual;
                         //function InRect:TInRect;virtual;
                         procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                         procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                         procedure ReCalcFromObjMatrix;virtual;
                         procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;
                         procedure setrot(r:GDBDouble);
                         procedure transform(const t_matrix:DMatrix4D);virtual;
                   end;
{EXPORT-}
implementation
//uses
//   log;
procedure GDBObjAbstractText.transform;
var tv{,tv2}:GDBVertex;
   m:DMatrix4D;
begin

  {m:=onematrix;
  m[0,0]:=textprop.size;
  m:=uzegeometry.MatrixMultiply(m,t_matrix);}
  tv:=NulVertex;
  tv.x:=textprop.size;
  m:=t_matrix;
  PGDBVertex(@m[3])^:=NulVertex;

  tv:=VectorTransform3d(tv,m);
  textprop.size:=oneVertexlength(tv);
  {textprop.size:=m[0,0];}

  inherited;
end;
procedure GDBObjAbstractText.setrot(r:GDBDouble);
var m1:DMatrix4D;
begin
m1:=onematrix;
m1[0,0]:=cos(r);
m1[1,1]:=cos(r);
m1[1,0]:=-sin(r);
m1[0,1]:=sin(r);
objMatrix:=MatrixMultiply(m1,objMatrix);
end;
procedure GDBObjAbstractText.FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);
var
   r:double;
   ox:gdbvertex;
   {m,}m2,m3:DMAtrix4D;
begin
     if PField=@textprop.angle then
                                   begin
                                        //m:=self.CalcObjMatrixWithoutOwner;
                                        m2:=self.getownermatrix^;
                                        m3:=m2;
                                        matrixinvert(m3);
                                        objMatrix:=MatrixMultiply(m3,objMatrix);
                                        if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                                                       ox:=CrossVertex(YWCS,{PGDBVertex(@m[2])^}Local.basis.oz)
                                                                                                   else
                                                                                                       ox:=CrossVertex(ZWCS,{PGDBVertex(@m[2])^}Local.basis.oz);
                                        r:=scalardot({PGDBVertex(@m[0])^}Local.basis.ox,ox);
                                        r:=arccos(r);
                                        setrot(-r);
                                        r:=textprop.angle;
                                        setrot(textprop.angle);
                                        ReCalcFromObjMatrix;
                                        objMatrix:=MatrixMultiply(m2,objMatrix);
                                        textprop.angle:=r;
                                   end;
     inherited;
end;

procedure GDBObjAbstractText.ReCalcFromObjMatrix;
var
    ox:gdbvertex;
begin
     inherited;
     Local.basis.ox:=PGDBVertex(@objmatrix[0])^;
     Local.basis.oy:=PGDBVertex(@objmatrix[1])^;

     Local.basis.ox:=normalizevertex(Local.basis.ox);
     Local.basis.oy:=normalizevertex(Local.basis.oy);
     Local.basis.oz:=normalizevertex(Local.basis.oz);

     Local.P_insert:=PGDBVertex(@objmatrix[3])^;

     {scale.x:=PGDBVertex(@objmatrix[0])^.x/local.OX.x;
     scale.y:=PGDBVertex(@objmatrix[1])^.y/local.Oy.y;
     scale.z:=PGDBVertex(@objmatrix[2])^.z/local.Oz.z;}

     if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                    ox:=CrossVertex(YWCS,Local.basis.oz)
                                                                else
                                                                    ox:=CrossVertex(ZWCS,Local.basis.oz);
     normalizevertex(ox);
     textprop.angle:=scalardot(Local.basis.ox,ox);
     textprop.angle:=arccos(textprop.angle);
     if local.basis.OX.y<-eps then textprop.angle:=2*pi-textprop.angle;
     //Local.basis.ox:=ox;
end;

procedure GDBObjAbstractText.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
                    case pdesc^.pointtype of
                    os_point:begin
          pdesc.worldcoord:=P_insert_in_WCS;//Local.P_insert;
          pdesc.dispcoord.x:=round(ProjP_insert.x);
          pdesc.dispcoord.y:=round(ProjP_insert.y);
                             end;
                    end;
end;
procedure GDBObjAbstractText.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{5A458E80-F735-432A-8E6D-85B580F5F0DC}',{$ENDIF}1);
          pdesc.selected:=false;
          pdesc.pobject:=nil;
          pdesc.pointtype:=os_point;
          pdesc.worldcoord:=P_insert_in_WCS;//Local.P_insert;
          {pdesc.dispcoord.x:=round(ProjP_insert.x);
          pdesc.dispcoord.y:=round(ProjP_insert.y);}
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;
(*function GDBObjAbstractText.InRect;
//var i:GDBInteger;
//    ptpv:PGDBPolyVertex2D;
begin
     if pprojoutbound<>nil then
     if self.pprojoutbound^.inrect=IRFully then
     begin
          result:=IRFully;
          exit;
     end;
     //if POGLWnd^.seldesc.MouseFrameInverse then
     {if Vertex2D_in_DCS_Array.inrect=IRPartially then
     begin
          result:=IRPartially;
          exit;
     end;}
     result:=IREmpty;
end;*)
function GDBObjAbstractText.onmouse;
var //i,counter:GDBInteger;
    //d:GDBDouble;
    //ptpv0,ptpv1:PGDBPolyVertex3D;
    subresult:TInBoundingVolume;
begin
  result:=false;
  {if pprojoutbound^.count<4 then exit;
  i:=pprojoutbound^.onmouse;
  if i=2 then
     begin
          result:=true;
          exit;
     end;
   if i=0 then
              exit;}
    subresult:=CalcOutBound4VInFrustum(outbound,mf);
    if subresult<>IRPartially then
                               if subresult=irempty then
                                                        exit
                                                    else
                                                        begin
                                                             result:=true;
                                                             exit;
                                                        end;

    if geom.CalcTrueInFrustum (mf,false)<>IREmpty then
                                                 result:=true
                                             else
                                                 result:=false;

   {if Vertex3D_in_WCS_Array.count<2 then exit;
   ptpv0:=Vertex3D_in_WCS_Array.parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   counter:=0;
   i:=0;
   while i<(Vertex3D_in_WCS_Array.count-1) do
   begin
     if counter<=0 then counter:=ptpv0^.count;
     if uzegeometry.CalcTrueInFrustum (ptpv1^.coord,ptpv0^.coord,mf)<>IREmpty
                                                                          then
                                                                              result:=true
                                                                          else
                                                                              result:=false;
     if result then
                   exit;
     if counter<=0 then
                       begin
                            i:=i+2;
                            inc(ptpv1,2);
                            inc(ptpv0,2);
                       end
                   else
                       begin
                            inc(i);
                            dec(counter);
                            inc(ptpv1);
                            inc(ptpv0);
                       end;
   end;}
end;
function GDBObjAbstractText.CalcInFrustum;
var i:GDBInteger;
begin
      result:=true;
      for i:=0 to 4 do
      begin
      if(frustum[i][0] * outbound[0].x + frustum[i][1] * outbound[0].y + frustum[i][2] * outbound[0].z + frustum[i][3] < 0 )
      and(frustum[i][0] * outbound[1].x + frustum[i][1] * outbound[1].y + frustum[i][2] * outbound[1].z + frustum[i][3] < 0 )
      and(frustum[i][0] * outbound[2].x + frustum[i][1] * outbound[2].y + frustum[i][2] * outbound[2].z + frustum[i][3] < 0 )
      and(frustum[i][0] * outbound[3].x + frustum[i][1] * outbound[3].y + frustum[i][2] * outbound[3].z + frustum[i][3] < 0 )
      then
      begin
           result:=false;
           system.break;
      end;
      end;
end;
function GDBObjAbstractText.CalcTrueInFrustum;
//var i,count:GDBInteger;
//    d1,d2,d3,d4:gdbdouble;
begin
      result:=CalcOutBound4VInFrustum(outbound,frustum);
      if result<>IRPartially then
                                 exit;
      result:=geom.CalcTrueInFrustum(frustum,true);
end;
procedure GDBObjAbstractText.Renderfeedback;
var //pm:DMatrix4D;
    tv:GDBvertex;
begin
           inherited;
           //myGluProject(Local.p_insert.x,Local.p_insert.y,Local.p_insert.z,@gdb.pcamera^.modelMatrix,@gdb.pcamera^.projMatrix,@gdb.pcamera^.viewport,ProjP_insert.x,ProjP_insert.y,ProjP_insert.z);
           //pprojoutbound^.clear;
           //pm:=gdb.GetCurrentDWG.pcamera^.modelMatrix;
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(outbound[0],tv);
           pprojoutbound^.addgdbvertex(tv);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(outbound[1],tv);
           pprojoutbound^.addgdbvertex(tv);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(outbound[2],tv);
           pprojoutbound^.addgdbvertex(tv);
           {gdb.GetCurrentDWG^.myGluProject2}ProjectProc(outbound[3],tv);
           pprojoutbound^.addlastgdbvertex(tv);
           //if (pprojoutbound^.count<4) then visible:=false;
           {if (projoutbound[0].x=projoutbound[1].x) and (projoutbound[0].y=projoutbound[1].y) then visible:=false;
           if (projoutbound[1].x=projoutbound[2].x) and (projoutbound[1].y=projoutbound[2].y) then visible:=false;
           if (projoutbound[2].x=projoutbound[3].x) and (projoutbound[2].y=projoutbound[3].y) then visible:=false;
           if (projoutbound[3].x=projoutbound[0].x) and (projoutbound[3].y=projoutbound[0].y) then visible:=false;}
           if pprojoutbound^.count<4 then
           begin
            lod:=1;
           end
           else
           begin
                lod:=0;
           end;
           //projectpoint;
end;
procedure GDBObjAbstractText.CalcObjMatrix;
var m1,m2,m3:DMatrix4D;
    angle:GDBDouble;
begin
  inherited CalcObjMatrix;
  if textprop.upsidedown then
  begin
        PGDBVertex(@objmatrix[1])^.x:=-Local.basis.oy.x;
        PGDBVertex(@objmatrix[1])^.y:=-Local.basis.oy.y;
        PGDBVertex(@objmatrix[1])^.z:=-Local.basis.oy.z;
  end;
  if textprop.backward then
  begin
        PGDBVertex(@objmatrix[0])^.x:=-Local.basis.ox.x;
        PGDBVertex(@objmatrix[0])^.y:=-Local.basis.ox.y;
        PGDBVertex(@objmatrix[0])^.z:=-Local.basis.ox.z;
  end;
  m1:= OneMatrix;

  {m1[0,0]:=cos(self.textprop.angle*pi/180);
  m1[1,1]:=cos(self.textprop.angle*pi/180);
  m1[1,0]:=-sin(self.textprop.angle*pi/180);
  m1[0,1]:=sin(self.textprop.angle*pi/180);}
  objMatrix:=MatrixMultiply(m1,objMatrix);




  m1:= OneMatrix;
  //angle:=pi/2 - textprop.oblique*(pi/180);
  angle:=(pi/2 - textprop.oblique);
  if angle<>pi/2 then
                     begin
                          m1[1, 0] :=cotan(angle);//1/tan(angle)
                     end
                else
                   m1[1, 0] := 0;
  m2:= OneMatrix;
  Pgdbvertex(@m2[3])^:=P_drawInOCS;
  m3:=OneMatrix;
  m3[0, 0] := textprop.wfactor*textprop.size;
  m3[1, 1] := textprop.size;
  m3[2, 2] := textprop.size;
  {DrawMatrix:=MatrixMultiply(m1,m3);
  DrawMatrix:=MatrixMultiply(DrawMatrix,m2);}
  DrawMatrix:=MatrixMultiply(m3,m1);
  DrawMatrix:=MatrixMultiply(DrawMatrix,m2);
end;
procedure GDBObjAbstractText.SimpleDrawGeometry;
begin
     //geom.SHX.simpledrawgeometry(dc,1);
end;

procedure GDBObjAbstractText.DrawGeometry;
var
   PanObjectDegradation:boolean;
begin
  dc.subrender := dc.subrender + 1;
  PanObjectDegradation:=SysVarRDPanObjectDegradation;
  if {true//}(((not {GDB.GetCurrentDWG.OGLwindow1.param.scrollmode}dc.scrollmode)or(not PanObjectDegradation)) {and (lod=0)})
  then
      begin
           (*templod:=sqrt(objmatrix[0,0]*objmatrix[0,0]+objmatrix[1,1]*objmatrix[1,1]+objmatrix[2,2]*objmatrix[2,2]);
           templod:=(templod*self.textprop.size)/({GDB.GetCurrentDWG.pcamera.prop}dc.zoom{*GDB.GetCurrentDWG.pcamera.prop.zoom});
           //_lod:=round({self.textprop.size/}10*GDB.GetCurrentDWG.pcamera.prop.zoom*GDB.GetCurrentDWG.pcamera.prop.zoom+1);
           if ({(self.textprop.size/GDB.GetCurrentDWG.pcamera.prop.zoom)}templod>1.5{0.04}{0.2})or(dc.maxdetail) then*)
           if CanSimplyDrawInOCS(DC,self.textprop.size,1.5) then

                                                                                   //Vertex3D_in_WCS_Array.simpledrawgeometry({_lod}3)
                                                                                   //simpledrawgeometry
                                                                                   begin
                                                                                   //geom.SHX.drawgeometry;
                                                                                   geom.DrawGeometry(DC);
                                                                                   end
                                                                               else
                                                                                   geom.DrawGeometry(DC);
                                                                                   //simpledrawgeometry(dc);
                                                                                     {begin
                                                                                           myglbegin(gl_line_loop);
                                                                                           myglvertex3dv(@outbound[0]);
                                                                                           myglvertex3dv(@outbound[1]);
                                                                                           myglvertex3dv(@outbound[2]);
                                                                                           myglvertex3dv(@outbound[3]);
                                                                                           myglend;
                                                                                      end;}
           {myglbegin(gl_points);
           Vertex3D_in_WCS_Array.iterategl(@myglvertex3dv);
           myglend;}
      end
  else
  begin
       DC.Drawer.DrawLine3DInModelSpace(outbound[0],outbound[1],DC.DrawingContext.matrixs);
       DC.Drawer.DrawLine3DInModelSpace(outbound[1],outbound[2],DC.DrawingContext.matrixs);
       DC.Drawer.DrawLine3DInModelSpace(outbound[2],outbound[3],DC.DrawingContext.matrixs);
       DC.Drawer.DrawLine3DInModelSpace(outbound[3],outbound[0],DC.DrawingContext.matrixs);
  end;
  dc.subrender := dc.subrender - 1;
  inherited;
end;
begin
end.
