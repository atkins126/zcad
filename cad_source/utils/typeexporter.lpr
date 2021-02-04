{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev)
}

program typeexporter;
{$APPTYPE CONSOLE}
 uses
  SysUtils,iolow,classes{,uzbpaths};

const IgnoreSHP=#13;
      BreakSHP=#10;
      starttoken='{EXPORT+}';
      endtoken='{EXPORT-}';
      objregtoken='{REGISTEROBJECTTYPE ';
      recregtoken='{REGISTERRECORDTYPE ';
      PathPrefixToket='pathprefix=';
      OutputFileToket='outputfile=';
      ProcessFilesToken='processfiles=';
var
   outhandle,allgeneratedfiles:cardinal;
   FileName:pstring;
   FileNames:TStringList;
   error:boolean;
   //ir:itrec;
   i:integer;

   PathPrefix:string='E:/zcad/cad_source/';
   OutputFile:string='E:/zcad/cad/rtl/system.pas';
   ProcessFiles:string='zcad.files';
   CurrentFile:string;
   AutoRegisterPath,AutoGeneratedFile:string;
   TmpOutputFile:string;
   TmpFileSuffix:string='.tmp';
function createoutfile(name:string):cardinal;
var filehandle:cardinal;
begin
  filehandle:=0;
  filehandle := FileCreate(name);
  result:=filehandle;
end;
function closeoutfile(filehandle:cardinal):cardinal;
begin
  fileclose(filehandle);
end;
procedure writestring(h: integer; s: string);
begin
  if s='//Generate on E:\zcad\CAD_SOURCE\gdb\GDBtext.pas' then
               s:=s;
  s := s + eol;
  FileWrite(h,s[1],length(s));
end;
procedure processfile(name:string;handle:cardinal);
var f:filestream;
    line,lineend:string;
    expblock:integer;
    find,find2,find3:integer;
begin
  expblock:=0;
  f.init(10000);
  f.assign(name,fmShareDenyNone);
  line:='';
  lineend:='';
  line:=f.readgdbstring;
  while f.filesize<>f.currentpos do
    begin
         if (pos('PROCEDURE',uppercase(line))<=0)and
            (pos('FUNCTION',uppercase(line))<=0)and
            (pos('CONSTRUCTOR',uppercase(line))<=0)and
            (pos('DESTRUCTOR',uppercase(line))<=0) then
         begin
         find:=pos(starttoken,uppercase(line));
         if find>0 then
                       begin
                            find:=find+length(starttoken);
                            inc(expblock);
                            line:=copy(line,find,length(line)-find+1);
                       end;
         find:=pos(endtoken,uppercase(line));
         if find>0 then
                       begin
                            DEC(expblock);
                            lineend:=copy(line,1,find-1);
                       end;
         if (lineend<>'') then writestring(handle,lineend);
         lineend:='';
         if (expblock>0)and(line<>'') then
         begin
              //{-}PGDBObjVisible{/pointer/}
              find:=pos('{-}',line);
              if find>0 then
              begin
                   find2:=pos('{/',line);
                   find3:=pos('/}',line);
                   if (find2>find)and(find3>find2) then
                   begin
                        line:=copy(line,1,find-1)+copy(line,find2+2,find3-find2-2)+copy(line,find3+2,length(line)-find3+2);
                   end;

              end;
              writestring(handle,line);
         end;
         end;
         line:=f.readgdbstring;
         {fileclose(handle);
         handle:=FileOpen('C:\CAD\components\type\GDBObjectsdef.pas', fmOpenWrite);
         FileSeek(handle,0,2);}
    end;
    f.close;
    f.done;
end;
procedure CreateRegistrationFile(filename,objname,unitname:string;allgeneratedfiles:cardinal);
var
    createdfilehandle:cardinal;
begin
createdfilehandle:=createoutfile(AutoRegisterPath+filename+'.pas');
writestring(createdfilehandle,'unit '+filename+';');
writestring(createdfilehandle,'{$INCLUDE def.inc}');
writestring(createdfilehandle,'{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}');
writestring(createdfilehandle,'interface');
if uppercase(unitname)<>'VARMAN' then
  writestring(createdfilehandle,'uses UObjectDescriptor,Varman,TypeDescriptors,'+unitname+';')
else
  writestring(createdfilehandle,'uses UObjectDescriptor,Varman,TypeDescriptors;');
