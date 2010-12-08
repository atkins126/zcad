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

unit cmdline;
{$INCLUDE def.inc}
interface
uses
 strproc,lclproc,
 StdCtrls,ExtCtrls,ComCtrls,Controls,Classes,menus,Forms,{IFDEF FPClcltype,$ENDIF}fileutil,graphics,
 UDMenuWnd{,ZStaticsText},gdbase{,ZPanelsNoFrame}, memman,UGDBDescriptor,math,commandline,varman,languade,
 UGDBTracePropArray,{zforms,}{ZEditsWithProcedure}{,zbasicvisible,}varmandef,{ZGUIsCT,}{ZPanelsGeneric,}
 geometry,shared{,zmemos};
const
     cheight=18;
     defaultpromot=' Команда> ';
type
  TCLineMode=(CLCOMMANDREDY,CLCOMMANDRUN);
  TCLine = class({TPanel}TForm{Tcustomform})
    procedure beforeinit;virtual;
    procedure AfterConstruction; override;
  private
    mode:TCLineMode;
    prompttext:ansistring;
  public

    DMenu:PTDMenuWnd;
    utfpresent:boolean;
    utflen:integer;
    procedure keypressmy(Sender: TObject; var Key: char);
    procedure SetMode(m:TCLineMode);virtual;
    procedure DoOnResize; override;
    procedure MyResize;
    procedure HistoryAdd(s:string);
    procedure mypaint(sender:tobject);
    procedure FormCreate(Sender: TObject);
  end;
var
  CLine: TCLine;
implementation
uses gdbasetypes,mainwindow,oglwindowdef,log;
procedure TCLine.mypaint(sender:tobject);
begin
     canvas.Line(0,0,100,100);
end;

procedure TCLine.HistoryAdd(s:string);
var
   l,ll:integer;
   ss:string;
begin
     ss:=(s);
     if HistoryLine.Lines.Count=0 then
                                            utflen:=utflen+UTF8Length(ss)
                                        else
                                            utflen:=2+utflen+UTF8Length(ss);
    //TTextStrings(CLine.HistoryLine.lines).add(ss);
    HistoryLine.Append(ss);
    l:=HistoryLine.GetTextLen;
    HistoryLine.SelStart:=utflen;
    HistoryLine.SelLength:=2;

    //cline.HistoryLine.Invalidate;
    //application.ProcessMessages;

    //ss:=CLine.HistoryLine.Text;
    //CLine.HistoryLine.Text:=copy(CLine.HistoryLine.Text,1,length(CLine.HistoryLine.Text)-2);
    //CLine.HistoryLine.Lines.Strings[CLine.HistoryLine.Lines.Count-1]:='1212';
    //CLine.HistoryLine.ClearSelection; {тормоз}

end;

procedure TCLine.SetMode(m:TCLineMode);
begin
     {if m=mode then
                   exit;}
     case m of
     CLCOMMANDREDY:
     begin
           prompt.Caption:=(defaultpromot);
     end;
     CLCOMMANDRUN:
     begin
          prompt.Caption:='> ';
     end;
     end;
     mode:=m;
end;
procedure TCLine.FormCreate(Sender: TObject);
var
   bv:tbevel;
begin
    self.Constraints.MinHeight:=36;
    utfpresent:=false;
    UTFLen:=0;
    //height:=100;
    //self.DoubleBuffered:=true;

    panel:=TPanel.create(self);
    panel.parent:=self;
    panel.top:=0;
    panel.Constraints.MinHeight:=14+2;
    panel.Constraints.MaxHeight:=14+2;
    panel.BorderStyle:=bsNone;
    panel.BevelOuter:=bvnone;
    panel.BorderWidth:=0;
    panel.Align:=alBottom;

    with TBevel.Create(self) do
    begin
         parent:={self}panel;
         top:=0;
         height:=2;
         Align:={alBottom}altop;
         //---------------BevelOuter:=bvraised;
    end;

    HistoryLine:=TMemo.create(self);
    HistoryLine.Align:=alClient;
    HistoryLine.ReadOnly:=true;
    HistoryLine.BorderStyle:=bsnone;
    HistoryLine.BorderWidth:=0;
    HistoryLine.ScrollBars:=ssAutoBoth;
    HistoryLine.Height:=self.clientheight-22;
    HistoryLine.parent:=self;
    //HistoryLine.:=

    //HistoryLine.DoubleBuffered:=true;

    panel.Color:=HistoryLine.Brush.Color;

    prompt:=TLabel.create(panel);
    prompt.Align:=alLeft;
    prompt.Layout:=tlCenter;
    //prompt.Width:=1;
    //prompt.BorderStyle:=sbsSingle;
    prompt.AutoSize:=true;
    //prompt.Caption:='Command';
    //prompt.Text:='Command';
    prompt.parent:=panel;
    //prompt.Canvas.Brush:=prompt.Canvas.Brush;

    cmdedit:=TEdit.create(panel);
    cmdedit.Align:=alClient;
    cmdedit.BorderStyle:=bsnone;
    cmdedit.BorderWidth:=0;
    //cmdedit.BevelOuter:=bvnone;
    cmdedit.parent:=panel;
    cmdedit.DoubleBuffered:=true;
    cmdedit.AutoSize:=true;
    with cmdedit.Constraints do
    begin
         MaxHeight:=22;
    end;
    with prompt.Constraints do
    begin
         MaxHeight:=22;
    end;
    SetMode(CLCOMMANDREDY);

    cmdedit.OnKeyPress:=keypressmy;

    BorderStyle:=BSsingle;
    BorderWidth:=0;
    //---------------BevelOuter:=bvnone;

      if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
                                                  sysvar.SYS.SYS_IsHistoryLineCreated^:=true;
