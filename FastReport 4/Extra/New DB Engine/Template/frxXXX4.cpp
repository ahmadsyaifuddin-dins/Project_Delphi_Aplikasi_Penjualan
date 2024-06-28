//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frxXXX4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("frxXXXReg.pas");
USERES("frxXXXReg.dcr");
USEPACKAGE("vcldb40.bpi");
USEPACKAGE("PXXX40.bpi");
USEPACKAGE("frx4.bpi");
USEPACKAGE("frxDB4.bpi");
USEPACKAGE("fs4.bpi");
USEPACKAGE("fqb40.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------
//   Package source.
//---------------------------------------------------------------------------
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------
