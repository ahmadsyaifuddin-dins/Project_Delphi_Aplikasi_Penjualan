//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frx5.res");
USEUNIT("frxReg.pas");
USEUNIT("frxrcClass.pas");
USEUNIT("frxrcDesgn.pas"); 
USEUNIT("frxrcInsp.pas");
USERES("frxReg.dcr");
USEPACKAGE("vcl50.bpi");
USEPACKAGE("vclsmp50.bpi");
USEPACKAGE("vclx50.bpi");
USEPACKAGE("vcljpg50.bpi");
USEPACKAGE("fs5.bpi");
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
