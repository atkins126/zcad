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

unit gdbcommandsinterface;
{$INCLUDE def.inc}

interface
uses
 colorwnd,dswnd,ltwnd,tswnd,uinfoform,UGDBFontManager,ugdbsimpledrawing,GDBCommandsBase,zcadsysvars,commandline,TypeDescriptors,GDBManager,zcadstrconsts,UGDBStringArray,ucxmenumgr,{$IFNDEF DELPHI}intftranslations,{$ENDIF}layerwnd,{strutils,}strproc,umytreenode,menus, {$IFDEF FPC}lcltype,{$ENDIF}
 LCLProc,Classes,{ SysUtils,} FileUtil,{ LResources,} Forms, {stdctrls,} Controls, {Graphics, Dialogs,}ComCtrls,Clipbrd,lclintf,
  plugins,OGLSpecFunc,
  sysinfo,
  //commandline,
  commandlinedef,
  commanddefinternal,
  gdbase,
  UGDBDescriptor,
  sysutils,
  varmandef,
  //oglwindowdef,
  //OGLtypes,
  UGDBOpenArrayOfByte,
  iodxf,iodwg,
  //optionswnd,
  {objinsp,}
   zcadinterface,
  //cmdline,
  //UGDBVisibleOpenArray,
  //gdbobjectsconstdef,
  GDBEntity,
 shared,
 UGDBEntTree,
  {zmenus,}projecttreewnd,gdbasetypes,{optionswnd,}AboutWnd,HelpWnd,memman,WindowsSpecific,{txteditwnd,}
 {messages,}UUnitManager,{zguisct,}log,Varman,UGDBNumerator,cmdline,
 AnchorDocking,dialogs,XMLPropStorage,xmlconf,openglviewarea{,
   uPSCompiler,
  uPSRuntime,
  uPSC_std,
  uPSC_controls,
  uPSC_stdctrls,
  uPSC_forms,
  uPSR_std,
  uPSR_controls,
  uPSR_stdctrls,
  uPSR_forms,
  uPSUtils};



   {procedure startup;
   procedure finalize;}
   {var selframecommand:PCommandObjectDef;
       ms2objinsp:PCommandObjectDef;
       deselall,selall:pCommandFastObjectPlugin;

       MSEditor:TMSEditor;

       InfoFormVar:TInfoForm=nil;

       MSelectCXMenu:TmyPopupMenu=nil;

   function SaveAs_com(Operands:pansichar):GDBInteger;
   procedure CopyToClipboard;}
   function quit_com(Operands:pansichar):GDBInteger;
   function layer_cmd:GDBInteger;
   function Colors_cmd:GDBInteger;
   //function Regen_com(Operands:pansichar):GDBInteger;
//var DWGPageCxMenu:pzpopupmenu;
implementation
uses GDBPolyLine,UGDBPolyLine2DArray,GDBLWPolyLine,mainwindow,UGDBSelectedObjArray,
     oglwindow,geometry;
function CloseDWG_com(Operands:pansichar):GDBInteger;
var
   //poglwnd:toglwnd;
   CurrentDWG:PTDrawing;
begin
  application.ProcessMessages;
  CurrentDWG:=PTDrawing(gdb.GetCurrentDWG);
  _CloseDWGPage(CurrentDWG,mainformn.PageControl.ActivePage);
  (*if CurrentDWG<>nil then
  begin
       if CurrentDWG.Changed then
                                 begin
                                      if MainFormN.MessageBox(@rsCloseDWGQuery[1],@rsWarningCaption[1],MB_YESNO)<>IDYES then exit;
                                 end;
       poglwnd:=CurrentDWG.OGLwindow1;
       //mainform.PageControl.delpage(mainform.PageControl.onmouse);
       gdb.eraseobj(CurrentDWG);
       gdb.pack;
       poglwnd.PDWG:=nil;
       gdb.CurrentDWG:=nil;

       poglwnd.free;

       mainformn.PageControl.ActivePage.Free;
       tobject(poglwnd):=mainformn.PageControl.ActivePage;

       if poglwnd<>nil then
       begin
            tobject(poglwnd):=FindControlByType(poglwnd,TOGLWnd);
            //pointer(poglwnd):=poglwnd^.FindKidsByType(typeof(TOGLWnd));
            gdb.CurrentDWG:=poglwnd.PDWG;
            poglwnd.GDBActivate;
       end;
       shared.SBTextOut('Закрыто');
       GDBobjinsp.ReturnToDefault;
       sharedgdb.updatevisible;
  end;*)
