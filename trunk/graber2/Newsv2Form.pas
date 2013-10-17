unit Newsv2Form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxCustomData, cxStyles, cxTL, cxTLdxBarBuiltInMenu, dxSkinsCore, Menus,
  StdCtrls, cxButtons, ExtCtrls, ComCtrls, cxInplaceContainer, cxTextEdit,
  cxContainer, cxEdit, cxMemo, cxRichEdit, cxRichEditUtils;

type
  TfmNewsv2 = class(TForm)
    tlList: TcxTreeList;
    Panel1: TPanel;
    bClose: TcxButton;
    tlListColumn1: TcxTreeListColumn;
    eText: TcxRichEdit;
    procedure bCloseClick(Sender: TObject);
    procedure tlListFocusedNodeChanged(Sender: TcxCustomTreeList;
      APrevFocusedNode, AFocusedNode: TcxTreeListNode);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure execute(fname: string);
    procedure CleanList;
    procedure SetRichText(caption: string; s: tstringlist);
    procedure SetLang;
    { Public declarations }
  end;

var
  fmNewsv2: TfmNewsv2;

procedure ShowNews(fname: string);

implementation

uses common, LangString;

{$R *.dfm}

procedure TfmNewsv2.CleanList;
var
  i: integer;
  s: tstringlist;
begin
  for i := 0 to tlList.Count - 1 do
  begin
    s := tlList.Items[i].Data;
    s.Free;
  end;
  tlList.Clear;
end;

procedure TfmNewsv2.bCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfmNewsv2.execute(fname: string);
var
  f: tstringlist;
  fValue: tstringlist;
  i: integer;
  node: TcxTreeListNode;
begin
  node := nil;
  fValue := nil;
  f := tstringlist.Create;
  try
    f.LoadFromFile(fname);
    for i := 0 to f.Count - 1 do
    begin
      if length(trim(f[i])) > 0 then
        if (trim(f[i])[1] = '=') then
        begin
          node := tlList.Add;
          node.Texts[0] := copyfromto(f[i], '=', '=');
          fValue := tstringlist.Create;
          node.Data := fValue;
        end
        else if assigned(node) then
          fValue.Add(f[i]);
    end;
  finally
    f.Free;
  end;

  if tlList.Count > 0 then
    tlList.Items[0].Focused := true;

  ShowModal;

  CleanList;

end;

procedure TfmNewsv2.FormCreate(Sender: TObject);
begin
  SetLang;
end;

procedure TfmNewsv2.SetLang;
begin
  caption := lang('_WHATSNEW_');
  bClose.caption := lang('_CLOSE_');
end;

procedure TfmNewsv2.SetRichText(caption: string; s: tstringlist);
var
  i: integer;
begin
  eText.Lines.BeginUpdate;
  try
    SendMessage(eText.Handle, WM_SETREDRAW, integer(FALSE), 0);
    eText.Clear;
    eText.SelAttributes2.Style := [fsBold];
    eText.Lines.Add(caption);
    eText.SelStart := length(caption) + 2;
    for i := 0 to s.Count - 1 do
    begin
      case s[i][1] of
        '-':
          begin
            eText.SelAttributes2.Style := [];
            eText.Paragraph2.NumberingType := pfnSymbols;
            eText.Lines.Add(trimex(s[i], [' ', '-']));
          end;
        '/':
          begin
            eText.SelAttributes2.Style := [];
            eText.Paragraph2.NumberingType := pfnNone;
            eText.Lines.Add(trimex(s[i], [' ', '/']));
          end;
      end;

    end;

    // eText.Lines.Delete(eText.Lines.Count -1);
    eText.SelAttributes2.Style := [];
    eText.Paragraph2.NumberingType := pfnNone;
    eText.SelStart := 0;

  finally
    SendMessage(eText.Handle, WM_SETREDRAW, integer(true), 0);
    eText.Lines.EndUpdate;
    eText.Repaint;
    // after enabling SETREDRAW object do not redrawing aotomatically
  end;
end;

procedure TfmNewsv2.tlListFocusedNodeChanged(Sender: TcxCustomTreeList;
  APrevFocusedNode, AFocusedNode: TcxTreeListNode);
var
  s: tstringlist;
begin
  if assigned(AFocusedNode) then
  begin
    s := AFocusedNode.Data;
    SetRichText(AFocusedNode.Texts[0], s);
  end;
end;

procedure ShowNews(fname: string);
begin
  Application.CreateForm(TfmNewsv2, fmNewsv2);
  try
    fmNewsv2.eText.Paragraph2.SpaceAfter := 4;
    fmNewsv2.execute(fname);
  finally
    fmNewsv2.Free;
  end;
end;

end.
