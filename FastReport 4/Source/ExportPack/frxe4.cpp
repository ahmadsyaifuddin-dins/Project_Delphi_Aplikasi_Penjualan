//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frxe4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("frxeReg.pas");
USEUNIT("frxrcExports.pas");
USERES("frxeReg.dcr");
USEPACKAGE("vcljpg40.bpi");
USEPACKAGE("vclx40.bpi");
USEPACKAGE("frx4.bpi");
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
