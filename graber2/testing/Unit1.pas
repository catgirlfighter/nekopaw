unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button3: TButton;
    Button2: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure oneal(sender: tobject);
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses GraberU, MyHTTP, MyXMLParser;

{$R *.dfm}

var
  fl,ResList: TResourceList;
  FCookie: TMyCookieList;
  fn: integer;

procedure TForm1.Button1Click(Sender: TObject);

begin
  if not reslist.ListFinished then
  begin
    ShowMessage('still working');
    Exit;
  end;


  memo1.Clear;
  fl.Clear;
  reslist.Clear;
  FCookie.Clear;

    fl.LoadList('d:\wg\nekopaw\compiled\resources');
    Memo1.Lines.Add('loaded ' + IntToStr(fl.Count) + ' items');
    fl.Items[0].NameFormat := '$rootdir$\$fname$';
    fl.Items[0].Fields['tag'] := 'taokaka';
{
  if GlobalSettings.Downl.UsePerRes then
    ResList.MaxThreadCount := GlobalSettings.Downl.PerResThreads
  else
    ResList.MaxThreadCount := 0;

  ResList.ThreadHandler.Proxy := Globalsettings.Proxy;
  ResList.ThreadHandler.ThreadCount := GlobalSettings.Downl.ThreadCount;
  ResList.ThreadHandler.Retries := GlobalSettings.Downl.Retries;

  ResList.DWNLDHandler.Proxy := Globalsettings.Proxy;
  ResList.DWNLDHandler.ThreadCount := GlobalSettings.Downl.PicThreads;
  ResList.DWNLDHandler.Retries := GlobalSettings.Downl.Retries;
  ResList.PictureList.IgnoreList := CopyDSArray(IgnoreList);

  bbDALF.Down := GlobalSettings.Downl.SDALF;
  bbAutoUnch.Down := GlobalSettings.Downl.AutoUncheckInvisible;
}

    reslist.CopyResource(fl.ItemByName('gelbooru.com'));

    reslist.CopyResource(fl.ItemByName('safebooru.org'));
    reslist.CopyResource(fl.ItemByName('tbib.org'));

    //reslist.CopyResource(fl.ItemByName('gelbooru.com'));
    Memo1.Lines.Add('3 items copied to working list');

    reslist.ThreadHandler.ThreadCount := 8;
    reslist.MaxThreadCount := 4;
    reslist.ThreadHandler.Cookies := FCookie;
    reslist.PictureList.OnEndAddList := oneal;
end;


procedure TForm1.Button2Click(Sender: TObject);
//var
//  res: tresource;
begin
  //if not reslist.ListFinished then
  //begin
  //  ShowMessage('still working');
  //  Exit;
  //end;

  //res := reslist.ItemByName('donmai.us');
  //res.Fields['login'] := 'avil';
  //res.Fields['password'] := '1ashnazg';
  //res.Relogin := true;
  //reslist.StartJob(JOB_LOGIN);
  //memo1.Lines.Add('loging in');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if not reslist.ListFinished then
  begin
    reslist.StartJob(JOB_STOPLIST);
    ShowMessage('still working');
    Exit;
  end;

    fn := 0;
    reslist.StartJob(JOB_LIST);
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  st: tstringlist;
  s: string;
  xml: tmyxmlparser;
begin
  st := tstringlist.Create;
  try
    st.LoadFromFile(ExtractFilePath(paramstr(0))+'xmltest.src');
    xml := tmyxmlparser.Create;
    try
      xml.Parse(st,true);
      memo1.Text := xml.TagList.Text;
    finally
      xml.Free;
    end;
  finally
    st.Free;
  end;
end;

procedure TForm1.oneal(sender: tobject);
var
  i: integer;
begin
  if reslist.PictureList.Count <> fn then
  begin
    for i := fn to reslist.PictureList.Count-1 do
      memo1.Lines.Add(reslist.PictureList.Items[i].PicName);
    fn := reslist.PictureList.Count;
  end;

end;

initialization

  FCookie := TMyCookieList.Create;
  ResList := TResourceList.Create;
  fl := TResourceList.Create;

finalization

  ResList.Free;
  fl.Free;
  FCookie.Free;

end.
