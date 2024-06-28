
#include <vcl.h>
#pragma hdrstop
USEUNIT("fqbClass.pas");
USEUNIT("fqbSynmemo.pas");
USEUNIT("fqbLinkForm.pas");
USEUNIT("fqbUtils.pas");
USEUNIT("fqbDesign.pas");
USEUNIT("fqbZLib.pas");
USEPACKAGE("vcl50.bpi");
USEPACKAGE("vclx50.bpi");
USEPACKAGE("vcldb50.bpi");
USEPACKAGE("vclbde50.bpi");

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

