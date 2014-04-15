unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, unit_win7taskbar, AppEvnts, MyHTTP,GraberU;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button3: TButton;
    Button2: TButton;
    Button4: TButton;
    ProgressBar1: TProgressBar;
    ApplicationEvents1: TApplicationEvents;
    OpenDialog1: TOpenDialog;
    Edit1: TEdit;
    Button5: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    Msg_TaskbarButtonCreated: Cardinal;
    { Private declarations }
    l1,l2: TResourceList;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
uses common, MyXMLParser;

procedure TForm1.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if Msg.message = Msg_TaskbarButtonCreated then
  begin
    if InitializeTaskBarAPI then
    begin
      Button4.Enabled := true;
      Button3.Enabled := true;
    end;
    Handled := true;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  f: tfilestream;
  ext: string;
  p: array of char;
begin
  setlength(p,1000);
  if OpenDialog1.Execute then
  begin
    f := tfilestream.Create(OpenDialog1.FileName,fmOpenRead);
    try
      f.Read(p[0],1000);
      ext := ImageFormat(@p[0]);
      memo1.Text := ext;
    finally
      f.Free;
    end;
  end;
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
  SetTaskbarProgressState(tbpsNormal);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin

//  progressbar1.Min := 0;
//  progressbar1.Max := 1000;
//  InitializeTaskBarAPI;

  SetTaskbarProgressValue(1,100)
{  progressbar1.Style := pbstMarquee;
  progressbar1.Position := 400;
  SetTaskbarProgressValue(400,1000);
  progressbar1.Position := 500;
  SetTaskbarProgressValue(500,1000);
  //  w7taskbar.SetProgress(50,100);  }
//  w7taskbar.State := tbpsNormal;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  fname: string;
  f: tfilestream;
  buff: array[0..21] of byte;
begin
  fname := ExtractFilePath(paramstr(0)) + 'file.bin';

  f := tfilestream.Create(fname,fmOpenRead);
  try
    f.Read(buff,22);
    memo1.Lines.Insert(0,ImageFormat(@buff[0]));
  finally
    f.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    l2 := nil;
    l1 := TResourcelist.Create;
    l1.LoadList(extractfilepath(paramstr(0)) + '..\..\..\..\compiled\resources');
    memo1.Lines.Add('Resource count: ' + IntToStr(l1.Count)) ;
      //Msg_TaskbarButtonCreated := RegisterWindowMessage('TaskbarButtonCreated');
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  l1.Free;
end;

end.
