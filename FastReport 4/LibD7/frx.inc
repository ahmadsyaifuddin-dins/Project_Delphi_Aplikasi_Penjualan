{$DEFINE QBUILDER}
{******************************************}
{                                          }
{             FastReport v4.0              }
{              Include file                }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}


{$B-} {- Complete Boolean Evaluation }
{$R-} {- Range-Checking }
{$V-} {- Var-String Checking }
{$T-} {- Typed @ operator }
{$X+} {- Extended syntax }
{$P+} {- Open string params }
{$J+} {- Writeable structured consts }
{$H+} {- Use long strings by default }

{$IFDEF VER120}      // Delphi 4.0
  {$DEFINE Delphi4}
{$ENDIF}

{$IFDEF VER130}      // Delphi 5.0
  {$DEFINE Delphi4}
  {$DEFINE Delphi5}
{$ENDIF}

{$IFDEF VER140}      // Delphi 6.0
  {$DEFINE Delphi4}
  {$DEFINE Delphi5}
  {$DEFINE Delphi6}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
{$ENDIF}

{$IFDEF VER150}      // Delphi 7.0
  {$DEFINE Delphi4}
  {$DEFINE Delphi5}
  {$DEFINE Delphi6}
  {$DEFINE Delphi7}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
{$ENDIF}

{$IFDEF VER170}      // Delphi 9.0
  {$DEFINE Delphi4}
  {$DEFINE Delphi5}
  {$DEFINE Delphi6}
  {$DEFINE Delphi7}
  {$DEFINE Delphi9}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
{$ENDIF}

{$IFDEF VER180}      // Delphi 10.0
  {$DEFINE Delphi4}
  {$DEFINE Delphi5}
  {$DEFINE Delphi6}
  {$DEFINE Delphi7}
  {$DEFINE Delphi9}
  {$DEFINE Delphi10}
  {$DEFINE RICHBCB}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
{$ENDIF}

{$IFDEF VER125}      // Borland C++ Builder 4.0
  {$DEFINE Delphi4}
  {$ObjExportAll On}
  {$DEFINE BCB}
  {$DEFINE RICHBCB}
{$ENDIF}

{$IFDEF VER130}      // Borland C++ Builder 5.0
  {$IFDEF BCB}
    {$ObjExportAll On}
    {$DEFINE RICHBCB}
  {$ENDIF}
{$ENDIF}

{$IFDEF VER140}      // Borland C++ Builder 6.0
  {$IFDEF BCB}
    {$ObjExportAll On}
    {$DEFINE RICHBCB}
  {$ENDIF}
{$ENDIF}

// Uncomment the following line if you don't want to include component editors
// into your exe (in case if you don't use designer)
//{$DEFINE NO_EDITORS}

//-------------------------Additional components----------------------------

//------------------- JPEG images -----------------------------------
// JPEG images. Adds approximately 100Kb to your EXE.
// If you want to show jpeg images in "Picture" object, uncomment
// the following line:
{$DEFINE JPEG}

//------------------- PNG images -----------------------------------
// PNG images. If you want to show png images in "Picture" object, uncomment
// the following line:
//{$DEFINE PNG}

//------------------- "Open Picture" dialog -------------------------
// Adds approximately 60Kb to your EXE.
// If you want to use standard "Open picture" dialog in picture editor,
// uncomment the following line:
//{$DEFINE OPENPICTUREDLG}

//------------------- Visual Query builder --------------------------
// To use visual query builder, you should install FastQBuilder component.
// It is included in FR3 Pro and FR3 EE by default.
//{$DEFINE QBUILDER}

//------------------- TTabSet control -------------------------------
// In Delphi2005 and BDS2006 you can use TTabSet control instead of TTabControl
// to make a report designer more soft-looked.
{$DEFINE UseTabset}


{$IFDEF FR_COM}
  {$IFDEF FR_LITE}
     {$DEFINE FR_VER_BASIC}
  {$ENDIF}
{$ENDIF}

{$IFNDEF Delphi9}
  {$UNDEF UseTabset}
{$ENDIF}


