unit SelectFieldsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxListBox, Vcl.Menus,
  Vcl.StdCtrls, cxButtons, Math;

type
  TfmSelectFields = class(TForm)
    lbFieldList: TcxListBox;
    lbFullList: TcxListBox;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    cxButton3: TcxButton;
    cxButton4: TcxButton;
    cxButton5: TcxButton;
    cxButton6: TcxButton;
    cxButton7: TcxButton;
    cxButton8: TcxButton;
    procedure cxButton1Click(Sender: TObject);
    procedure cxButton4Click(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    procedure cxButton3Click(Sender: TObject);
    procedure cxButton7Click(Sender: TObject);
    procedure cxButton8Click(Sender: TObject);
    procedure lbFullListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbFullListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbFullListStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetLang;
    function Execute: Boolean;
    function FieldsAsStr: String;
    procedure Exclude;
    { Public declarations }
  end;

var
  fmSelectFields: TfmSelectFields;

implementation

{$R *.dfm}

uses LangString;

procedure TfmSelectFields.cxButton1Click(Sender: TObject);
begin
  lbFieldList.Items.AddStrings(lbFullList.Items);
  lbFullList.Clear;
end;

procedure TfmSelectFields.cxButton2Click(Sender: TObject);
var
  i: Integer;
begin

  lbFieldList.Items.BeginUpdate;
  try

    for i := 0 to lbFullList.Count - 1 do
      if lbFullList.Selected[i] then
        lbFieldList.Items.Append(lbFullList.Items[i]);

  finally
    lbFieldList.Items.EndUpdate;
  end;

  lbFullList.DeleteSelected;
end;

procedure TfmSelectFields.cxButton3Click(Sender: TObject);
var
  i: Integer;
begin
  lbFullList.Items.BeginUpdate;
  try

    for i := 0 to lbFieldList.Count - 1 do
      if lbFieldList.Selected[i] then
        lbFullList.Items.Append(lbFieldList.Items[i]);

  finally
    lbFullList.Items.EndUpdate;
  end;

  lbFieldList.DeleteSelected;
end;

procedure TfmSelectFields.cxButton4Click(Sender: TObject);
begin
  lbFullList.Items.AddStrings(lbFieldList.Items);
  lbFieldList.Clear;
end;

procedure TfmSelectFields.cxButton7Click(Sender: TObject);
var
  i, j: Integer;
begin
  if lbFieldList.SelCount = 0 then
    Exit;

  lbFieldList.Items.BeginUpdate;
  try
    j := 0;
    for i := 0 to lbFieldList.Count - 1 do
      if lbFieldList.Selected[i] then
      begin
        if (i > j) then
        begin
          lbFieldList.Items.Move(i, i - 1);
          lbFieldList.Selected[i - 1] := true;
        end;
        inc(j);
      end;

  finally
    lbFieldList.Items.EndUpdate;
  end;
end;

procedure TfmSelectFields.cxButton8Click(Sender: TObject);
var
  i, j: Integer;
begin
  if lbFieldList.SelCount = 0 then
    Exit;

  lbFieldList.Items.BeginUpdate;
  try
    j := lbFieldList.Count - 1;
    for i := lbFieldList.Count - 1 downto 0 do
      if lbFieldList.Selected[i] then
      begin
        if (i < j) then
        begin
          lbFieldList.Items.Move(i, i + 1);
          lbFieldList.Selected[i + 1] := true;
        end;
        dec(j);
      end;

  finally
    lbFieldList.Items.EndUpdate;
  end;
end;

procedure TfmSelectFields.Exclude;
var
  i, j: Integer;
begin
  lbFullList.Items.BeginUpdate;
  try
    for i := 0 to lbFieldList.Count - 1 do
    begin
      j := lbFullList.Items.IndexOf(lbFieldList.Items[i]);
      if j <> -1 then
        lbFullList.Items.Delete(j);
    end;
  finally
    lbFullList.Items.EndUpdate;
  end;
end;

function TfmSelectFields.Execute: Boolean;
begin
  Exclude;
  ShowModal;
  Result := (ModalResult = mrOk) and (lbFieldList.Count > 0);
end;

function TfmSelectFields.FieldsAsStr: String;
var
  i: Integer;
begin
  if lbFieldList.Count = 0 then
    Exit;

  Result := lbFieldList.Items[0];
  for i := 1 to lbFieldList.Count - 1 do
    Result := Result + ',' + lbFieldList.Items[i];

end;

procedure TfmSelectFields.FormCreate(Sender: TObject);
begin
  SetLang;
end;

procedure TfmSelectFields.lbFullListDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  row, i, c: Integer;
  snd, src: TcxListBox;
begin
  snd := Sender as TcxListBox;
  src := (Source as tDragControlObject).Control as TcxListBox;
  c := 0;

  snd.Items.BeginUpdate;
  try

    if snd = src then
    begin
      row := snd.ItemAtPos(Point(X, Y), true);
      if row = -1 then
        row := src.Count - 1;
      i := 0;
      while i < src.Count do
        if src.Selected[i] and
          ((row < src.Count - 1) and ((i < row) or (i > row + c)) or
          (row = src.Count - 1) and (i < row + 1 - c)) then
        begin
          src.Items.Move(i, Min(row + c, src.Count - 1));
          src.Selected[Min(row + c, src.Count - 1)] := true;
          inc(c);
        end
        else
          inc(i);
    end
    else
    begin
      row := snd.ItemAtPos(Point(X, Y), false);
      for i := 0 to src.Count - 1 do
      begin
        if src.Selected[i] then
        begin
          snd.Items.Insert(row + c, src.Items[i]);
          snd.Selected[row + c] := true;
          inc(c);
        end;
      end;

      src.InnerListBox.DeleteSelected;
    end;

  finally
    snd.Items.EndUpdate;
  end;
end;

procedure TfmSelectFields.lbFullListDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Sender is TcxListBox) and (Source is tDragControlObject) and
    ((Source as tDragControlObject).Control is TcxListBox) and
    ((Sender <> (Source as tDragControlObject).Control) or
    (Sender <> lbFullList));
end;

procedure TfmSelectFields.lbFullListStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  DragObject := tDragControlObject.Create(Sender as tControl);
end;

procedure TfmSelectFields.SetLang;
begin
  Caption := lang('_SELECTFIELDS_');
  cxButton5.Caption := lang('_OK_');
  cxButton6.Caption := lang('_CANCEL_');
end;

end.
