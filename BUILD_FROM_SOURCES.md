## Building from sources

The program has 2 assembly modes **ZCAD** and **ZCADELECTROTECH**, in the first only basic CAD functions, in the second plus a bit of electrical specifics.
I advise you to try to build **ZCADELECTROTECH**, because I always use it myself, respectively, it is more stable.

A simple compilation of the sources will only give you a file `zcad.exe`, but in order to work, some other files are needed, without which the program does not work
(not to mention `allgeneratedfiles.inc`, `zcadversion.inc` and `buildmode.inc` without which it does not even compile)

To automate the build process, a script was written based on the make build system.
I will describe its use in relation to 32bit Lazarus2.2 and fpc3.2.2 on Windows

### 1 Installing Lazarus
Installing the latest Lazarus release (2.2 at the time of writing). zcad is guaranteed to be compiled in trunk Lazarus by trunk fpc,
there are nuances with releases, but they are solvable.

We launch, check the performance of Lazarus - we build a test empty project. there shouldn't be any problems here.

We are looking for the bundled fpc utility `make`, it most likely lies here `lazarus\fpc\3.2.2\bin\i386-win32\make.exe` but, you never know.
In the future, I believe that Lazarus is installed on disk C, and the path to run 'make' is respectively `C:\lazarus\fpc\3.2.2\bin\i386-win32\make.exe`
if anything - to clarify the place)).

You will also need the following paths:
* path to Lazarus `C:\lazarus`
* the path to the Lazarus primary settings file, by default it is `C:\Users\<USERNAME>\AppData\Local\lazarus`

If your username is in non latin - additional actions are required, users with normal names calmly proceed to step 2.

The non latin (cyrillic) symbols in the paths is not supported by the `make` utility, or I didn't figure it out. We will have to "reconfigure" Lazarus so that the settings are stored in "normal" ways.
To do this, in the folder `C:\lazarus` creating a file `runlazarus.bat` with the following content:

`startlazarus.exe --pcp=C:\lazarus\mylazcfg`

and then we always use it to launch Lazarus IDE, everything that is written below you should edit on the assumption that the path to the Lazarus settings will be `C:\lazarus\mylazcfg`

### 2 Getting ZCAD
We clone the source code of zcad (or download it as an archive, but this is bad, it's better git clone). Some parts of zcad source code are decorated with git submodules, so the zcad submodules need to be initialized and updated. For the reasons described above, the path to the `zcad` folder should not contain non-Latin characters
There will be a lot of files\folders, but the main ones:
* `zcad\cad_source` - zcad source folder
* `zcad\environment` - a folder with the program environment files and the source of a small program 'typeexporter' that configures the zcad sources for compilation
* `zcad\Makefile` - a file with installation scripts
* `zcad\cad` - there is no such folder initially, it will be created in step 4 and contains a compiled zcad distribution with all the necessary files

### 3 Installing packages that ZCAD depends on
To make it easier, I have attached the packages on which ZCAD depends to the source distribution (with the exception of those included in Lazarus). Open the command line in the zcad folder,
where the `Makefile' file is located.

You need to install the packages required to compile the zcad in Lazarus, the item is executed only once, for the newly installed Lazarus, if the packages are installed,
skip this item (but if something happens, then re-execution does not bear anything terrible).
We perform:

`C:\lazarus\fpc\3.2.2\bin\i386-win32\make installpkgstolaz LP=C:\lazarus PCP=C:\Users\<USERNAME>\AppData\Local\lazarus`

**installpkgstolaz** this will write the required packages from `zcad\cad_source\other` and `zcad\cad_source\components` to Lazarus configs and will rebuild Lazarus.
For unclear reasons, builting at this point sometimes fails, but that's okay, just go ahead, Lazarus will compile everything you need in 4.

### 4 Compiling ZCAD
Actually, we run the compilation of the zcad by running the following:

`C:\lazarus\fpc\3.2.2\bin\i386-win32\make cleanzcadelectrotech LP=C:\lazarus PCP=C:\Users\<USERNAME>\AppData\Local\lazarus`

**cleanzcadelectrotech** - this target will build the program in **ZCADELECTROTECH** mode, replace with **cleanzcad** - if you want **ZCAD mode**

The script will do the following:

* **WILL ERASE** folders `zcad\cad` and `zcad\cad_source\autogenerated` if they are present **WITH ALL THEIR CONTENTS** without asking anything
* creates folders `zcad\cad` and `zcad\cad_source\autogenerated`
* copies the files needed for work from `zcad\environment\runtimefiles` to `zcad\cad`
* creates the file `zcad\cad_source\zcadversion.inc`
* creates the file `zcad\cad_source\autogenerated\buildmode.inc`
* compile `zcad\cad_source\cad_source\utils\typeexporter.lpi` and run it with necessary parameters, `typeexporter` in turn fill `zcad\cad_source\autogenerated` will create `zcad\cad_source\autogenerated\allgeneratedfiles.inc` (**only after this step zcad can be compiled**)
* compile zcad

If everything went fine, we have a properly filled folder `zcad\cad`, including a newly created executable binary `zcad\cad\bin\i386-win32\zcad.exe`
In the future, you can simply open the file `zcad\cad_source\zcad.lpi` in Lazarus and watch-collect the sources as usual in the IDE

PS.
Lazarus, FPC and ZCAD are developing projects, information is fast outdated and there are nuances. In particular, at the moment due to the FPC bug
https://gitlab.com/freepascal.org/fpc/source/-/issues/39387 in the IDE only a complete rebuild of the code works, i.e. in Lazarus if you just click
**F9** zcad will not assemble with a compiler failure, with any changes it is always necessary to perform a complete rebuild **shift-F9**