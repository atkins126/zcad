unit DEVICE_EL_VL_REPORT3_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Обозначение'*)
T2:GDBString;(*'Наименование'*)
T3:GDBString;(*'Примечание'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВД0';
NMO_BaseName:='ВД';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='';

end.