end;
function NextDrawint_com(Operands:pansichar):GDBInteger;
var
   i:integer;
begin
     if assigned(MainFormN.PageControl)then
     if MainFormN.PageControl.PageCount>1 then
     begin
          i:=MainFormN.PageControl.ActivePageIndex+1;
          if i=MainFormN.PageControl.PageCount
                                              then
                                                  i:=0;
             MainFormN.PageControl.ActivePageIndex:=i;
     end;
end;
function PrevDrawint_com(Operands:pansichar):GDBInteger;
var
   i:integer;
begin
     if assigned(MainFormN.PageControl)then
     if MainFormN.PageControl.PageCount>1 then
     begin
          i:=MainFormN.PageControl.ActivePageIndex-1;
          if i<0
                                            then
                                                  i:=MainFormN.PageControl.PageCount-1;
             MainFormN.PageControl.ActivePageIndex:=i;
     end;
end;
function newdwg_com(Operands:pansichar):GDBInteger;
var
   ptd:PTDrawing;
   myts:TTabSheet;
   oglwnd:TOGLWND;
   wpowner:TOpenGLViewArea;
   tn:GDBString;
begin
     ptd:=gdb.CreateDWG;

     gdb.AddRef(ptd^);

     gdb.SetCurrentDWG(ptd);

     if length(operands)=0 then
                               operands:=@rsUnnamedWindowTitle[1];

     {tf:=mainform.PageControl.addpage(Operands);
     mainform.PageControl.selpage(mainform.PageControl.lastcreated);
     mainform.PageControl.CxMenu:=DWGPageCxMenu;}

     myts:=nil;

     if not assigned(MainFormN.PageControl)then
     begin
          DockMaster.ShowControl('PageControl',true);
          //DockMaster.ShowControl('PageControl',true);
     end;


     myts:=TTabSheet.create(MainFormN.PageControl);
     myts.Caption:=(Operands);
     //mainformn.DisableAutoSizing;
     myts.Parent:=MainFormN.PageControl;
     //mainformn.EnableAutoSizing;

     //tf.align:=al_client;

     wpowner:=TOpenGLViewArea.Create(myts);
     oglwnd:=wpowner.OpenGLWindow;// TOGLWnd.Create(myts);




     //--------------------------------------------------------------oglwnd.BevelOuter:=bvnone;
     gdb.GetCurrentDWG.wa:=wpowner;
     //gdb.GetCurrentDWG.OGLwindow1:=oglwnd;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.wa.PDWG:=ptd;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.align:=alClient;
          //gdb.GetCurrentDWG.OGLwindow1.align:=al_client;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.Parent:=myts;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.init;{переделать из инита нужно убрать обнуление pdwg}
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.wa.PDWG:=ptd;
     programlog.logoutstr('oglwnd.PDWG:=ptd;',0);
     //oglwnd.GDBActivate;
     oglwnd._onresize(nil);
     programlog.logoutstr('oglwnd._onresize(nil);',0);
     oglwnd.MakeCurrent(false);
     programlog.logoutstr('oglwnd.MakeCurrent(false);',0);
     isOpenGLError;
     programlog.logoutstr('isOpenGLError;',0);
     //oglwnd.DoubleBuffered:=false;
     oglwnd.show;
     programlog.logoutstr('oglwnd.show;',0);
     isOpenGLError;
     programlog.logoutstr('isOpenGLError;',0);
     //oglwnd.Repaint;
     //gdb.GetCurrentDWG.OGLwindow1.initxywh('oglwnd',tf,200,72,768,596,false);

     //tf.size;

     //gdb.GetCurrentDWG.OGLwindow1.Show;

     //GDBGetMem({$IFDEF DEBUGBUILD}'{E197C531-C543-4FAF-AF4A-37B8F278E8A2}',{$ENDIF}GDBPointer(gdb.GetCurrentDWG),sizeof(UGDBDescriptor.TDrawing));
     //gdb.GetCurrentDWG^.init(@gdb.ProjectUnits);
     //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_nok.dxf',@gdb.GetCurrentDWG.ObjRoot);

     MainFormN.PageControl.ActivePage:=myts;
     programlog.logoutstr('MainFormN.PageControl.ActivePage:=myts;',0);
     if assigned(UpdateVisibleProc) then UpdateVisibleProc;
     programlog.logoutstr('sharedgdb.updatevisible;',0);
     operands:=operands;
     programlog.logoutstr('operands:=operands;???????????????',0);
     if not fileexists(operands) then
     begin
     tn:=expandpath(sysvar.PATH.Template_Path^)+sysvar.PATH.Template_File^;
     if fileExists(utf8tosys(tn)) then
                           {merge_com(@tn[1])}Load_merge(@tn[1],TLOLoad)
                       else
                           shared.ShowError(format(rsTemplateNotFound,[tn]));
                           //shared.ShowError('Не найден файл шаблона "'+tn+'"');
     end;
     //redrawoglwnd;
     result:=cmd_ok;
     programlog.logoutstr('result:=cmd_ok;',0);
     application.ProcessMessages;
     programlog.logoutstr(' application.ProcessMessages;',0);
     oglwnd._onresize(nil);
     programlog.logoutstr('oglwnd._onresize(nil);',0);

     //GDB.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,'DEVICE_TEST');
     //addblockinsert(gdb.GetCurrentROOT,@gdb.GetCurrentDWG.ConstructObjRoot.ObjArray, nulvertex, 1, 0, 'DEVICE_TEST');
     //gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
