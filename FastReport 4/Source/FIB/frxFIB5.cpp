//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("frxFIB5.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("frxFIBReg.pas");
USEUNIT("frxFIBComponents.pas");
USEUNIT("frxFIBEditor.pas");
USEUNIT("frxFIBRTTI.pas");
USERES("frxFIBReg.dcr");
USEPACKAGE("vcldb50.bpi");
USEPACKAGE("FIBPlus_CB5.bpi");
USEPACKAGE("frx5.bpi");
USEPACKAGE("fs5.bpi");
USEPACKAGE("fsDB5.bpi");
USEPACKAGE("frxDB5.bpi");
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
