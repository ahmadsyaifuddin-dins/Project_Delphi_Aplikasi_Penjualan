//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("frxIBX5.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("frxIBXReg.pas");
USEUNIT("frxIBXComponents.pas");
USEUNIT("frxIBXEditor.pas");
USEUNIT("frxIBXRTTI.pas");
USERES("frxIBXReg.dcr");
USEPACKAGE("vcldb50.bpi");
USEPACKAGE("vclib50.bpi");
USEPACKAGE("frx5.bpi");
USEPACKAGE("fs5.bpi");
USEPACKAGE("frxDB5.bpi");
USEPACKAGE("fsIBX5.bpi");
USEPACKAGE("fqb50.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------