end;
function Import_com(Operands:pansichar):GDBInteger;
var
   s: GDBString;
   //fileext:GDBString;
   isload:boolean;
begin
  if length(operands)=0 then
                     begin
                          if assigned(Showallcursorsproc) then Showallcursorsproc;
                          //mainformn.ShowAllCursors;
                          isload:=OpenFileDialog(s,'svg',ImportFileFilter,'','Import...');
                          if assigned(RestoreAllCursorsproc) then RestoreAllCursorsproc;
                          //mainformn.RestoreCursors;
                          //s:=utf8tosys(s);
                          if not isload then
                                            begin
                                                 result:=cmd_cancel;
                                                 exit;
                                            end
                     end
                 else
                 begin
                   s:=ExpandPath(operands);
                   s:=FindInSupportPath(operands);
                 end;
  isload:=FileExists(utf8tosys(s));
  if isload then
  begin
       newdwg_com(@s[1]);
       gdb.GetCurrentDWG.SetFileName(s);
       import(s,gdb.GetCurrentDWG^);
  end
            else
     shared.ShowError('LOAD:'+format(rsUnableToOpenFile,[s+'('+Operands+')']));
     //shared.ShowError('GDBCommandsBase.LOAD: Не могу открыть файл: '+s+'('+Operands+')');
end;
function Load_com(Operands:pansichar):GDBInteger;
var
   s: GDBString;
   //fileext:GDBString;
   isload:boolean;
   //mem:GDBOpenArrayOfByte;
   //pu:ptunit;
begin
     if length(operands)=0 then
                        begin
                             if assigned(Showallcursorsproc) then Showallcursorsproc;
                             isload:=OpenFileDialog(s,'dxf',ProjectFileFilter,'',rsOpenFile);
                             if assigned(RestoreAllCursorsproc) then RestoreAllCursorsproc;
                             //s:=utf8tosys(s);
                             if not isload then
                                               begin
                                                    result:=cmd_cancel;
                                                    exit;
                                               end
                                           else
                                               begin

                                               end;    

                        end
                    else
                    begin
                         if operands='QS' then
                                              s:=ExpandPath(sysvar.SAVE.SAVE_Auto_FileName^)
                                          else
                                              begin
                                                   s:=FindInSupportPath(operands);
                                                   if s='' then
                                                               s:=ExpandPath(operands);
                                              end;
                    end;
     isload:=FileExists(utf8tosys(s));
     if isload then
     begin
          newdwg_com(@s[1]);
          //if operands<>'QS' then
                                gdb.GetCurrentDWG.SetFileName(s);
          programlog.logoutstr('gdb.GetCurrentDWG.FileName:=s;',0);
          load_merge(@s[1],tloload);
          programlog.logoutstr('load_merge(@s[1],tloload);',0);
          if assigned(ProcessFilehistoryProc) then
           ProcessFilehistoryProc(s);
     end
               else
        shared.ShowError('LOAD:'+format(rsUnableToOpenFile,[s+'('+Operands+')']));
        //shared.ShowError('GDBCommandsBase.LOAD: Не могу открыть файл: '+s+'('+Operands+')');
