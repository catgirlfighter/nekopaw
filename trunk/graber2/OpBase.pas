unit OpBase;

interface

uses SysUtils, GraberU;

var
  FullResList: TResourceList;
  CurrList: TResourceList;
  rootdir: string;

implementation

initialization

  FullResList := TResourceList.Create;
  rootdir := ExtractFileDir(paramstr(0));

finalization

  FullResList.Free;

end.
