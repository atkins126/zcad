﻿unit DEVICE_EL_VL_SCHEMA3_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Floor1:Boolean;(*'Подвал'*)
VL_Floor2:Boolean;(*'1 этаж'*)
VL_Floor3:Boolean;(*'2 этаж'*)
VL_Floor4:Boolean;(*'3 этаж'*)
VL_Floor5:Boolean;(*'4 этаж'*)
VL_Floor6:Boolean;(*'5 этаж'*)
VL_Floor7:Boolean;(*'6 этаж'*)
VL_Floor8:Boolean;(*'7 этаж'*)
VL_Floor9:Boolean;(*'8 этаж'*)
VL_Floor10:Boolean;(*'9 этаж'*)
VL_Floor11:Boolean;(*'10 этаж'*)
VL_Floor12:Boolean;(*'11 этаж'*)
VL_Floor13:Boolean;(*'12 этаж'*)
VL_Floor14:Boolean;(*'13 этаж'*)
VL_Floor15:Boolean;(*'14 этаж'*)
VL_Floor16:Boolean;(*'15 этаж'*)
VL_Floor17:Boolean;(*'16 этаж'*)
VL_Floor18:Boolean;(*'17 этаж'*)
VL_Floor19:Boolean;(*'18 этаж'*)
VL_Floor20:Boolean;(*'19 этаж'*)
VL_Floor21:Boolean;(*'20 этаж'*)

VL_Shield:Integer;(*'Щит'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ЭТ0';
NMO_BaseName:='ЭТ';
NMO_Suffix:='??';

VL_Floor1:=True;
VL_Floor2:=False;
VL_Floor3:=False;
VL_Floor4:=False;
VL_Floor5:=False;
VL_Floor6:=False;
VL_Floor7:=False;
VL_Floor8:=False;
VL_Floor9:=False;
VL_Floor10:=False;
VL_Floor11:=False;
VL_Floor12:=False;
VL_Floor13:=False;
VL_Floor14:=False;
VL_Floor15:=False;
VL_Floor16:=False;
VL_Floor17:=False;
VL_Floor18:=False;
VL_Floor19:=False;
VL_Floor20:=False;
VL_Floor21:=False;

VL_Shield:=1;

end.