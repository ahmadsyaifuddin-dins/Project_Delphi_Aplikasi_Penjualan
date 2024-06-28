//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("frx5.res");
USEUNIT("frxRegIBO.pas");
USERES("frxReg.dcr");
USEPACKAGE("vcl50.bpi");
USEPACKAGE("IBO40CRT_C5.bpi");
USEPACKAGE("IBO40FRT_C5.bpi");
USEPACKAGE("IBO40TRT_C5.bpi");
USEPACKAGE("IBO40VRT_C5.bpi");
USEPACKAGE("IBO40XRT_C5.bpi");
USEPACKAGE("fs5.bpi");
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
