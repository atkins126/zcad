(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}  
unit uzccablemanager;
{$INCLUDE def.inc}
interface
uses uzcenitiesvariablesextender,uzcvariablesutils,Varman,uzbstrproc,uzcentcable,
     uzeentdevice,uzeconsts,gzctnrvectorpobjects,languade,gzctnrvectorobjects,
     gzctnrvectortypes,SysUtils,uzbtypesbase,uzbtypes,varmandef,uzbmemman,uzcdrawings,
     uzcstrconsts;
resourcestring
     DefCableName='Created. Not named';
type
{EXPORT+}
    PTCableDesctiptor=^TCableDesctiptor;
    TCableDesctiptor={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                     Name:GDBString;
                     Segments:TZctnrVectorPGDBaseObjects;   // сборщик всех кабелей с одинаковым именем (ШС..)
                     StartDevice,EndDevice:PGDBObjDevice;
                     StartSegment:PGDBObjCable;
                     Devices:TZctnrVectorPGDBaseObjects;
                     length:GDBDouble;
                     constructor init;
                     destructor done;virtual;
                     function GetObjTypeName:GDBString;virtual;
                     function GetObjName:GDBString;virtual;
                 end;

    PTCableManager=^TCableManager;
    TCableManager={$IFNDEF DELPHI}packed{$ENDIF} object(GZVectorObjects<TCableDesctiptor>)(*OpenArrayOfPObj*)
                       constructor init;
                       destructor done;virtual;
                       procedure build;virtual;
                       function FindOrCreate(sname:gdbstring):PTCableDesctiptor;virtual;
                       function Find(sname:gdbstring):PTCableDesctiptor;virtual;
                 end;
{EXPORT-}
implementation
function TCableDesctiptor.GetObjTypeName;
begin
     result:='TCableDesctiptor';
end;
function TCableDesctiptor.GetObjName;
begin
     if self.Segments.count=1 then
                                  result:=Name
                              else
                                  result:=Name+' ('+inttostr(self.Segments.count)+')';
end;
constructor TCableDesctiptor.init;
begin
     inherited;
     name:=defcablename;
     length:=0;
     Segments.init({$IFDEF DEBUGBUILD}'{FE431793-97FF-48AE-9B55-22D186BD5471}',{$ENDIF}10);
     Devices.init({$IFDEF DEBUGBUILD}'{7C4DC8CC-F0C0-402A-84F6-6FEA2C06F0C8}',{$ENDIF}10);
end;
constructor TCableManager.init;
begin
     inherited init({$IFDEF DEBUGBUILD}'{D8494E55-1296-45ED-A5ED-175D6C0671F5}',{$ENDIF}100{,sizeof(TCableDesctiptor)});
end;
destructor TCableDesctiptor.done;
begin
     name:='';
     Segments.done;
     //inherited;
end;

procedure TCableManager.build;
var pobj,pobj2:PGDBObjCable;
    ir,ir2,ir3:itrec;
    p1,p2:ppointer;
    tp:pointer;
    pvn,pvn2:pvardesk;
    sname:gdbstring;
    pcd,prevpcd:PTCableDesctiptor;
    tcd:TCableDesctiptor;
    itsok:boolean;
    pnp:PTNodeProp;
    sorted:boolean;
    lastadddevice:PGDBObjDevice;
    pentvarext,pentvarext2:PTVariablesExtender;
begin
     //** Создание списка всех кабелей по их имени + дополнительно собирается длина кабеля
     pobj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir); //выбрать первый элемент чертежа
     if pobj<>nil then
     repeat                                                   //перебор всех элементов чертежа
           if pobj^.GetObjType=GDBCableID then                //работа только с кабелями
           begin
                pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));   //получаем доступ к РТТИ что бы можно было просматривать что на заполнял пользователь
                //pvn:=PTObjectUnit(pobj^.ou.Instance)^.FindVariable('NMO_Name');
                pvn:=pentvarext^.entityunit.FindVariable('NMO_Name');      //находим обозначение кабеля (ШС2)
                if pvn<>nil then
                                sname:=pgdbstring(pvn^.data.Instance)^
                            else
                                sname:=rsNameAbsent;
                if sname='RS' then
                               sname:=sname;
                pcd:=FindOrCreate(sname);                                         //поиск или создание нового элемента в списки. Если такое имя в списке есть, то возвращает указатель на него, если нет то создает новый.
                pcd^.Segments.PushBackData(pobj);                                 //добавляем к сегменту новый кабель
                //pvn:=PTObjectUnit(pobj^.ou.Instance)^.FindVariable('AmountD');
                pvn:=pentvarext^.entityunit.FindVariable('AmountD');              //получаем длину кабеля
                if pvn<>nil then
                                pcd^.length:=pcd^.length+pgdbdouble(pvn^.data.Instance)^; //доюавляем к шлейфу общую длину
           end;
           pobj:=drawings.GetCurrentROOT.ObjArray.iterate(ir);    //следующий элемент в списке чертежа
     until pobj=nil;

     pcd:=beginiterate(ir2);         //перебираем полученый список разноименных кабелей
     if pcd<>nil then
     repeat
           ///****сортировка внутри кабельного контейнера, по возрастанию сегмента кабеля забитого пользователем ***///
           if pcd^.Segments.Count>1 then       //более одного кабеля с таким именим
           begin
                repeat
                itsok:=true;
                pobj2:=pcd^.Segments.beginiterate(ir);
                pentvarext2:=pobj2^.GetExtension(typeof(TVariablesExtender));
                p2:=pointer(ir.itp);
                pobj:=pcd^.Segments.iterate(ir);
                p1:=pointer(ir.itp);
                if pobj<>nil then
                repeat
                      pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
                      //pvn :=PTObjectUnit(pobj^.ou.Instance)^.FindVariable('CABLE_Segment');
                      //pvn2:=PTObjectUnit(pobj2^.ou.Instance)^.FindVariable('CABLE_Segment');
                      pvn :=pentvarext^.entityunit.FindVariable('CABLE_Segment');
                      pvn2:=pentvarext2^.entityunit.FindVariable('CABLE_Segment');
                      if pgdbinteger(pvn^.data.Instance)^<
                         pgdbinteger(pvn2^.data.Instance)^ then
                         begin
                              tp:=p2^;
                              p2^:=p1^;
                              p1^:=tp;
                              itsok:=false;
                         end
                            else
                                begin
                                pobj2:=pobj;
                                pentvarext2:=pentvarext;
                                end;
                      p2:=p1;
                      pobj:=pcd^.Segments.iterate(ir);
                      if pobj<>nil then
                                       p1:=pointer(ir.itp);
                until pobj=nil;
                until itsok;
           end;
           ///***сортировка закончина***///

           {***Заполнение кабелей, а именно какой кабель какие девайсы подключает с учетом стойков.
                формирует стартовый девайc и конечный.
                А так же список всех девайсов на данном шлейфе
                от себя плохо понял как работает это место***}
                lastadddevice:=nil;                                      // промежуточная переменная
                pobj:=pcd^.Segments.beginiterate(ir);                    // перебераем кабели, одного шлейфа
                pcd^.StartSegment:=pobj;                                 // присваеваем что это первый кабель
                      pnp:=pobj^.NodePropArray.beginiterate(ir3);        // список, устройств подключеных к кабелю.
                      pcd^.StartDevice:=pnp^.DevLink;
                if pobj<>nil then
                repeat
                      pnp:=pobj^.NodePropArray.beginiterate(ir3);
                      //pcd^.StartDevice:=pnp^.DevLink;
                      if pnp<>nil then
                      repeat
                            if pnp^.DevLink<>nil then
                            begin
                                 if pnp^.DevLink<>lastadddevice then
                                 begin
                                       pcd^.Devices.PushBackData(pnp^.DevLink);
                                       lastadddevice:=pnp^.DevLink;
                                 end;
                                 if pcd^.EndDevice<>nil then
                                 begin
                                      pvn :=FindVariableInEnt(pnp^.DevLink,'RiserName');
                                      pvn2:=FindVariableInEnt(pcd^.EndDevice,'RiserName');
                                      if (pvn<>nil)and(pvn2<>nil)then
                                      begin
                                           if pstring(pvn^.data.Instance)^=pstring(pvn2^.data.Instance)^ then
                                           begin
                                                pvn :=FindVariableInEnt(pnp^.DevLink,'Elevation');
                                                pvn2:=FindVariableInEnt(pcd^.EndDevice,'Elevation');
                                                if (pvn<>nil)and(pvn2<>nil)then
                                                begin
                                                     pcd^.length:=pcd^.length+abs(pgdbdouble(pvn^.data.Instance)^-pgdbdouble(pvn2^.data.Instance)^);
                                                end;
                                           end;
                                      end;
                                 end;
                            end;
                            pcd^.EndDevice:=pnp^.DevLink;
                            pnp:=pobj^.NodePropArray.iterate(ir3);
                      until pnp=nil;
                      pobj:=pcd^.Segments.iterate(ir);
                until pobj=nil;
           pcd:=iterate(ir2);
     until pcd=nil;
     //****************сбор данных заполнения кабелей закончен**********//

     //**********сортировка шлейфов по возврастанию, от ШС1..ШС9,ШС10..ШСх
     repeat
       sorted:=false;
       prevpcd:=beginiterate(ir2);
       pcd:=iterate(ir2);
       if (prevpcd<>nil)and(pcd<>nil) then
       repeat
             if {CompareNUMSTR}AnsiNaturalCompare(prevpcd^.Name,pcd^.Name)>0 then
                                            begin
                                                 tcd:=prevpcd^;
                                                 prevpcd^:=pcd^;
                                                 pcd^:=tcd;
                                                 sorted:=true;
                                            end;
             prevpcd:=pcd;
             pcd:=iterate(ir2);
       until pcd=nil;
     until not sorted;
     //*****************сортировка шлейфов окончена*************//

     {pcd:=beginiterate(ir2);
     if (pcd<>nil) then
     repeat
           HistoryOutStr('Cable "'+pcd^.Name+'", segments '+inttostr(pcd^.Segments.Count));
           pcd:=iterate(ir2);
     until pcd=nil;}
