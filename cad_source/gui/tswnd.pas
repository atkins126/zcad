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
unit tswnd;
{$INCLUDE def.inc}
{$mode objfpc}{$H+}

interface

uses
  ugdbdimstylearray,ugdbfont,selectorwnd,ugdbltypearray,ugdbutil,log,lineweightwnd,colorwnd,ugdbsimpledrawing,zcadsysvars,Classes, SysUtils,
  FileUtil, LResources, Forms, Controls, Graphics, Dialogs,GraphType,
  Buttons, ExtCtrls, StdCtrls, ComCtrls,LCLIntf,lcltype,

  gdbobjectsconstdef,UGDBTextStyleArray,UGDBDescriptor,gdbase,gdbasetypes,varmandef,usuptypededitors,

  zcadinterface, zcadstrconsts, strproc, shared, UBaseTypeDescriptor,
  imagesmanager, usupportgui, ZListView,UGDBFontManager,varman,UGDBStringArray,GDBEntity,GDBText;

const
     NameColumn=0;
     FontNameColumn=1;
     FontPathColumn=2;
     HeightColumn=3;
     WidthFactorColumn=4;
     ObliqueColumn=5;

     ColumnCount=5+1;

type
  TFTFilter=(TFTF_All,TFTF_TTF,TFTF_SHX);

  { TTextStylesWindow }

  TTextStylesWindow = class(TForm)
    AddLayerBtn: TSpeedButton;
    ComboBox1: TComboBox;
    DeleteLayerBtn: TSpeedButton;
    Bevel1: TBevel;
    ButtonApplyClose: TBitBtn;
    Button_Apply: TBitBtn;
    Label1: TLabel;
    LayerDescLabel: TLabel;
    ListView1: TZListView;
    MkCurrentBtn: TSpeedButton;
    PurgeBtn: TSpeedButton;
    procedure Aply(Sender: TObject);
    procedure AplyClose(Sender: TObject);
    procedure FontsTypesChange(Sender: TObject);
    procedure PurgeTStyles(Sender: TObject);
    procedure StyleAdd(Sender: TObject);
    procedure LayerDelete(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure MkCurrent(Sender: TObject);
    procedure MaceItemCurrent(ListItem:TListItem);
    procedure FillFontsSelector(currentitem:string;currentitempfont:PGDBfont);
    procedure onrsz(Sender: TObject);
    procedure countstyle(ptextstyle:PGDBTextStyle;out e,b,inDimStyles:GDBInteger);
  private
    changedstamp:boolean;
    PEditor:TPropEditor;
    EditedItem:TListItem;
    FontsSelector:TEnumData;
    SupportTypedEditors:TSupportTypedEditors;
    FontChange:boolean;
    IsUndoEndMarkerCreated:boolean;
    { private declarations }
    procedure UpdateItem2(Item:TObject);
    procedure CreateUndoStartMarkerNeeded;
    procedure CreateUndoEndMarkerNeeded;
    procedure GetFontsTypesComboValue;
    procedure doTStyleDelete(ProcessedItem:TListItem);

  public
    { public declarations }

    {Style name handle procedures}
    function GetStyleName(Item: TListItem):string;
    function CreateNameEditor(Item: TListItem;r: TRect):boolean;
    {Font name handle procedures}
    function GetFontName(Item: TListItem):string;
    function CreateFontNameEditor(Item: TListItem;r: TRect):boolean;
    {Font path handle procedures}
    function GetFontPath(Item: TListItem):string;
    {Height handle procedures}
    function GetHeight(Item: TListItem):string;
    function CreateHeightEditor(Item: TListItem;r: TRect):boolean;
    {Wfactor handle procedures}
    function GetWidthFactor(Item: TListItem):string;
    function CreateWidthFactorEditor(Item: TListItem;r: TRect):boolean;
    {Oblique handle procedures}
    function GetOblique(Item: TListItem):string;
    function CreateObliqueEditor(Item: TListItem;r: TRect):boolean;
  end;

var
  TSWindow: TTextStylesWindow;
  FontsFilter:TFTFilter;
implementation
uses
    mainwindow;
{$R *.lfm}
procedure TTextStylesWindow.GetFontsTypesComboValue;
begin
     ComboBox1.ItemIndex:=ord(FontsFilter);
end;

procedure TTextStylesWindow.CreateUndoStartMarkerNeeded;
begin
  if not IsUndoEndMarkerCreated then
   begin
    IsUndoEndMarkerCreated:=true;
    ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushStartMarker('Change text styles');
   end;
end;
procedure TTextStylesWindow.CreateUndoEndMarkerNeeded;
begin
  if IsUndoEndMarkerCreated then
   begin
    IsUndoEndMarkerCreated:=false;
    ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushEndMarker;
   end;
end;

procedure TTextStylesWindow.UpdateItem2(Item:TObject);
begin
     if FontChange then
     begin
          PGDBTextStyle(TListItem(Item).Data)^.pfont:=FontManager.addFonf(FindInPaths(sysvar.PATH.Fonts_Path^,pstring(FontsSelector.Enums.getelement(FontsSelector.Selected))^));
          PGDBTextStyle(TListItem(Item).Data)^.dxfname:=PGDBTextStyle(TListItem(Item).Data)^.pfont^.Name;
     end;
     ListView1.UpdateItem2(TListItem(Item));
     FontChange:=false;
     ComboBox1.enabled:=true;
end;

{Style name handle procedures}
function TTextStylesWindow.GetStyleName(Item: TListItem):string;
begin
  result:=Tria_AnsiToUtf8(PGDBTextStyle(Item.Data)^.Name);
end;
function TTextStylesWindow.CreateNameEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBTextStyle(Item.Data)^.Name,'GDBAnsiString')
end;
{Font name handle procedures}
function TTextStylesWindow.GetFontName(Item: TListItem):string;
begin
  result:=ExtractFileName(PGDBTextStyle(Item.Data)^.pfont^.fontfile);
