subunit devicebase;
interface
uses system;
type
     TsegmentenergoMKSngALS_WCS=(_02_35(*'2х0.35'*),
                                 _03_35(*'3х0.35'*),
                                 _04_35(*'4х0.35'*),
                                 _05_35(*'5х0.35'*),
                                 _02_50(*'2х0.5'*),
                                 _03_50(*'3х0.5'*),
                                 _04_50(*'4х0.5'*),
                                 _05_50(*'5х0.5'*),
                                 _02_75(*'2х0.75'*),
                                 _03_75(*'3х0.75'*),
                                 _04_75(*'4х0.75'*),
                                 _05_75(*'5х1.0'*),
                                 _02_10(*'2х1.0'*),
                                 _03_10(*'3х1.0'*),
                                 _04_10(*'4х1.0'*),
                                 _05_10(*'5х1.0'*),
                                 _02_15(*'2х1.5'*),
                                 _03_15(*'3х1.5'*),
                                 _04_15(*'4х1.5'*),
                                 _05_15(*'5х2.5'*),
                                 _02_25(*'2х2.5'*),
                                 _03_25(*'3х2.5'*),
                                 _04_25(*'4х2.5'*),
                                 _05_25(*'5х2.5'*));

    TsegmentenergoMKSngALS=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TsegmentenergoMKSngALS_WCS;
                  end;
    TsegmentenergoMKSngALSLTx=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TsegmentenergoMKSngALS_WCS;
                  end; 
    TsegmentenergoMKESngALSLTx=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TsegmentenergoMKSngALS_WCS;
                  end; 

var
   _EQ_segmentenergoMKSngALS:TsegmentenergoMKSngALS;
   _EQ_segmentenergoMKSngALSLTx:TsegmentenergoMKSngALSLTx;
   _EQ_segmentenergoMKESngALSLTx:TsegmentenergoMKESngALSLTx;
