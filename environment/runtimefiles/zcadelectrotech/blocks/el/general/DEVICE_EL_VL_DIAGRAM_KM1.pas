unit DEVICE_EL_VL_DIAGRAM_DIAGRAM_KM1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Тип'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='A0';
NMO_BaseName:='A3.';
NMO_Suffix:='??';

T1:='??';

end.