unit DEVICE_EL_VL_DIAGRAM_CH1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T2:GDBString;(*'Марка'*)
T3:GDBString;(*'Параметры'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Щиты';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='А0';
NMO_BaseName:='А';
NMO_Suffix:='??';
NMO_Affix:='.11';

T2:='??';
T3:='??';

end.