end;
function layer_cmd:GDBInteger;
begin
  LayerWindow:=TLayerWindow.Create(nil);
  SetHeightControl(LayerWindow,sysvar.INTF.INTF_ObjInspRowH^);
  DOShowModal(LayerWindow);
  Freeandnil(LayerWindow);
  result:=cmd_ok;
end;
function TextStyles_cmd:GDBInteger;
begin
  TSWindow:=TTSWindow.Create(nil);
  SetHeightControl(TSWindow,sysvar.INTF.INTF_ObjInspRowH^);
  DOShowModal(TSWindow);
  Freeandnil(TSWindow);
  result:=cmd_ok;
end;
function DimStyles_cmd:GDBInteger;
begin
  DSWindow:=TDSWindow.Create(nil);
  SetHeightControl(DSWindow,sysvar.INTF.INTF_ObjInspRowH^);
  DOShowModal(DSWindow);
  Freeandnil(DSWindow);
  result:=cmd_ok;
end;
 function LineTypes_cmd:GDBInteger;
begin
  LTWindow:=TLTWindow.Create(nil);
  SetHeightControl(LTWindow,sysvar.INTF.INTF_ObjInspRowH^);
  DOShowModal(LTWindow);
  Freeandnil(LTWindow);
  result:=cmd_ok;
end;
function Colors_cmd:GDBInteger;
var
   mr:integer;
begin
     if not assigned(ColorSelectWND)then
     Application.CreateForm(TColorSelectWND, ColorSelectWND);
     SetHeightControl(ColorSelectWND,sysvar.INTF.INTF_ObjInspRowH^);
     if assigned(ShowAllCursorsProc) then
                                         ShowAllCursorsProc;
     mr:=ColorSelectWND.run(SysVar.dwg.DWG_CColor^,true){showmodal};
     if mr=mrOk then
                    begin
                    SysVar.dwg.DWG_CColor^:=ColorSelectWND.ColorInfex;
                    end;
     if assigned(RestoreAllCursorsProc) then
                                            RestoreAllCursorsProc;
     freeandnil(ColorSelectWND);
     result:=cmd_ok;
end;




procedure finalize;
begin
end;
procedure SaveLayoutToFile(Filename: string);
var
  XMLConfig: TXMLConfig;
  Config: TXMLConfigStorage;
begin
  XMLConfig:=TXMLConfig.Create(nil);
  try
    XMLConfig.StartEmpty:=true;
    XMLConfig.Filename:=Filename;
    Config:=TXMLConfigStorage.Create(XMLConfig);
    try
      DockMaster.SaveLayoutToConfig(Config);
      DockMaster.SaveSettingsToConfig(Config);
    finally
      Config.Free;
    end;
    XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;
end;
function SaveLayout_com:GDBInteger;
var
  XMLConfig: TXMLConfigStorage;
  filename:string;
begin
  try
    // create a new xml config file
    filename:=utf8tosys(sysparam.programpath+'components/defaultlayout.xml');
    SaveLayoutToFile(filename);
    exit;
    XMLConfig:=TXMLConfigStorage.Create(filename,false);
    try
      // save the current layout of all forms
      DockMaster.SaveLayoutToConfig(XMLConfig);
      XMLConfig.WriteToDisk;
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
      MessageDlg('Error',
        'Error saving layout to file '+Filename+':'#13+E.Message,mtError,
        [mbCancel],0);
    end;
  end;
  result:=cmd_ok;
end;
function Show_com(Operands:pansichar):GDBInteger;
var
   ctrl:TControl;
begin
  if Operands<>'' then
                      begin
                           ctrl:=DockMaster.FindControl(Operands);
                           if (ctrl<>nil)and(ctrl.IsVisible) then
                                           begin
                                                DockMaster.ManualFloat(ctrl);
                                                DockMaster.GetAnchorSite(ctrl).Close;
                                           end
                                       else
                                           begin
                                                If IsValidIdent(Operands) then
                                                                              DockMaster.ShowControl(Operands,true)
                                                                          else
                                                                              shared.ShowError('Show: invalid identificator!');
                                           end;
                      end
                  else
                      shared.ShowError('Show command must have one operand!');