end;

procedure TCLine.AfterConstruction;
begin
    name:='MainForm123';
    oncreate:=FormCreate;
    inherited;
end;
procedure TCLine.MyResize;
begin
        if assigned(HistoryLine) then
                                         HistoryLine.Height:=self.clientheight-22;
end;

procedure TCLine.DoOnResize;
begin
     inherited;
     myresize;
end;

procedure TCLine.beforeinit;
begin
(*
  mode:=CLCOMMANDREDY;
  prompttext:='Команда>';
  prompt.initxywh(prompttext,@self,-1,clientheight-cheight-1,clientwidth+3,cheight+2,false);
  //prompt.setextstyle(0,WS_EX_ClientEdge);
  //prompt.setstyle(WS_Border,0);
  //GDBGetMem({$IFDEF DEBUGBUILD}'{C5652242-FC00-4B6B-9C44-3CFAADC6D918}',{$ENDIF}GDBPointer(cmdedit),sizeof(ZEditWithProcedure));
  cmdedit.initxywh('',@self,0,clientheight-cheight,clientwidth,cheight,false);
  cmdedit.setextstyle(0,WS_EX_ClientEdge);
  cmdedit.setstyle(WS_Border,0);
  cmdedit.onenter:=keypressmy;


  //GDBGetMem({$IFDEF DEBUGBUILD}'{1D86B21F-D1DE-4D07-82F3-AE8CEEAA25DF}',{$ENDIF}GDBPointer(HistoryLine),sizeof(zmemo));
  HistoryLine.initxywh('',@self,0,0,clientwidth,clientheight-cheight+1,false);
  HistoryLine.SetReadOnlyState(1);
  //HistoryLine.align:=al_client;
  //cmdedit^.align:=al_client;

  DMenu.initxywh('DisplayMenu',@MainForm,200,100,10,10,false);

//  dmenu.AddProcedure('test1','подсказка1',nil);
//  dmenu.AddProcedure('test2','подсказка2',nil);
//  dmenu.AddProcedure('test3 test3 test3 test3 test3','подсказка3',nil);
*)
end;
procedure TCLine.keypressmy(Sender: TObject; var Key: char);
var code,ch: GDBInteger;
  len: double;
  temp: gdbvertex;
  v:vardesk;
  s:GDBString;
  tv:gdbvertex;
begin
    ch:=ord(key);
    if ord(key)=13 then
    begin
    if (length(CmdEdit.text) > 0) then
    begin
      val(CmdEdit.text, len, code);
      if code = 0 then
      begin
      if assigned(gdb.GetCurrentDWG) then
      if assigned(gdb.GetCurrentDWG.OGLwindow1) then
      begin
        if gdb.GetCurrentDWG.OGLwindow1.param.polarlinetrace = 1 then
        begin
          tv:=pgdbvertex(gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].arrayworldaxis.getelement(gdb.GetCurrentDWG.OGLwindow1.param.axisnum))^;
          tv:=geometry.normalizevertex(tv);
          temp.x := gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].worldcoord.x + len * tv.x * sign(ptraceprop(gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].arraydispaxis.getelement(gdb.GetCurrentDWG.OGLwindow1.param.axisnum)).tmouse);
          temp.y := gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].worldcoord.y + len * tv.y * sign(ptraceprop(gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].arraydispaxis.getelement(gdb.GetCurrentDWG.OGLwindow1.param.axisnum)).tmouse);
          temp.z := gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].worldcoord.z + len * tv.z * sign(ptraceprop(gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.otrackarray[gdb.GetCurrentDWG.OGLwindow1.param.pointnum].arraydispaxis.getelement(gdb.GetCurrentDWG.OGLwindow1.param.axisnum)).tmouse);

          gdb.GetCurrentDWG.OGLwindow1.sendcoordtocommandTraceOn(temp,MZW_LBUTTON,nil);
          //commandmanager.sendpoint2command(temp, poglwnd.md.mouse, 1,nil);
          //mainwindow.OGLwindow1.param.lastpoint:=temp;
        end;
      end
      end
      else if CmdEdit.text[1] = '$' then begin
                                              v:=evaluate(copy(CmdEdit.text, 2, length(CmdEdit.text) - 1),SysUnit);
                                              //s:=valuetoGDBString(v.pvalue,v.ptd);
                                              s:=v.data.ptd^.GetValueAsString(v.data.Instance);
                                              v.data.Instance:=v.data.Instance;
                                              historyout(GDBPointer(CmdEdit.text+' return '+s));
                                         end
      else
          commandmanager.executecommand(GDBPointer(CmdEdit.text));
    end;
    CmdEdit.text:='';
    key:=#0;
    //CmdEdit.settext('');
    if assigned(gdb.GetCurrentDWG) then
    if assigned(gdb.GetCurrentDWG.OGLwindow1) then
    begin
    //gdb.GetCurrentDWG.OGLwindow1.setfocus;
    gdb.GetCurrentDWG.OGLwindow1.param.firstdraw := TRUE;
    gdb.GetCurrentDWG.OGLwindow1.reprojectaxis;
    gdb.GetCurrentDWG.OGLwindow1.{paint}draw;
    end;
    //redrawoglwnd;
    {poglwnd.loadmatrix;
    poglwnd.paint;}
    end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('cmdline.initialization');{$ENDIF}
end.