end;
function TCableManager.FindOrCreate;
var
    pcd:PTCableDesctiptor;
    ir:itrec;
    sn:gdbstring;
begin
     sn:=uppercase(sname);
     pcd:=beginiterate(ir);
     if pcd<>nil then
     repeat
           if uppercase(pcd^.Name)=sn then
                                             system.break;
           pcd:=iterate(ir);
     until pcd=nil;
     if pcd=nil then
     begin
          pcd:=pointer(self.CreateObject);
          pcd^.init;
          pcd^.name:=sname;
     end;
     result:=pcd;
end;
destructor TCableManager.done;
var
    pcd:PTCableDesctiptor;
    ir:itrec;
begin
     pcd:=beginiterate(ir);
     if pcd<>nil then
     repeat
           pcd^.Segments.Clear;
           pcd^.Devices.Clear;

           pcd:=iterate(ir);
     until pcd=nil;
     inherited;
end;
function TCableManager.Find;
var
    pcd:PTCableDesctiptor;
    ir:itrec;
    sn:gdbstring;
begin
     sn:=uppercase(sname);
     pcd:=beginiterate(ir);
     if pcd<>nil then
     repeat
           if uppercase(pcd^.Name)=sn then
                                             system.break;
           pcd:=iterate(ir);
     until pcd=nil;
     result:=pcd;
end;
begin
end.