end;
function quit_com(Operands:pansichar):GDBInteger;
begin
     //Application.QueueAsyncCall(MainFormN.asynccloseapp, 0);
     CloseApp;
end;
function About_com(Operands:pansichar):GDBInteger;
begin
  if not assigned(Aboutwindow) then
                                  Aboutwindow:=TAboutWnd.mycreate(Application,@Aboutwindow);
  DOShowModal(Aboutwindow);
end;
function Help_com(Operands:pansichar):GDBInteger;
begin
  if not assigned(Helpwindow) then
                                  Helpwindow:=THelpWnd.mycreate(Application,@Helpwindow);
  DOShowModal(Helpwindow);
end;
function ClearFileHistory_com(Operands:pansichar):GDBInteger;
var i,j,k:integer;
    pstr,pstrnext:PGDBString;
begin
     for i:=0 to 9 do
     begin
          pstr:=SavedUnit.FindValue('PATH_File'+inttostr(i));
          if assigned(pstr) then
          pstr^:='';
          if assigned(MainFormN.FileHistory[i]) then
          begin
              MainFormN.FileHistory[i].Caption:='';
              MainFormN.FileHistory[i].command:='';
              MainFormN.FileHistory[i].Visible:=false;
          end;
     end;
end;
function tw_com(Operands:pansichar):GDBInteger;
begin
  if CWMemo.IsVisible then
                                 CWindow.Hide
                             else
                                 CWindow.Show;

end;
function SetObjInsp_com(Operands:pansichar):GDBInteger;
var
   obj:gdbstring;
   objt:PUserTypeDescriptor;
  pp:PGDBObjEntity;
  ir:itrec;
begin
     if Operands='VARS' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,gdb.GetCurrentDWG);
                            end
else if Operands='CAMERA' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(SysUnit.TypeName2PTD('GDBObjCamera'),gdb.GetCurrentDWG.pcamera,gdb.GetCurrentDWG);
                            end
else if Operands='CURRENT' then
                            begin

                                 if (GDB.GetCurrentDWG.GetLastSelected <> nil)
                                 then
                                     begin
                                          obj:=pGDBObjEntity(GDB.GetCurrentDWG.GetLastSelected)^.GetObjTypeName;
                                          objt:=SysUnit.TypeName2PTD(obj);
                                          If assigned(SetGDBObjInspProc)then
                                          SetGDBObjInspProc(objt,GDB.GetCurrentDWG.GetLastSelected,gdb.GetCurrentDWG);
                                     end
                                 else
                                     begin
                                          ShowError('ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject=NIL, try SetObjInsp(SELECTED)...');
                                     end;
                                 SysVar.DWG.DWG_SelectedObjToInsp^:=false;
                            end
else if Operands='SELECTED' then
                            begin
                                     begin
                                          //ShowError('ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject=NIL, try find selected in DRAWING...');
                                          pp:=gdb.GetCurrentROOT.objarray.beginiterate(ir);
                                          if pp<>nil then
                                         begin
                                              repeat
                                              if pp^.Selected then
                                                              begin
                                                                   obj:=pp^.GetObjTypeName;
                                                                   objt:=SysUnit.TypeName2PTD(obj);
                                                                   If assigned(SetGDBObjInspProc)then
                                                                   SetGDBObjInspProc(objt,pp,gdb.GetCurrentDWG);
                                                                   exit;
                                                              end;
                                              pp:=gdb.GetCurrentROOT.objarray.iterate(ir);
                                              until pp=nil;
                                         end;
                                     end;
                                 SysVar.DWG.DWG_SelectedObjToInsp^:=false;
                            end
else if Operands='OGLWND_DEBUG' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(SysUnit.TypeName2PTD('OGLWndtype'),@gdb.GetCurrentDWG.wa.param,gdb.GetCurrentDWG);
                            end
else if Operands='GDBDescriptor' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(SysUnit.TypeName2PTD('GDBDescriptor'),@gdb,gdb.GetCurrentDWG);
                            end
