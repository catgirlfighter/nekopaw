unit Whatsnewform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Menus,
  cxControls, cxContainer, cxEdit, cxCheckBox, StdCtrls, cxButtons, cxTextEdit,
  cxMemo, INIFiles;

type
  TfWhatsNew = class(TForm)
    Panel1: TPanel;
    bClose: TcxButton;
    mText: TcxMemo;
  private
    { Private declarations }
  public
    procedure Execute;
    procedure SetLang;
    { Public declarations }
  end;

var
  fWhatsNew: TfWhatsNew;

implementation

uses LangString, OpBase;

{$R *.dfm}

procedure TfWhatsNew.Execute;
{var
  INI: TINIFile;   }
  //s: tstringlist;
begin
  if FileExists(rootdir + '\versionlog.txt') then
  begin
    //INI := TINIFile.Create(rootdir + '\versionlog.txt');
    //try
      //s := tstringlist.Create;
      //try
        //INI.ReadSections(s);
        //if s.Count > 0 then
      //  begin
          SetLang;
          //INI.ReadSectionValues(s[0],s);
          mText.Lines.LoadFromFile(rootdir + '\versionlog.txt');
          ShowModal;
      //  end;
      //finally
      //  s.Free;
      //end;
    //finally
    //  INI.Free;
    //end;
  end;
end;

procedure TfWhatsNew.SetLang;
begin
  Caption := lang('_WHATSNEW_');
  bClose.Caption := lang('_CLOSE_');
end;

end.
