unit u_fsummary;

interface

uses Windows, ComObj, ActiveX, Variants, Sysutils;

procedure SetFileSummaryInfo(const FileName : WideString; Author, Title, Subject, Keywords, Comments : WideString);
function GetFileSummaryInfo(const FileName: WideString): String;
function IsNTFS(AFileName : string) : boolean;

implementation

const

FmtID_SummaryInformation: TGUID =     '{F29F85E0-4FF9-1068-AB91-08002B27B3D9}';
FMTID_DocSummaryInformation : TGUID = '{D5CDD502-2E9C-101B-9397-08002B2CF9AE}';
FMTID_UserDefinedProperties : TGUID = '{D5CDD505-2E9C-101B-9397-08002B2CF9AE}';
IID_IPropertySetStorage : TGUID =     '{0000013A-0000-0000-C000-000000000046}';

STGFMT_FILE = 3; //Indicates that the file must not be a compound file.
                 //This element is only valid when using the StgCreateStorageEx
                 //or StgOpenStorageEx functions to access the NTFS file system
                 //implementation of the IPropertySetStorage interface.
                 //Therefore, these functions return an error if the riid
                 //parameter does not specify the IPropertySetStorage interface,
                 //or if the specified file is not located on an NTFS file system volume.

STGFMT_ANY = 4; //Indicates that the system will determine the file type and
                //use the appropriate structured storage or property set
                //implementation.
                //This value cannot be used with the StgCreateStorageEx function.


// Summary Information
 PID_TITLE        = 2;
 PID_SUBJECT      = 3;
 PID_AUTHOR       = 4;
 PID_KEYWORDS     = 5;
 PID_COMMENTS     = 6;
 PID_TEMPLATE     = 7;
 PID_LASTAUTHOR   = 8;
 PID_REVNUMBER    = 9;
 PID_EDITTIME     = 10;
 PID_LASTPRINTED  = 11;
 PID_CREATE_DTM   = 12;
 PID_LASTSAVE_DTM = 13;
 PID_PAGECOUNT    = 14;
 PID_WORDCOUNT    = 15;
 PID_CHARCOUNT    = 16;
 PID_THUMBNAIL    = 17;
 PID_APPNAME      = 18;
 PID_SECURITY     = 19;

 // Document Summary Information
 PID_CATEGORY     = 2;
 PID_PRESFORMAT   = 3;
 PID_BYTECOUNT    = 4;
 PID_LINECOUNT    = 5;
 PID_PARCOUNT     = 6;
 PID_SLIDECOUNT   = 7;
 PID_NOTECOUNT    = 8;
 PID_HIDDENCOUNT  = 9;
 PID_MMCLIPCOUNT  = 10;
 PID_SCALE        = 11;
 PID_HEADINGPAIR  = 12;
 PID_DOCPARTS     = 13;
 PID_MANAGER      = 14;
 PID_COMPANY      = 15;
 PID_LINKSDIRTY   = 16;
 PID_CHARCOUNT2   = 17;

function IsNTFS(AFileName : string) : boolean;
var
fso, drv : OleVariant;
begin
IsNTFS := False;
fso := CreateOleObject('Scripting.FileSystemObject');
drv := fso.GetDrive(fso.GetDriveName(AFileName));
 if drv.FileSystem = 'NTFS' then
  IsNTFS := True;
end;

function StgOpenStorageEx (
 const pwcsName : POleStr;  //Pointer to the path of the
                            //file containing storage object
 grfMode : LongInt;         //Specifies the access mode for the object
 stgfmt : DWORD;            //Specifies the storage file format
 grfAttrs : DWORD;          //Reserved; must be zero
 pStgOptions : Pointer;     //Address of STGOPTIONS pointer
 reserved2 : Pointer;       //Reserved; must be zero
 riid : PGUID;              //Specifies the GUID of the interface pointer
 out stgOpen :              //Address of an interface pointer
 IStorage ) : HResult; stdcall; external 'ole32.dll';


function GetFileSummaryInfo(const FileName: WideString): String;

var
 I: Integer;
 PropSetStg: IPropertySetStorage;
 PropSpec: array of TPropSpec;
 PropStg: IPropertyStorage;
 PropVariant: array of TPropVariant;
 Rslt: HResult;
 S: String;
 Stg: IStorage;
 PropEnum: IEnumSTATPROPSTG;
 HR : HResult;
 PropStat: STATPROPSTG;
 k : integer;

