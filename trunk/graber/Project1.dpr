program Project1;
{$R *.dres}

uses
  Windows,
  Forms,
  SysUtils,
  Dialogs,
  Unit1 in 'Unit1.pas' {MainForm},
  rpVersionInfo in 'rpVersionInfo.pas',
  Unit3 in 'Unit3.pas' {fPreview},
  MyXMLParser in 'MyXMLParser.pas',
  Unit_Win7Taskbar in 'Unit_Win7Taskbar.pas',
  common in 'common.pas',
  hacks in 'hacks.pas',
  DownloadThreads in 'DownloadThreads.pas',
  stoping_u in 'stoping_u.pas' {fStoping},
  Unit5 in 'Unit5.pas' {fmLogin},
  AboutForm in 'AboutForm.pas' {fmAbout},
  md5 in 'md5.pas';

{$R *.res}

var
  hFileMapObj: THandle;
  P: PChar;
  NN: LongWord;
  s, t, r: string;
  gt, dw: boolean;

begin
  try
    hFileMapObj := OpenFileMapping(PAGE_READONLY, false, UNIQUE_ID);
    if hFileMapObj <> 0 then
    begin
      P := MapViewOfFile(hFileMapObj, FILE_MAP_WRITE, 0, 0, 0);
      NN := ReadLWFromPChar(P);
      UnmapViewOfFile(P);
      SendMessage(NN, MSG_FORCERESTORE, 0, 0);
      Exit;
    end;

    Application.Initialize;
    Application.Title := 'imagegraber';
    Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TfPreview, fPreview);
  Application.CreateForm(TfStoping, fStoping);
  Application.CreateForm(TfmLogin, fmLogin);
  Application.CreateForm(TfmAbout, fmAbout);
  if ParamCount > 0 then
      begin
        gt := false;
        dw := false;
        MainForm.chbByAuthor.Checked := false;
        s := trim(trim(DeleteFromTo(CmdLine, '"', '"')));
        t := GetNextS(s, ' ', '"');
        while (t <> '') or (s <> '') do
        begin
          r := lowercase(GetNextS(t, '='));
          t := trim(t, '"');
          if r = 'resid' then
            MainForm.cbSite.ItemIndex := REV_RVLIST[StrToInt(t)]
          else if r = 'resname' then
            MainForm.cbSite.ItemIndex := MainForm.cbSite.Items.IndexOf(t)
          else if r = 'tag' then
          begin
            MainForm.eTag.Text := ClearHTML(t);
            gt := true;
            dw := true;
          end
          else if r = 'uid' then
          begin
            MainForm.euserid.Value := StrToInt(t);
            MainForm.chbByAuthor.Checked := true;
          end
          else if r = 'list' then
          begin
            MainForm.LoadFromFile(t);
            gt := false;
            dw := false;
          end
          else if (r = 'get') and (curdest > -1) then
            gt := true
          else if (r = 'download') and (curdest > -1) then
            dw := true
          else if (r = 'save') then
          begin
            MainForm.AutoSave := true;
            if curdest = -1 then
              MainForm.sdList.InitialDir := ExcludeTrailingPathDelimiter(MainForm.edir.Text);
            if t <> '' then
            begin
              replace(replace(t,
              '?t',MainForm.eTag.Text,false,true),
              '?d',ExcludeTrailingPathDelimiter(MainForm.edir.Text),false,true);
              MainForm.sdList.FileName := t;
            end;
          end
          else if r = 'login' then
            MainForm.authdata[MainForm.cbSite.ItemIndex].Login := t
          else if r = 'password' then
            MainForm.authdata[MainForm.cbSite.ItemIndex].Password := t
          else if r = 'path' then
            MainForm.edir.Text := t
          else if r = 'close' then
            MainForm.CloseAfterFinish := true
          else if (s = '') and FileExists(t) then
            MainForm.LoadFromFile(t);

          t := GetNextS(s, ' ', '"');
        end;

        if gt then
        begin
          MainForm.AutoMode := true;
          MainForm.Show;
          MainForm.btnListGetClick(nil);
          if (curdest in [RP_EXHENTAI, RP_EHENTAI_G]) or
            (curdest in RS_POOLS - [RP_SANKAKU_IDOL, RP_SANKAKU_CHAN])
            and MainForm.chbInPools.Checked then MainForm.btnListGetClick(nil);
          MainForm.AutoMode := false;
          if (not dw or (MainForm.RowCount = 0)) and MainForm.CloseAfterFinish then
            MainForm.Close;
        end;
        if dw then
        begin
          MainForm.AutoMode := true;
          MainForm.tsDownloading.Show;
          MainForm.btnGrabClick(nil);
        end;

        // Form1.AutoMode := false;
      end;
      Application.Run;
    except
    end;

end.
