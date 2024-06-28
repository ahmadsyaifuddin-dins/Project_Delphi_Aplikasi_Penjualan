{******************************************}
{                                          }
{            FastQueryBuilder              }
{          Language resource file          }
{                                          }
{         Copyright (c) 1998-2005          }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit fqbrcDesign;

interface

implementation

uses fqbRes;

const resStr =
'1=Ok' + #13#10 +
'2=Cancel' + #13#10 +
'1803=Clear' + #13#10 +
'1804=Save to file' + #13#10 +
'1805=Load from file' + #13#10 +
'1806=Model' + #13#10 +
'1807=SQL' + #13#10 +
'1808=Result' + #13#10 +
'-------TfqbGrid-------' + #13#10 +
'1820=Collumn' + #13#10 +
'1821=Visible' + #13#10 +
'1822=Where' + #13#10 +
'1823=Sort' + #13#10 +
'1824=Function' + #13#10 +
'1825=Group' + #13#10 +
'1826=Move up' + #13#10 +
'1827=Move down' + #13#10 +
'1828=Visible' + #13#10 +
'1829=Not Visible' + #13#10 +
'1830=No' + #13#10 +
'1831=Ascending' + #13#10 +
'1832=Descending' + #13#10 +
'1833=Grouping' + #13#10 +
'';

initialization
  fqbResources.AddStrings(resStr);

end.
