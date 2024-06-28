//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frx4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("frxRegDB.pas");
USERES("frxReg.dcr");
USEPACKAGE("vcldb40.bpi");
USEPACKAGE("fs4.bpi");
USEPACKAGE("fsDB4.bpi");
USEPACKAGE("frx4.bpi");
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
