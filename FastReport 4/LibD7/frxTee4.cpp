//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frx4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("frxRegTee.pas");
USEUNIT("frxChart.pas");
USEUNIT("frxChartEditor.pas");
USEUNIT("frxChartRTTI.pas");
USERES("frxReg.dcr");
USEPACKAGE("vclsmp40.bpi");
USEPACKAGE("vclx40.bpi");
USEPACKAGE("vcljpg40.bpi");
USEPACKAGE("tee40.bpi");
USEPACKAGE("teeui40.bpi");
USEPACKAGE("fs4.bpi");
USEPACKAGE("fsTee4.bpi");
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
