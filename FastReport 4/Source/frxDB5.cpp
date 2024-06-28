//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frx5.res");
USEUNIT("frxRegDB.pas");
USERES("frxReg.dcr");
USEPACKAGE("vcl50.bpi");
USEPACKAGE("vcldb50.bpi");
USEPACKAGE("fs5.bpi");
USEPACKAGE("fsDB5.bpi");
USEPACKAGE("frx5.bpi");
USEPACKAGE("fqb50.bpi");
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