function PropertyPIDToCaption(const ePID: Cardinal): string;
begin
 case ePID of
   PID_TITLE:
     Result := 'Title';
   PID_SUBJECT:
     Result := 'Subject';
   PID_AUTHOR:
     Result := 'Author';
   PID_KEYWORDS:
     Result := 'Keywords';
   PID_COMMENTS:
     Result := 'Comments';
   PID_TEMPLATE:
     Result := 'Template';
   PID_LASTAUTHOR:
     Result := 'Last Saved By';
   PID_REVNUMBER:
     Result := 'Revision Number';
   PID_EDITTIME:
     Result := 'Total Editing Time';
   PID_LASTPRINTED:
     Result := 'Last Printed';
   PID_CREATE_DTM:
     Result := 'Create Time/Date';
   PID_LASTSAVE_DTM:
     Result := 'Last Saved Time/Date';
   PID_PAGECOUNT:
     Result := 'Number of Pages';
   PID_WORDCOUNT:
     Result := 'Number of Words';
   PID_CHARCOUNT:
     Result := 'Number of Characters';
   PID_THUMBNAIL:
     Result := 'Thumbnail';
   PID_APPNAME:
     Result := 'Creating Application';
   PID_SECURITY:
     Result := 'Security';
   else
     Result := '$' + IntToHex(ePID, 8);
   end
end;

begin
 Result := '';
try
 OleCheck(StgOpenStorageEx(PWideChar(FileName),
 STGM_READ or STGM_SHARE_DENY_WRITE,
 STGFMT_FILE,
 0, nil,  nil, @IID_IPropertySetStorage, stg));

 PropSetStg := Stg as IPropertySetStorage;

 OleCheck(PropSetStg.Open(FmtID_SummaryInformation,
    STGM_READ or STGM_SHARE_EXCLUSIVE, PropStg));

 OleCheck(PropStg.Enum(PropEnum));
 I := 0;

 hr := PropEnum.Next(1, PropStat, nil);
  while hr = S_OK do
  begin
    inc(I);
    SetLength(PropSpec,I);
    PropSpec[i-1].ulKind := PRSPEC_PROPID;
    PropSpec[i-1].propid := PropStat.propid;
    hr := PropEnum.Next(1, PropStat, nil);
 end;

 SetLength(PropVariant,i);
 Rslt := PropStg.ReadMultiple(i, @PropSpec[0], @PropVariant[0]);

 if Rslt =  S_FALSE then Exit;

 for k := 0 to i -1 do
  begin
    S := '';
    if PropVariant[k].vt = VT_LPSTR then
      if Assigned(PropVariant[k].pszVal) then
       S := PropVariant[k].pszVal;

    S := Format(PropertyPIDToCaption(PropSpec[k].Propid)+ ' %s',[s]);
   if S <> '' then Result := Result + S + #13;
 end;
 finally
 end;
end;

procedure SetFileSummaryInfo(const FileName : WideString; Author, Title, Subject, Keywords, Comments : WideString);

var
PropSetStg: IPropertySetStorage;
PropSpec: array of TPropSpec;
PropStg: IPropertyStorage;
PropVariant: array of TPropVariant;
Stg: IStorage;

begin
 OleCheck(StgOpenStorageEx(PWideChar(FileName), STGM_SHARE_EXCLUSIVE or STGM_READWRITE, STGFMT_ANY, 0, nil,  nil, @IID_IPropertySetStorage, stg));
 PropSetStg := Stg as IPropertySetStorage;
 OleCheck(PropSetStg.Create(FmtID_SummaryInformation, FmtID_SummaryInformation, PROPSETFLAG_DEFAULT,STGM_CREATE or STGM_READWRITE or STGM_SHARE_EXCLUSIVE, PropStg));
 Setlength(PropSpec,6);
 PropSpec[0].ulKind := PRSPEC_PROPID;
 PropSpec[0].propid := PID_AUTHOR;
 PropSpec[1].ulKind := PRSPEC_PROPID;
 PropSpec[1].propid := PID_TITLE;
 PropSpec[2].ulKind := PRSPEC_PROPID;
 PropSpec[2].propid := PID_SUBJECT;
 PropSpec[3].ulKind := PRSPEC_PROPID;
 PropSpec[3].propid := PID_KEYWORDS;
 PropSpec[4].ulKind := PRSPEC_PROPID;
 PropSpec[4].propid := PID_COMMENTS;
 PropSpec[5].ulKind := PRSPEC_PROPID;
 PropSpec[5].propid := 99;

 SetLength(PropVariant,6);
 PropVariant[0].vt:=VT_LPWSTR;
 PropVariant[0].pwszVal:=PWideChar(Author);
 PropVariant[1].vt:=VT_LPWSTR;
 PropVariant[1].pwszVal:=PWideChar(Title);
 PropVariant[2].vt:= VT_LPWSTR;
 PropVariant[2].pwszVal:=PWideChar(Subject);
 PropVariant[3].vt:= VT_LPWSTR;
 PropVariant[3].pwszVal:=PWideChar(Keywords);
 PropVariant[4].vt:= VT_LPWSTR;
 PropVariant[4].pwszVal:=PWideChar(Comments);
 PropVariant[5].vt:= VT_LPWSTR;
 PropVariant[5].pwszVal:=PWideChar(Comments);
 OleCheck(PropStg.WriteMultiple(6, @PropSpec[0], @PropVariant[0], 2 ));
 PropStg.Commit(STGC_DEFAULT);
end;


end.

