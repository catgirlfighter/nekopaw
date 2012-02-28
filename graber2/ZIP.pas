unit ZIP;

interface

uses ShellApi, Variants, OleAuto;

const
  SHCONTCH_NOPROGRESSBOX = 4;
  SHCONTCH_AUTORENAME = 8;
  SHCONTCH_RESPONDYESTOALL = 16;
  SHCONTF_INCLUDEHIDDEN = 128;
  SHCONTF_FOLDERS = 32;
  SHCONTF_NONFOLDERS = 64;

function ShellUnzip(zipfile, targetfolder: string; filter: string = ''): boolean;

implementation

function ShellUnzip(zipfile, targetfolder: string; filter: string = ''): boolean;
var
  shellobj: variant;
  srcfldr, destfldr: variant;
  shellfldritems: variant;

begin
  shellobj := CreateOleObject('Shell.Application');

  srcfldr := shellobj.NameSpace(zipfile);
  destfldr := shellobj.NameSpace(targetfolder);

  shellfldritems := srcfldr.Items;
  if (filter <> '') then
    shellfldritems.Filter(SHCONTF_INCLUDEHIDDEN or SHCONTF_NONFOLDERS or SHCONTF_FOLDERS,filter);

  destfldr.CopyHere(shellfldritems, SHCONTCH_NOPROGRESSBOX or SHCONTCH_RESPONDYESTOALL);
end;

end.