else if Operands='RELE_DEBUG' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(dbunit.TypeName2PTD('vardesk'),dbunit.FindVariable('SEVCABLEkvvg'),gdb.GetCurrentDWG);
                            end
else if Operands='LAYERS' then
                            begin
                                 SetGDBObjInspProc(dbunit.TypeName2PTD('GDBLayerArray'),@gdb.GetCurrentDWG.LayerTable,gdb.GetCurrentDWG);
                            end
else if Operands='TSTYLES' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(dbunit.TypeName2PTD('GDBTextStyleArray'),@gdb.GetCurrentDWG.TextStyleTable,gdb.GetCurrentDWG);
                            end
else if Operands='FONTS' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(dbunit.TypeName2PTD('GDBFontManager'),@FontManager,gdb.GetCurrentDWG);
                            end
else if Operands='OSMODE' then
                            begin
                                 OSModeEditor.GetState;
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(dbunit.TypeName2PTD('TOSModeEditor'),@OSModeEditor,gdb.GetCurrentDWG);
                            end
else if Operands='NUMERATORS' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(SysUnit.TypeName2PTD('GDBNumerator'),@gdb.GetCurrentDWG.Numerator,gdb.GetCurrentDWG);
                            end
else if Operands='LINETYPESTYLES' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(SysUnit.TypeName2PTD('GDBLtypeArray'),@gdb.GetCurrentDWG.LTypeStyleTable,gdb.GetCurrentDWG);
                            end
else if Operands='TABLESTYLES' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(SysUnit.TypeName2PTD('GDBTableStyleArray'),@gdb.GetCurrentDWG.TableStyleTable,gdb.GetCurrentDWG);
                            end
else if Operands='DIMSTYLES' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(SysUnit.TypeName2PTD('GDBDimStyleArray'),@gdb.GetCurrentDWG.DimStyleTable,gdb.GetCurrentDWG);
                            end
                            ;
     If assigned(SetCurrentObjDefaultProc)then
                                              SetCurrentObjDefaultProc
     //GDBobjinsp.SetCurrentObjDefault;
end;

function Options_com(Operands:pansichar):GDBInteger;
begin
  if assigned(SetGDBObjInspProc)then
                                    SetGDBObjInspProc(SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,gdb.GetCurrentDWG);
  historyoutstr(rscmOptions2OI);
  result:=cmd_ok;
end;
function SaveOptions_com(Operands:pansichar):GDBInteger;
var
   mem:GDBOpenArrayOfByte;
begin
           mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);
           SysVarUnit^.SavePasToMem(mem);
           mem.SaveToFile(sysparam.programpath+'rtl/sysvar.pas');
           mem.done;
end;
function CommandList_com(Operands:pansichar):GDBInteger;
var
   p:PCommandObjectDef;
   ir:itrec;
   clist:GDBGDBStringArray;
begin
   clist.init(200);
   p:=commandmanager.beginiterate(ir);
   if p<>nil then
   repeat
         clist.add(@p^.CommandName);
         p:=commandmanager.iterate(ir);
   until p=nil;
   clist.sort;
   shared.HistoryOutStr(clist.GetTextWithEOL);
   clist.done;
   result:=cmd_ok;
end;
function DebClip_com(Operands:pansichar):GDBInteger;
var
   pbuf:pansichar;
   i:gdbinteger;
   cf:TClipboardFormat;
   ts:string;

   memsubstr:TMemoryStream;
   InfoForm:TInfoForm;
begin
     InfoForm:=TInfoForm.create(application.MainForm);
     InfoForm.DialogPanel.HelpButton.Hide;
     InfoForm.DialogPanel.CancelButton.Hide;
     InfoForm.DialogPanel.CloseButton.Hide;
     InfoForm.caption:=('Clipboard:');

     memsubstr:=TMemoryStream.Create;
     ts:=Clipboard.AsText;
     i:=Clipboard.FormatCount;
     for i:=0 to Clipboard.FormatCount-1 do
     begin
          cf:=Clipboard.Formats[i];
          ts:=ClipboardFormatToMimeType(cf);
          if ts='' then
                       ts:=inttostr(cf);
          InfoForm.Memo.lines.Add(ts);
          Clipboard.GetFormat(cf,memsubstr);
          pbuf:=memsubstr.Memory;
          InfoForm.Memo.lines.Add('  ANSI: '+pbuf);
          memsubstr.Clear;
     end;
     memsubstr.Free;

     DOShowModal(InfoForm);
     InfoForm.Free;

     result:=cmd_ok;
