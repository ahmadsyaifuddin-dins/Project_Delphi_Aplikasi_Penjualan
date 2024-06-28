//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frx4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("frxReg.pas");
USEUNIT("frxrcClass.pas");
USEUNIT("frxrcDesgn.pas"); 
USEUNIT("frxrcInsp.pas");
USERES("frxReg.dcr");
USEPACKAGE("vclsmp40.bpi");
USEPACKAGE("vclx40.bpi");
USEPACKAGE("vcljpg40.bpi");
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
