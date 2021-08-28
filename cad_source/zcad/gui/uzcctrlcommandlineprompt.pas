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

unit uzcctrlcommandlineprompt;
{$ifdef fpc}
  {$mode delphi}{$H+}
{$endif}

interface

uses
  Classes,StdCtrls,Graphics,Controls,
  LCLIntf,LCLType,
  Common.Graphics;

const
  //раскраска опции
  HLOptionFontColor = clBtnText;
  HLOptionBrushColor = clBtnFace;
  HLOptionUseBrush = True;
  HLOptionFontUnderLine=False;

  //раскраска выделенной части опции
  HLHLOptionFontColor = clRed;
  HLHLOptionBrushColor = clBtnFace;
  HLHLOptionUseBrush = True;
  HLHLOptionFontUnderLine=True;

  //раскраска опции под мышкой
  HotOptionFontColor = clBtnText;
  HotOptionBrushColor = clActiveBorder;
  HotOptionUseBrush = True;
  HotOptionFontUnderLine=False;

type
  TCommandLineTextType=(CLTT_Option,       //опция (подсвечивается под мышкой)
                        CLTT_HLOption);    //выделенная часть опции (например шорткат или подобное)
  TTag=Integer;                            //Тип тэга(доп инфа привязаная к подсвеченному участку)
  TNotifyProc=procedure(Tag:TTag)of object;//Процедура нотификации о клике по выделенной части
  TCLTagType=record                        //Доп инфа привязаная к подсвеченному участку
    &Type:TCommandLineTextType;            //Тип участка
    Tag:TTag;                              //Доп инфа
  end;
  TSubString=record                        //определяет подстроку
    P:Integer;                             //начало в кодепоинтах
    L:Integer;                             //длина в кодепоинтах
    &Type:TCommandLineTextType;            //тип
    Tag:TTag;                              //тэг
  end;
  TSubStrings=array of TSubString;         //массив подстрок
  TRectWithTag=record                      //рект для контроля положения мышки
    R:TRect;
    Tag:TTag;
  end;
  TRectsWithTags=array of TRectWithTag;    //массив ректов для мышки

  TCommandLinePrompt=class(TCustomLabel)
    type
      TCLHighlight=THighlight<TCLTagType>;
    private
      FOnClickNotify:TNotifyProc;
    protected
      property Layout default tlCenter;
      procedure MouseLeave; override;
      procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
      procedure Click; override;
      procedure UpdateHighLightTagsData;
      function UpdateRects(Words:TWords;FillRect:boolean):integer;
    public
      Highlight: TCLHighlight;
      HotTag: Integer;
      Rects:TRectsWithTags;
      procedure Paint; override;
      property OnClickNotify: TNotifyProc read FOnClickNotify write FOnClickNotify;
      constructor Create(TheOwner: TComponent); override;
      procedure SetHighLightedText(const Value: TCaption;Parts:TSubStrings);
  end;

function SubString(p,l:integer;t:TCommandLineTextType;tag:integer):TSubString;

implementation

function SubString(p,l:integer;t:TCommandLineTextType;tag:integer):TSubString;
begin
  result.p:=p;
  result.l:=l;
  result.&type:=t;
  result.tag:=tag;
end;
procedure TCommandLinePrompt.UpdateHighLightTagsData;
var
  i:Integer;
begin
  for i := 0 to Highlight.Items.Count - 1 do begin
    if Highlight.Items[i].Tag.Tag=HotTag then begin
      Highlight.Items[i].FontColor := HotOptionFontColor;
      Highlight.Items[i].BrushColor := HotOptionBrushColor;
      Highlight.Items[i].UseBrush := HotOptionUseBrush;
      Highlight.Items[i].FontUnderLine:=HotOptionFontUnderLine;
    end else case Highlight.Items[i].Tag.&Type of
                                     CLTT_Option:begin
                                                   Highlight.Items[i].FontColor := HLOptionFontColor;
                                                   Highlight.Items[i].BrushColor := HLOptionBrushColor;
                                                   Highlight.Items[i].UseBrush := HLOptionUseBrush;
                                                   Highlight.Items[i].FontUnderLine:=HLOptionFontUnderLine;
                                                 end;
                                   CLTT_HLOption:begin
                                                   Highlight.Items[i].FontColor := HLHLOptionFontColor;
                                                   Highlight.Items[i].BrushColor := HLHLOptionBrushColor;
                                                   Highlight.Items[i].UseBrush := HLHLOptionUseBrush;
                                                   Highlight.Items[i].FontUnderLine:=HLHLOptionFontUnderLine;
                                                 end;
             end;
  end;