writestring(createdfilehandle,'implementation');
writestring(createdfilehandle,'var');
writestring(createdfilehandle,'pt:PObjectDescriptor;');
writestring(createdfilehandle,'initialization');
writestring(createdfilehandle,'if assigned(SysUnit) then');
writestring(createdfilehandle,'begin');
writestring(createdfilehandle,'     pt:=SysUnit.ObjectTypeName2PTD('''+objname+''');');
writestring(createdfilehandle,'     pt^.RegisterTypeinfo(TypeInfo('+objname+'));');
writestring(createdfilehandle,'     pt^.RegisterObject(TypeOf('+objname+'),@'+objname+'.initnul);');
writestring(createdfilehandle,'     pt^.AddMetod('''',''initnul'','''',@'+objname+'.initnul,m_constructor);');
writestring(createdfilehandle,'end;');
writestring(createdfilehandle,'end.');
closeoutfile(createdfilehandle);
writestring(allgeneratedfiles,filename+',');
end;

procedure CreateRecRegistrationFile(filename,objname,unitname:string;allgeneratedfiles:cardinal);
var
    createdfilehandle:cardinal;
begin
createdfilehandle:=createoutfile(AutoRegisterPath+filename+'.pas');
writestring(createdfilehandle,'unit '+filename+';');
writestring(createdfilehandle,'{$INCLUDE def.inc}');
writestring(createdfilehandle,'{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}');
writestring(createdfilehandle,'interface');
writestring(createdfilehandle,'uses URecordDescriptor,Varman,TypeDescriptors,'+unitname+';');
writestring(createdfilehandle,'implementation');
writestring(createdfilehandle,'var');
writestring(createdfilehandle,'pr:PRecordDescriptor;');
writestring(createdfilehandle,'initialization');
writestring(createdfilehandle,'if assigned(SysUnit) then');
writestring(createdfilehandle,'begin');
writestring(createdfilehandle,'     pr:=SysUnit.ObjectTypeName2PTD('''+objname+''');');
writestring(createdfilehandle,'     pr^.RegisterTypeinfo(TypeInfo('+objname+'));');
writestring(createdfilehandle,'end;');
writestring(createdfilehandle,'end.');
closeoutfile(createdfilehandle);
writestring(allgeneratedfiles,filename+',');
end;


procedure processfileabstract(name:string;handle:cardinal);
var f:filestream;
    line,lineend,fn:string;
    expblock:integer;
    find,find2,find3:integer;
    inobj,alreadyinuses:boolean;
begin
  alreadyinuses:=false;
  writestring(handle,'//Generate on '+name);
  expblock:=0;
  f.init(10000);
  f.assign(name,fmShareDenyNone);
  write('  Process file: ',f.name);
  if f.filesize<>-1 then
  begin
  line:='';
  lineend:='';
  line:=f.readgdbstring;
  inobj:=false;
  while f.filesize<>f.currentpos do
    begin
         find:=pos(objregtoken,uppercase(line));
         if find>0 then
                       begin
                            find:=find+length(objregtoken);
                            line:=copy(line,find,length(line)-find);
                            //if not alreadyinuses then
                                                 begin
                                                      fn:=ExtractFileName(name);
                                                      fn:=copy(fn,1,pos('.',fn)-1);
                                                 end;
                            CreateRegistrationFile('areg'+line,line,fn,allgeneratedfiles);
                            alreadyinuses:=true;
                            line:='';
                       end;
         find:=pos(recregtoken,uppercase(line));
         if find>0 then
                       begin
                            find:=find+length(objregtoken);
                            line:=copy(line,find,length(line)-find);
                                                 begin
                                                      fn:=ExtractFileName(name);
                                                      fn:=copy(fn,1,pos('.',fn)-1);
                                                 end;
                            CreateRecRegistrationFile('areg'+line,line,fn,allgeneratedfiles);
                            alreadyinuses:=true;
                            line:='';
                       end;
         find:=pos('OBJECT',uppercase(line));
         if find>0 then inobj:=true;
         find:=pos('END;',uppercase(line));
         if inobj and (find>0) then inobj:=false;
         begin
         find:=pos(starttoken,uppercase(line));
         if find>0 then
                       begin
                            find:=find+length(starttoken);
                            inc(expblock);
                            line:=copy(line,find,length(line)-find+1);
                       end;
         find:=pos(endtoken,uppercase(line));
         if find>0 then
                       begin
                            DEC(expblock);
                            lineend:=copy(line,1,find-1);
                       end;
         if (lineend<>'') then writestring(handle,lineend);
         lineend:='';
         if (expblock>0)and(line<>'') then
         begin
              //{-}PGDBObjVisible{/pointer/}
              find:=pos('{-}',line);
              if find>0 then
              begin
                   find2:=pos('{/',line);
                   find3:=pos('/}',line);
                   if (find2>find)and(find3>find2) then
                   begin
                        line:=copy(line,1,find-1)+copy(line,find2+2,find3-find2-2)+copy(line,find3+2,length(line)-find3+2);
                   end;

              end;
         if (pos('VIRTUAL',uppercase(line))>0) then
         begin
              if (pos('ABSTRACT',uppercase(line))<=0) then
                                                          line:=line+'abstract;';
              writestring(handle,line);
         end
         else if {((pos('PROCEDURE',uppercase(line))<=0)and
            (pos('FUNCTION',uppercase(line))<=0)and
            (pos('CONSTRUCTOR',uppercase(line))<=0)and
            (pos('DESTRUCTOR',uppercase(line))<=0))} true and inobj then writestring(handle,line)
            else  if not inobj then writestring(handle,line);
         end;
         end;
         line:=f.readgdbstring;


         {fileclose(handle);
         handle:=FileOpen('C:\CAD\components\type\GDBObjectsdef.pas', fmOpenWrite);
         FileSeek(handle,0,2);}
    end;

    writeln('...OK');
  end
  else
      begin
           writeln('...ERROR! Source file not found');
           error:=true;
      end;
    f.close;
    f.done;
{$R *.res}


end;
procedure parsecommandline;
var
    i:integer;
    param,paramUC:string;
begin
for i:=1 to paramcount do
  begin
       {$ifdef windows}param:={SysToUTF8}(paramstr(i));{$endif}
       {$ifndef windows}param:=paramstr(i);{$endif}
       paramUC:=lowercase(param);

{      PathPrefixToket='pathprefix=';
      OutputFileToket='outputfile=';}
      if pos(PathPrefixToket,paramUC)=1 then
      begin
         PathPrefix:=Copy(param,length(PathPrefixToket)+1,length(param)-length(PathPrefixToket));
      end
 else if pos(OutputFileToket,paramUC)=1 then
      begin
         OutputFile:=Copy(param,length(OutputFileToket)+1,length(param)-length(OutputFileToket));
      end
 else if pos(ProcessFilesToken,paramUC)=1 then
      begin
         ProcessFiles:=Copy(param,length(ProcessFilesToken)+1,length(param)-length(ProcessFilesToken));
      end
 else begin
         writeln(format('Unknown parameter "%s"',[param]));
         writeln;
      end
  end;
end;
function GetPartOfPath(out part:String;var path:String;const separator:String):String;
var
   i:Integer;
begin
           i:=pos(separator,path);
           if i<>0 then
                       begin
                            part:=copy(path,1,i-1);
                            path:=copy(path,i+1,length(path)-i);
                       end
                   else
                       begin
                            part:=path;
                            path:='';
                       end;
     result:=part;
end;
begin
     writeln('ZCAD data types export utility');
     writeln;
     writeln(' Usage:');
     writeln('       typeexporter.exe pathprefix=path/to/cad_source/ outputfile=path/to/cad/rtl/system.pas ');
     writeln;
     parsecommandline;
     TmpOutputFile:=OutputFile+TmpFileSuffix;
     AutoGeneratedFile:=PathPrefix+'autogenerated/allgeneratedfiles.inc';
     AutoRegisterPath:=PathPrefix+'autogenerated/';
     writeln(format('ParamStr(0)      =%s',[ParamStr(0)]));
     writeln(format('CurrentDir       =%s',[GetCurrentDir]));
     writeln(format('ProcessFiles     =%s',[ProcessFiles]));
     writeln(format('PathPrefix       =%s',[PathPrefix]));
     writeln(format('OutputFile       =%s',[OutputFile]));
     writeln(format('AutoGeneratedFile=%s',[AutoGeneratedFile]));
     writeln(format('AutoRegisterPath =%s',[AutoRegisterPath]));
     writeln;
     //writeln('Process files in filelist.txt:');
     error:=false;
     outhandle:=createoutfile(TmpOutputFile);
     allgeneratedfiles:=createoutfile(AutoGeneratedFile);

     writestring(outhandle,'unit System;');
     writestring(outhandle,'{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}');
     writestring(outhandle,'interface');
     writestring(outhandle,'type');

     FileNames:=TStringList.create;
     while GetPartOfPath(CurrentFile,ProcessFiles,';')<>'' do
     begin
       writeln(format('ProcessFile    =%s',[CurrentFile]));
       FileNames.loadfromfile({ExtractFilePath(paramstr(0))+'filelist.txt'}CurrentFile);

       for i:=0 to FileNames.Count-1 do
         processfileabstract(PathPrefix+FileNames.ValueFromIndex[i],outhandle);
       FileNames.Clear;
     end;


     writestring(outhandle,'implementation');
     writestring(outhandle,'begin');
     writestring(outhandle,'end.');
     closeoutfile(outhandle);
     closeoutfile(allgeneratedfiles);

     if error then
                  begin
                       writeln;
                       writeln(format('Errors found. File "%s" not created!',[OutputFile]))
                  end
              else
                  begin
                       DeleteFile(OutputFile);
                       RenameFile(TmpOutputFile,OutputFile);
                       DeleteFile(TmpOutputFile);
                  end;
end.


