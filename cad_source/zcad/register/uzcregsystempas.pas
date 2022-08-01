{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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

unit uzcregsystempas;
{$INCLUDE zengineconfig.inc}
interface
uses uzbpaths,UUnitManager,uzcsysvars,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
     uzbstrproc,Varman,SysUtils,
     UBaseTypeDescriptor,uzctnrVectorBytes, strmy, varmandef,
     uzcsysparams,uzcsysinfo,TypeDescriptors,URecordDescriptor,
     uzblog,uzclog,LazLogger;
implementation
{$IFNDEF WINDOWS}
var
  ptd:PUserTypeDescriptor;
{$ENDIF}
initialization;
     with programlog.Enter('uzcregsystempas.initialization',LM_Debug) do begin
     if SysUnit=nil then
       begin
         units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/system.pas'),nil);
         SysUnit:=units.findunit(SupportPath,InterfaceTranslate,'System');
       end;
     programlog.leave(IfEntered);
     end;
finalization;
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization')
end.