end;
function MemSummary_com(Operands:pansichar):GDBInteger;
var
    memcount:GDBNumerator;
    pmemcounter:PGDBNumItem;
    ir:itrec;
    s:gdbstring;
    I:gdbinteger;
    InfoForm:TInfoForm;
begin

     InfoForm:=TInfoForm.create(application.MainForm);
     InfoForm.DialogPanel.HelpButton.Hide;
     InfoForm.DialogPanel.CancelButton.Hide;
     InfoForm.DialogPanel.CloseButton.Hide;
     InfoForm.caption:=('Memory is used to:');
     memcount.init(100);
     for i := 0 to memdesktotal do
     begin
          if not(memdeskarr[i].free) then
          begin
               pmemcounter:=memcount.addnumerator(memdeskarr[i].getmemguid);
               inc(pmemcounter^.Nymber,memdeskarr[i].size);
           end;
     end;
     memcount.sort;

     pmemcounter:=memcount.beginiterate(ir);
     if pmemcounter<>nil then
     repeat

           s:=pmemcounter^.Name+' '+inttostr(pmemcounter^.Nymber);
           InfoForm.Memo.lines.Add(s);
           pmemcounter:=memcount.iterate(ir);
     until pmemcounter=nil;


     DOShowModal(InfoForm);
     InfoForm.Free;
     memcount.FreeAndDone;
    result:=cmd_ok;
end;
function ShowPage_com(Operands:pansichar):GDBInteger;
begin
  if assigned(mainformn)then
  if assigned(mainformn.PageControl)then
  mainformn.PageControl.ActivePageIndex:=strtoint(Operands);
end;
procedure startup;
begin
  CreateCommandFastObjectPlugin(@newdwg_com,'NewDWG',0,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@NextDrawint_com,'NextDrawing',0,0);
  CreateCommandFastObjectPlugin(@PrevDrawint_com,'PrevDrawing',0,0);
  CreateCommandFastObjectPlugin(@CloseDWG_com,'CloseDWG',CADWG,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@Load_com,'Load',0,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@Import_com,'Import',0,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@LoadLayout_com,'LoadLayout',0,0);
  CreateCommandFastObjectPlugin(@quit_com,'Quit',0,0);
  CreateCommandFastObjectPlugin(@layer_cmd,'Layer',CADWG,0);
  CreateCommandFastObjectPlugin(@TextStyles_cmd,'TextStyles',CADWG,0);
  CreateCommandFastObjectPlugin(@DimStyles_cmd,'DimStyles',CADWG,0);
  CreateCommandFastObjectPlugin(@LineTypes_cmd,'LineTypes',CADWG,0);
  CreateCommandFastObjectPlugin(@Colors_cmd,'Colors',CADWG,0);
  CreateCommandFastObjectPlugin(@SaveLayout_com,'SaveLayout',0,0);
  CreateCommandFastObjectPlugin(@Show_com,'Show',0,0);
  CreateCommandFastObjectPlugin(@About_com,'About',0,0);
  CreateCommandFastObjectPlugin(@Help_com,'Help',0,0);
  CreateCommandFastObjectPlugin(@ClearFileHistory_com,'ClearFileHistory',0,0);
  CreateCommandFastObjectPlugin(@TW_com,'TextWindow',0,0).overlay:=true;
  CreateCommandFastObjectPlugin(@Options_com,'Options',0,0);
  CreateCommandFastObjectPlugin(@SaveOptions_com,'SaveOptions',0,0);
  CreateCommandFastObjectPlugin(@SetObjInsp_com,'SetObjInsp',CADWG,0);
  CreateCommandFastObjectPlugin(@CommandList_com,'CommandList',0,0);
  CreateCommandFastObjectPlugin(@DebClip_com,'DebClip',0,0);
  CreateCommandFastObjectPlugin(@MemSummary_com,'MeMSummary',0,0);
  CreateCommandFastObjectPlugin(@ShowPage_com,'ShowPage',0,0);
  Aboutwindow:=nil;
  Helpwindow:=nil;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('gdbcommandsinterface.initialization');{$ENDIF}
  startup;
finalization
  finalize;
end.
