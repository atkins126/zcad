unit DEVICE_EL_VL_UNIT_A2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Mark:String;(*'Обозначение'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='A0';
NMO_BaseName:='A';
NMO_Suffix:='??';
NMO_Affix:='';

VL_Mark:='';

end.