end;
procedure  TCommandLinePrompt.SetHighLightedText(const Value: TCaption;Parts:TSubStrings);
var
  i:Integer;
  HLItem: TCLHighlight.THighlightItem;
begin
  Highlight.Clear;
  for i:=Low(Parts) to High(Parts) do begin
    HLItem := Highlight.AddHighlight;
    HLItem.Tag.&Type:=Parts[i].&Type;
    HLItem.Tag.Tag:=Parts[i].Tag;
    HLItem.Start := Parts[i].P;
    HLItem.Len := Parts[i].L;
  end;
  UpdateHighLightTagsData;
  Caption:=Value;
end;

procedure TCommandLinePrompt.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i:Integer;
begin
  inherited;
  for i:=Low(Rects) to High(Rects) do begin
    if PtInRect(Rects[i].R,Point(X,Y)) then
      begin
        if HotTag<>Rects[i].Tag then begin
          HotTag:=Rects[i].Tag;
          UpdateHighLightTagsData;
          Invalidate;
        end;
        exit;
      end;
  end;
  if HotTag<>-1 then begin
    HotTag:=-1;
    UpdateHighLightTagsData;
    Invalidate;
  end;
end;
procedure TCommandLinePrompt.MouseLeave;
begin
  inherited;
  if HotTag<>-1 then begin
    HotTag:=-1;
    UpdateHighLightTagsData;
    Invalidate;
  end;
end;

procedure TCommandLinePrompt.Click;
begin
  inherited;
  if (HotTag<>-1)and(assigned(FOnClickNotify)) then
    FOnClickNotify(HotTag);
end;

function TCommandLinePrompt.UpdateRects(Words:TWords;FillRect:boolean):integer;
var
  i:Integer;
  LastR:TRect;
  LastTag:TTag;
begin
  result:=0;
  for i:=Low(Words) to High(Words) do begin
    if Words[i].HightLightIndex>=0 then begin
      if result=0 then begin
        inc(result);
        lastR:=Words[i].ARect;
        lastTag:=Highlight.Items[Words[i].HightLightIndex].Tag.Tag;
      end else begin
        if (lastTag<>Highlight.Items[Words[i].HightLightIndex].Tag.Tag)or(abs(Words[i].ARect.Left-lastR.Right)>2) then begin
          if FillRect then begin
            Rects[Result-1].R:=lastR;
            Rects[Result-1].Tag:=lastTag;
          end;
          lastR:=Words[i].ARect;
          lastTag:=Highlight.Items[Words[i].HightLightIndex].Tag.Tag;
          inc(result);
        end else begin
          lastR.Right:=Words[i].ARect.Right
        end;
      end;
    end;
  end;
  if FillRect then begin
    if result>0 then begin
      Rects[Result-1].R:=lastR;
      Rects[Result-1].Tag:=lastTag;
    end;
  end;
end;

procedure TCommandLinePrompt.Paint;

var
  R: TRect;
  TestString:string;
  Words:TWords;
  RectsSize:integer;
begin
  TestString:=GetLabelText;
  R := Rect(0,0,Width,Height);
  try
     Words:=DrawHighlitedText<TCLTagType>(Canvas, TestString, R, DT_SINGLELINE, Highlight, False);
     RectsSize:=UpdateRects(Words,false);
     SetLength(Rects,RectsSize);
     UpdateRects(Words,true);
  finally
  end;
end;

constructor TCommandLinePrompt.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  HotTag:=-1;
  Highlight:=TCLHighlight.Create;
  Layout:=tlCenter;
end;
end.
