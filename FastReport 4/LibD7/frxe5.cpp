//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frxe5.res");
USEUNIT("frxeReg.pas");
USEUNIT("frxrcExports.pas");
USERES("frxeReg.dcr");
USEPACKAGE("vcl50.bpi");
USEPACKAGE("vcljpg50.bpi");
USEPACKAGE("vclx50.bpi");
USEPACKAGE("frx5.bpi");
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
