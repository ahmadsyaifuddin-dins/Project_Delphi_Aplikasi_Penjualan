//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frx4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("frxRegIBO.pas");
USERES("frxReg.dcr");
USEPACKAGE("IBO40CRT_C4.bpi");
USEPACKAGE("IBO40FRT_C4.bpi");
USEPACKAGE("IBO40TRT_C4.bpi");
USEPACKAGE("IBO40VRT_C4.bpi");
USEPACKAGE("IBO40XRT_C4.bpi");
USEPACKAGE("fs4.bpi");
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
