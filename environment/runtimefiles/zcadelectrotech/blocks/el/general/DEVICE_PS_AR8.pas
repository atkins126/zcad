unit DEVICE_PS_AR8;
interface
uses system,devices;
usescopy objname;
usescopy blocktype;
var
   Device_Type:TDeviceType;(*'Тип устройства'*) 

   DB_link:String;(*'Материал'*)
   
   GC_HeadDevice:String;
   GC_HDShortName:String;
   GC_HDGroup:Integer;
   GC_NumberInGroup:Integer;

   SerialConnection:Integer;


   EL_Cab_AddLength:Double;(*'Добавлять к длине кабеля'*)
implementation
begin
   DB_link:='расширитель 8 ШС';

   BTY_TreeCoord:='PLAN_OPS_С2000-АР8';
   Device_Type:=TDT_PriborOPS;
   NMO_Template:='@@[NMO_Prefix]@@[GC_HDGroup]@@[NMO_BaseName]-@@[NMO_Suffix]';
   EL_Cab_AddLength:=1.0;

   NMO_Prefix:='';
   NMO_BaseName:='AU8';
   NMO_Suffix:='??';



   SerialConnection:=8;
   GC_HDShortName:='??';
   GC_HeadDevice:='??';
   GC_HDGroup:=0;
end.