end;
function TTextStylesWindow.CreateFontNameEditor(Item: TListItem;r: TRect):boolean;
begin
  FillFontsSelector(PGDBTextStyle(Item.Data)^.pfont^.fontfile,PGDBTextStyle(Item.Data)^.pfont);
  FontChange:=true;
  ComboBox1.enabled:=false;
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,FontsSelector,'TEnumData')
end;
{Font path handle procedures}
function TTextStylesWindow.GetFontPath(Item: TListItem):string;
begin
  result:=ExtractFilePath(PGDBTextStyle(Item.Data)^.pfont^.fontfile);
end;
{Height handle procedures}
function TTextStylesWindow.GetHeight(Item: TListItem):string;
begin
  result:=floattostr(PGDBTextStyle(Item.Data)^.prop.size);
end;
function TTextStylesWindow.CreateHeightEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBTextStyle(Item.Data)^.prop.size,'GDBDouble')
end;
{Wfactor handle procedures}
function TTextStylesWindow.GetWidthFactor(Item: TListItem):string;
begin
  result:=floattostr(PGDBTextStyle(Item.Data)^.prop.wfactor);
end;
function TTextStylesWindow.CreateWidthFactorEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBTextStyle(Item.Data)^.prop.wfactor,'GDBDouble')
end;
{Oblique handle procedures}
function TTextStylesWindow.GetOblique(Item: TListItem):string;
begin
  result:=floattostr(PGDBTextStyle(Item.Data)^.prop.oblique);
end;
function TTextStylesWindow.CreateObliqueEditor(Item: TListItem;r: TRect):boolean;
begin
  result:=SupportTypedEditors.createeditor(ListView1,Item,r,PGDBTextStyle(Item.Data)^.prop.oblique,'GDBDouble')
end;
procedure TTextStylesWindow.FillFontsSelector(currentitem:string;currentitempfont:PGDBfont);
var i:integer;
    s:string;
    CurrentFontIndex:integer;
