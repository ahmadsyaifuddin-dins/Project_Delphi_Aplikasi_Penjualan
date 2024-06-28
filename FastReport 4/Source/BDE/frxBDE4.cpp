//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frxBDE4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("frxBDEReg.pas");
USERES("frxBDEReg.dcr");
USEPACKAGE("vcldb40.bpi");
USEPACKAGE("frx4.bpi");
USEPACKAGE("fs4.bpi");
USEPACKAGE("frxDB4.bpi");
USEPACKAGE("fsBDE4.bpi");
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
