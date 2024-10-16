unit DEVICE_EL_VL_VEDOMOSTI2_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Mark:String;(*'Обозначение'*)
VL_Name:String;(*'Наименование'*)
VL_Note:String;(*'Примечание'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='СД0';
NMO_BaseName:='СД';
NMO_Suffix:='??';

VL_Mark:='??';
VL_Name:='??';
VL_Note:='??';

end.