implementation
begin
     _EQ_segmentenergoMKSngALS.initnul;

     _EQ_segmentenergoMKSngALS.Category:=_kables;
     _EQ_segmentenergoMKSngALS.Group:=_cables;
     _EQ_segmentenergoMKSngALS.EdIzm:=_m;
     _EQ_segmentenergoMKSngALS.ID:='segmentenergoMKSngALS';
     _EQ_segmentenergoMKSngALS.Standard:='ТУ 3581-003-17648068-2014';
     _EQ_segmentenergoMKSngALS.OKP:='';
     _EQ_segmentenergoMKSngALS.Manufacturer:='ООО «СегментЭнерго» г.Москва';
     _EQ_segmentenergoMKSngALS.Description:='Кабели предназначенные для переносного и фиксированного межприборного монтажа электрических устройств, работающих при номинальном переменном напряжении до 500 В частоты до 400 Гц или постоянном напряжении до 750 В';

     _EQ_segmentenergoMKSngALS.NameShortTemplate:='МКШng(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_segmentenergoMKSngALS.NameTemplate:='Кабель монтажный МКШng(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_segmentenergoMKSngALS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_segmentenergoMKSngALS.NameFullTemplate:='Кабель монтажный для фиксированного межприборного монтажа электрических устройств, до 500В, до 400Гц или постоянном напряжении до 750В. Пучковой скрутки, с низким дымо- и газовыделением. Температура эксплуатации −50 … +50 °С, сечением %%[Wire_Count_Section_DESC]';

     _EQ_segmentenergoMKSngALS.Wire_Count_Section_DESC:=_02_75;

     _EQ_segmentenergoMKSngALS.TreeCoord:='BP_СегментЭнерго_Кабели монтажные_МКШng(A)-LS|BC_Кабельная продукция_контрольные_МКШng(A)-LS(СегментЭнерго)';

     _EQ_segmentenergoMKSngALS.format;



     _EQ_segmentenergoMKSngALSLTx.initnul;

     _EQ_segmentenergoMKSngALSLTx.Category:=_kables;
     _EQ_segmentenergoMKSngALSLTx.Group:=_cables;
     _EQ_segmentenergoMKSngALSLTx.EdIzm:=_m;
     _EQ_segmentenergoMKSngALSLTx.ID:='segmentenergoMKSngALSLTx';
     _EQ_segmentenergoMKSngALSLTx.Standard:='ТУ 3581-003-17648068-2014';
     _EQ_segmentenergoMKSngALSLTx.OKP:='';
     _EQ_segmentenergoMKSngALSLTx.Manufacturer:='ООО «СегментЭнерго» г.Москва';
     _EQ_segmentenergoMKSngALSLTx.Description:='Кабели предназначенные для переносного и фиксированного межприборного монтажа электрических устройств, работающих при номинальном переменном напряжении до 500 В частоты до 400 Гц или постоянном напряжении до 750 В';

     _EQ_segmentenergoMKSngALSLTx.NameShortTemplate:='МКШng(A)-LSLTx-%%[Wire_Count_Section_DESC]';
     _EQ_segmentenergoMKSngALSLTx.NameTemplate:='Кабель монтажный МКШng(A)-LSLTx-%%[Wire_Count_Section_DESC]';
     _EQ_segmentenergoMKSngALSLTx.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_segmentenergoMKSngALSLTx.NameFullTemplate:='Кабель монтажный для фиксированного межприборного монтажа электрических устройств, до 500В, до 400Гц или постоянном напряжении до 750В. Пучковой скрутки, с низким дымо- и газовыделением и низкой токсичностью продуктов горения. Температура эксплуатации −50 … +50 °С, сечением %%[Wire_Count_Section_DESC]';

     _EQ_segmentenergoMKSngALSLTx.Wire_Count_Section_DESC:=_02_75;

     _EQ_segmentenergoMKSngALSLTx.TreeCoord:='BP_СегментЭнерго_Кабели монтажные_МКШng(A)-LSLTx|BC_Кабельная продукция_контрольные_МКШng(A)-LSLTx(СегментЭнерго)';

     _EQ_segmentenergoMKSngALSLTx.format;



     _EQ_segmentenergoMKESngALSLTx.initnul;

     _EQ_segmentenergoMKESngALSLTx.Category:=_kables;
     _EQ_segmentenergoMKESngALSLTx.Group:=_cables;
     _EQ_segmentenergoMKESngALSLTx.EdIzm:=_m;
     _EQ_segmentenergoMKESngALSLTx.ID:='segmentenergoMKESngALSLTx';
     _EQ_segmentenergoMKESngALSLTx.Standard:='ТУ 3581-003-17648068-2014';
     _EQ_segmentenergoMKESngALSLTx.OKP:='';
     _EQ_segmentenergoMKESngALSLTx.Manufacturer:='ООО «СегментЭнерго» г.Москва';
     _EQ_segmentenergoMKESngALSLTx.Description:='Кабели предназначенные для переносного и фиксированного межприборного монтажа электрических устройств, работающих при номинальном переменном напряжении до 500 В частоты до 400 Гц или постоянном напряжении до 750 В.';

     _EQ_segmentenergoMKESngALSLTx.NameShortTemplate:='МКЭШng(A)-LSLTx-%%[Wire_Count_Section_DESC]';
     _EQ_segmentenergoMKESngALSLTx.NameTemplate:='Кабель монтажный экранированный МКЭШng(A)-LSLTx-%%[Wire_Count_Section_DESC]';
     _EQ_segmentenergoMKESngALSLTx.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_segmentenergoMKESngALSLTx.NameFullTemplate:='Кабель монтажный экранированный для фиксированного межприборного монтажа электрических устройств, до 500В, до 400Гц или постоянном напряжении до 750В. Пучковой скрутки, с низким дымо- и газовыделением и низкой токсичностью продуктов горения. Температура эксплуатации −50 … +50 °С, сечением %%[Wire_Count_Section_DESC]';

     _EQ_segmentenergoMKESngALSLTx.Wire_Count_Section_DESC:=_02_75;

     _EQ_segmentenergoMKESngALSLTx.TreeCoord:='BP_СегментЭнерго_Кабели монтажные_МКЭШng(A)-LSLTx|BC_Кабельная продукция_контрольные_МКЭШng(A)-LSLTx(СегментЭнерго)';

     _EQ_segmentenergoMKESngALSLTx.format;


end.