unit NewDoublesRuleForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Menus,
  dxSkinsCore, dxSkinsDefaultPainters, StdCtrls, cxButtons, ExtCtrls,
  cxControls, cxContainer, cxEdit, cxTextEdit, cxLabel, cxStyles,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxClasses,
  cxGridCustomView, cxGrid, dxSkinsdxBarPainter, dxBar, cxEditRepositoryItems;

type

  TCheckNameFunction=function(rulename:string):boolean of object;

  TfmDoublesNewRule = class(TForm)
    Panel1: TPanel;
    bOk: TcxButton;
    bCancel: TcxButton;
    lRuleName: TcxLabel;
    eName: TcxTextEdit;
    gValues: TcxGrid;
    tvValues: TcxGridTableView;
    cChWhat: TcxGridColumn;
    cChWith: TcxGridColumn;
    gValuesLevel1: TcxGridLevel;
    BarManager: TdxBarManager;
    DoublesActions: TdxBar;
    bbNewRule: TdxBarButton;
    bbEditRule: TdxBarButton;
    bbDeleteRule: TdxBarButton;
    bcValues: TdxBarDockControl;
    cxEditRepository1: TcxEditRepository;
    cComboBox: TcxEditRepositoryComboBoxItem;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bbNewRuleClick(Sender: TObject);
    procedure bbDeleteRuleClick(Sender: TObject);
    procedure tvValuesEditValueChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
  private
    FRuleName: string;
    FResultString: String;
    FCheckName: TCheckNameFunction;
    //fpicfields: tstringlist;
    { Private declarations }
  public
    procedure SetLang;
    procedure PostValues;
    property RuleName: String read FRuleName;
    property ValueString: String read FResultString;
    property OnCheckName: TCheckNameFunction read FCheckname write FCheckName;
    function Execute(rulename:string;valuestring: string;
      picfields: tstringlist; chName: TChecknameFunction = nil): boolean;
    { Public declarations }
  end;

var
  fmDoublesNewRule: TfmDoublesNewRule;

implementation

uses common, LangString;

{$R *.dfm}

procedure TfmDoublesNewRule.bbDeleteRuleClick(Sender: TObject);
begin
  tvValues.DataController.DeleteFocused;
end;

procedure TfmDoublesNewRule.bbNewRuleClick(Sender: TObject);
begin
  tvValues.DataController.Append;
  gValues.SetFocus;
end;

function TfmDoublesNewRule.Execute(rulename:string;valuestring: string;
  picfields: tstringlist; chName: TChecknameFunction): boolean;
var
  s,h,v: string;
  i: integer;
begin
  SetLang;
  FRuleName := rulename;
  FResultString := valuestring;
  FCheckName := chName;
  cComboBox.Properties.Items.Assign(picfields);
  cComboBox.Properties.Sorted := true;
  //fpicfields := picfields;
  eName.Text := rulename;
  i := 0;
  tvValues.BeginUpdate;
  tvValues.DataController.RecordCount := 0;
  while valuestring <> '' do
  begin
    s := CopyTo(valuestring,';',['""'],[],true);
    h := CopyTo(s,'=',['""'],[],true);
    if s <> '' then
    begin
      tvValues.DataController.RecordCount := tvValues.DataController.RecordCount + 1;
      v := CopyTo(s,',',['""'],[],true);
      tvValues.DataController.Values[i,cChWhat.Index] := h;
      tvValues.DataController.Values[i,cChWith.Index] := v;
      inc(i);
      while s <> '' do
      begin
        v := CopyTo(s,',',['""'],[],true);
        tvValues.DataController.RecordCount := tvValues.DataController.RecordCount + 1;
        //tvValues.DataController.Values[i,cChWhat.Index] := CopyTo(s,'=',['""'],true);
        tvValues.DataController.Values[i,cChWith.Index] := v;
        inc(i);
      end;
    end;
  end;
  tvValues.EndUpdate;

  ShowModal;

  Result := ModalResult = mrOK;

  if Result then
  begin
    FRuleName := eName.Text;

    s := '';

    if tvValues.DataController.RecordCount > 0 then
    begin
      h := tvValues.DataController.Values[0,cChWhat.Index];
      v := tvValues.DataController.Values[0,cChWith.Index];

      for i := 1 to tvValues.DataController.RecordCount-1 do
        if VarToStr(tvValues.DataController.Values[i,cChWith.Index]) <> '' then
          if VarToStr(tvValues.DataController.Values[i,cChWhat.Index]) = '' then
            v := v + ',' + tvValues.DataController.Values[i,cChWith.Index]
          else
          begin
            s := s + h + '=' + v + ';';
            h := tvValues.DataController.Values[i,cChWhat.Index];
            v := tvValues.DataController.Values[i,cChWith.Index];
          end;
      s := s + h + '=' + v + ';';
    end;

    FResultString := s;
  end;
end;

procedure TfmDoublesNewRule.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  i: integer;
begin
  if (ModalResult=mrOk) then
  begin
    if(tvValues.DataController.RecordCount = 0) then
    begin
      CanClose := false;
      MessageDlg(lang('_NO_VALUES_'),mtError,[mbOk],0);
      Exit;
    end;

    for i := 0 to tvValues.DataController.RecordCount-1 do
      if trim(VarToStr(tvValues.DataController.Values[i,cChWith.index])) = '' then
      begin
        CanClose := false;
        MessageDlg(lang('_EMPTY_VALUES_'),mtError,[mbOk],0);
        Exit;
      end;

    if(trim(eName.Text) = '') then
    begin
      CanClose := false;
      MessageDlg(lang('_NO_NAME_'),mtError,[mbOk],0);
      eName.SetFocus;
      Exit;
    end;

    if Assigned(FCheckName)and FCheckName(trim(eName.Text)) then
    begin
      CanClose := false;
      MessageDlg(lang('_NAME_EXISTS_'),mtError,[mbOk],0);
      eName.SetFocus;
      Exit;
    end;
  end;
end;

procedure TfmDoublesNewRule.PostValues;
begin
  eName.PostEditValue;
  tvValues.DataController.Post(true);
end;

procedure TfmDoublesNewRule.SetLang;
begin
  Caption := lang('_RULEEDITING_');
  bOk.Caption := lang('_OK_');
  bCancel.Caption := lang('_CANCEL_');
  lRuleName.Caption := lang('_RULENAME_');
  bbNewRule.Caption := lang('_ADDRULE_');
  bbDeleteRule.Caption := lang('_DELETERULE_');
  cChWhat.Caption := lang('_FIELD_');
  cChWith.Caption := lang('_COMPARESTRING_');
end;

procedure TfmDoublesNewRule.tvValuesEditValueChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  if AItem = cChWhat then
    Sender.DataController.Values[Sender.DataController.FocusedRecordIndex,cChWith.Index]
      := Sender.DataController.Values[Sender.DataController.FocusedRecordIndex,AItem.Index];
end;

end.