begin
     CurrentFontIndex:=-1;
     FontsSelector.Enums.Free;
     if FontsFilter<>TFTF_SHX then
     for i:=0 to FontManager.ttffontfiles.Count-1 do
     begin
          S:=FontManager.ttffontfiles[i];
          if S=currentitem then
           CurrentFontIndex:=FontsSelector.Enums.Count;
          S:=extractfilename(S);
          FontsSelector.Enums.add(@S);
     end;
     if FontsFilter<>TFTF_TTF then
     for i:=0 to FontManager.shxfontfiles.Count-1 do
     begin
          S:=FontManager.shxfontfiles[i];
          if S=currentitem then
           CurrentFontIndex:=FontsSelector.Enums.Count;
          S:=extractfilename(S);
          FontsSelector.Enums.add(@S);
     end;
     if CurrentFontIndex=-1 then
     begin
          CurrentFontIndex:=FontsSelector.Enums.Count;
          S:=extractfilename(currentitempfont^.fontfile);
          FontsSelector.Enums.add(@S);
     end;
     FontsSelector.Selected:=CurrentFontIndex;
     FontsSelector.Enums.SortAndSaveIndex(FontsSelector.Selected);
end;

procedure TTextStylesWindow.onrsz(Sender: TObject);
begin
     Sender:=Sender;
     SupportTypedEditors.freeeditor;
end;

procedure TTextStylesWindow.FormCreate(Sender: TObject);
begin
IconList.GetBitmap(II_Plus, AddLayerBtn.Glyph);
IconList.GetBitmap(II_Minus, DeleteLayerBtn.Glyph);
IconList.GetBitmap(II_Ok, MkCurrentBtn.Glyph);
IconList.GetBitmap(II_Purge, PurgeBtn.Glyph);
ListView1.SmallImages:=IconList;
ListView1.DefaultItemIndex:=II_Ok;

FontsSelector.Enums.init(100);
SupportTypedEditors:=TSupportTypedEditors.create;
SupportTypedEditors.OnUpdateEditedControl:=@UpdateItem2;
FontChange:=false;
IsUndoEndMarkerCreated:=false;

setlength(ListView1.SubItems,ColumnCount);

with ListView1.SubItems[NameColumn] do
begin
     OnGetName:=@GetStyleName;
     OnClick:=@CreateNameEditor;
end;
with ListView1.SubItems[FontNameColumn] do
begin
     OnGetName:=@GetFontName;
     OnClick:=@CreateFontNameEditor;
end;
with ListView1.SubItems[FontPathColumn] do
begin
     OnGetName:=@GetFontPath;
end;
with ListView1.SubItems[HeightColumn] do
begin
     OnGetName:=@GetHeight;
     OnClick:=@CreateHeightEditor;
end;
with ListView1.SubItems[WidthFactorColumn] do
begin
     OnGetName:=@GetWidthFactor;
     OnClick:=@CreateWidthFactorEditor;
end;
with ListView1.SubItems[ObliqueColumn] do
begin
     OnGetName:=@GetOblique;
     OnClick:=@CreateObliqueEditor;
end;
end;
procedure TTextStylesWindow.MaceItemCurrent(ListItem:TListItem);
begin
     if ListView1.CurrentItem<>ListItem then
     begin
     CreateUndoStartMarkerNeeded;
     with PTDrawing(gdb.GetCurrentDWG)^.UndoStack.PushCreateTGChangeCommand(sysvar.dwg.DWG_CTStyle^)^ do
     begin
          SysVar.dwg.DWG_CTStyle^:=ListItem.Data;
          ComitFromObj;
     end;
     end;
end;
procedure TTextStylesWindow.MkCurrent(Sender: TObject);
begin
  if assigned(ListView1.Selected)then
                                     begin
                                     MaceItemCurrent(ListView1.Selected);
                                     ListView1.MakeItemCorrent(ListView1.Selected);
                                     UpdateItem2(ListView1.Selected);
                                     end
                                 else
                                     MessageBox(@rsLayerMustBeSelected[1],@rsWarningCaption[1],MB_OK or MB_ICONWARNING);
end;
procedure TTextStylesWindow.FormShow(Sender: TObject);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   plp:PGDBTextStyle;
   li:TListItem;
begin
     GetFontsTypesComboValue;
     ListView1.BeginUpdate;
     ListView1.Clear;
     pdwg:=gdb.GetCurrentDWG;
     if (pdwg<>nil)and(pdwg<>PTSimpleDrawing(BlockBaseDWG)) then
     begin
       plp:=pdwg^.TextStyleTable.beginiterate(ir);
       if plp<>nil then
       repeat
            li:=ListView1.Items.Add;

            li.Data:=plp;

            ListView1.UpdateItem(li,gdb.GetCurrentDWG^.TextStyleTable.GetCurrentTextStyle);

            plp:=pdwg^.TextStyleTable.iterate(ir);
       until plp=nil;
     end;
     ListView1.SortColumn:=1;
     ListView1.SetFocus;
     ListView1.EndUpdate;
end;
procedure TextStyleCounter(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
begin
     if (PGDBObjEntity(PInstance)^.vp.ID=GDBMTextID)or(PGDBObjEntity(PInstance)^.vp.ID=GDBTextID) then
     if PCounted=PGDBObjText(PInstance)^.TXTStyleIndex then
                                                           inc(Counter);
end;
procedure TextStyleCounterInDimStyles(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
begin
     if PCounted=PGDBDimStyle(PInstance)^.Text.DIMTXSTY then
                                                           inc(Counter);
end;
procedure TTextStylesWindow.countstyle(ptextstyle:PGDBTextStyle;out e,b,inDimStyles:GDBInteger);
var
   pdwg:PTSimpleDrawing;
begin
  pdwg:=gdb.GetCurrentDWG;
  e:=0;
  pdwg^.mainObjRoot.IterateCounter(ptextstyle,e,@TextStyleCounter);
  b:=0;
  pdwg^.BlockDefArray.IterateCounter(ptextstyle,b,@TextStyleCounter);
  inDimStyles:=0;
  pdwg^.DimStyleTable.IterateCounter(ptextstyle,inDimStyles,@TextStyleCounterInDimStyles);
end;
procedure TTextStylesWindow.ListView1SelectItem(Sender: TObject; Item: TListItem;Selected: Boolean);
var
   pstyle:PGDBTextStyle;
   pdwg:PTSimpleDrawing;
   inent,inblock,indimstyles:integer;
begin
     if selected then
     begin
          pdwg:=gdb.GetCurrentDWG;
          pstyle:=(Item.Data);
          countstyle(pstyle,inent,inblock,indimstyles);
          LayerDescLabel.Caption:=Format(rsTextStyleUsedIn,[pstyle^.Name,inent,inblock,indimstyles]);
     end;
end;

procedure TTextStylesWindow.StyleAdd(Sender: TObject);
var
   pstyle,pcreatedstyle:PGDBTextStyle;
   pdwg:PTSimpleDrawing;
   stylename:string;
   counter:integer;
   li:TListItem;
   domethod,undomethod:tmethod;
begin
  pdwg:=gdb.GetCurrentDWG;
  if assigned(ListView1.Selected)then
                                     pstyle:=(ListView1.Selected.Data)
                                 else
                                     pstyle:=pdwg^.TextStyleTable.GetCurrentTextStyle;

  stylename:=pdwg^.TextStyleTable.GetFreeName(Tria_Utf8ToAnsi(rsNewTextStyleNameFormat),1);
  if stylename='' then
  begin
    shared.ShowError(rsUnableSelectFreeTextStylerName);
    exit;
  end;

  pdwg^.TextStyleTable.AddItem(stylename,pcreatedstyle);
  pcreatedstyle^:=pstyle^;
  pcreatedstyle^.Name:=stylename;

  domethod:=tmethod(@pdwg^.TextStyleTable.AddToArray);
  undomethod:=tmethod(@pdwg^.TextStyleTable.RemoveFromArray);
  CreateUndoStartMarkerNeeded;
  with ptdrawing(GDB.GetCurrentDWG)^.UndoStack.PushCreateTGObjectChangeCommand2(pcreatedstyle,tmethod(domethod),tmethod(undomethod))^ do
  begin
       AfterAction:=false;
       //comit;
  end;

  ListView1.AddCreatedItem(pcreatedstyle,gdb.GetCurrentDWG^.LayerTable.GetCurrentLayer);
end;
procedure TTextStylesWindow.doTStyleDelete(ProcessedItem:TListItem);
var
   domethod,undomethod:tmethod;
   pstyle:PGDBTextStyle;
   pdwg:PTSimpleDrawing;
begin
  pdwg:=gdb.GetCurrentDWG;
  pstyle:=(ProcessedItem.Data);
  domethod:=tmethod(@pdwg^.TextStyleTable.RemoveFromArray);
  undomethod:=tmethod(@pdwg^.TextStyleTable.AddToArray);
  CreateUndoStartMarkerNeeded;
  with ptdrawing(pdwg)^.UndoStack.PushCreateTGObjectChangeCommand2(pstyle,tmethod(domethod),tmethod(undomethod))^ do
  begin
       AfterAction:=false;
       comit;
  end;
  ListView1.Items.Delete(ListView1.Items.IndexOf(ProcessedItem));
end;

procedure TTextStylesWindow.LayerDelete(Sender: TObject);
var
   pstyle:PGDBTextStyle;
   pdwg:PTSimpleDrawing;
   inEntities,inBlockTable,indimstyles:GDBInteger;
   domethod,undomethod:tmethod;
begin
  pdwg:=gdb.GetCurrentDWG;
  if assigned(ListView1.Selected)then
                                     begin
                                     pstyle:=(ListView1.Selected.Data);
                                     countstyle(pstyle,inEntities,inBlockTable,indimstyles);
                                     if ListView1.Selected.Data=pdwg^.TextStyleTable.GetCurrentTextStyle then
                                     begin
                                       ShowError(rsCurrentStyleCannotBeDeleted);
                                       exit;
                                     end;
                                     if (inEntities+inBlockTable+indimstyles)>0 then
                                                  begin
                                                       ShowError(rsUnableDelUsedStyle);
                                                       exit;
                                                  end;

                                     doTStyleDelete(ListView1.Selected);

                                     LayerDescLabel.Caption:='';
                                     end
                                 else
                                     ShowError(rsStyleMustBeSelected);
end;

procedure TTextStylesWindow.AplyClose(Sender: TObject);
begin
     close;
end;

procedure TTextStylesWindow.FontsTypesChange(Sender: TObject);
begin
  FontsFilter:=TFTFilter(ComboBox1.ItemIndex);
end;

procedure TTextStylesWindow.PurgeTStyles(Sender: TObject);
var
   i,purgedcounter:integer;
   ProcessedItem:TListItem;
   inEntities,inBlockTable,indimstyles:GDBInteger;
   PCurrentStyle:PGDBTextStyle;
begin
     i:=0;
     purgedcounter:=0;
     PCurrentStyle:=gdb.GetCurrentDWG^.TextStyleTable.GetCurrentTextStyle;
     if ListView1.Items.Count>0 then
     begin
       repeat
          ProcessedItem:=ListView1.Items[i];
          countstyle(ProcessedItem.Data,inEntities,inBlockTable,indimstyles);
          if (ProcessedItem.Data<>PCurrentStyle)and((inEntities+inBlockTable+indimstyles)=0) then
          begin
           doTStyleDelete(ProcessedItem);
           inc(purgedcounter);
          end
          else
           inc(i);
       until i>=ListView1.Items.Count;
     end;
     LayerDescLabel.Caption:=Format(rsCountTStylesPurged,[purgedcounter]);
end;

procedure TTextStylesWindow.Aply(Sender: TObject);
begin
     if changedstamp then
     begin
           if assigned(UpdateVisibleProc) then UpdateVisibleProc;
           if assigned(redrawoglwndproc)then
                                            redrawoglwndproc;
     end;
end;

procedure TTextStylesWindow.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
     Aply(nil);
     CreateUndoEndMarkerNeeded;
     FontsSelector.Enums.done;
     SupportTypedEditors.Free;
end;
initialization
  FontsFilter:=TFTF_SHX;
end.

