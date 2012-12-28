unit cxmycombobox;

interface

uses Windows, Classes, SysUtils, StrUtils,

cxVariants, dxMessages, cxFilterControlUtils, cxContainer, cxEdit, cxTextEdit,
cxControls, cxDropDownEdit, cxEditRepositoryItems;

type
  tcxMyComboBox = class;

   TOnBeforeGetItems = procedure(Sender: TObject; SearchWord: string;
    Items: TStrings) of object;

  TcxMyComboBoxProperties = class(cxDropDownEdit.TcxComboBoxProperties)
  private
    FWordMode: Boolean;
    fSpacer,fSeparator,fIsolator:String;
    fOnBeforeGetItems: TOnBeforeGetItems;
  public
    constructor Create(AOwner: TPersistent); override;
    procedure Assign(Source: TPersistent); override;
    class function GetContainerClass: TcxContainerClass; override;
    property WordMode: Boolean read FWordMode write FWordMode default false;
    property Spacer: String read fSpacer write fSpacer;
    property Separator: String read fSeparator write fSeparator;
    property Isolator: String read fIsolator write fIsolator;
    property OnBeforeGetItems: TOnBeforeGetItems read fOnBeforeGetItems write fOnBeforeGetItems;
  end;

  TcxMyEditRepositoryComboBoxItem = class(cxEditRepositoryItems.TcxEditRepositoryComboBoxItem)
  private
    function GetProperties: TcxMyComboBoxProperties;
    procedure SetProperties(Value: TcxMyComboBoxProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxMyComboBoxProperties read GetProperties write SetProperties;
  end;

  TcxCustomTextEditProperties = class(cxTextEdit.TcxCustomTextEditProperties);

  tcxMyComboBox = class(cxDropDownEdit.TcxComboBox)
  private
    function GetActiveProperties: TcxMyComboBoxProperties;
    function GetProperties: TcxMyComboBoxProperties;
    procedure SetProperties(Value: TcxMyComboBoxProperties);
  protected
    function GetWord(s: string; var sstart: integer;
      slen: integer; full: boolean = false): string;
    function ChangeWord(wrd: string): integer;
    procedure HandleSelectItem(Sender: TObject); override;
    procedure DoEditKeyPress(var Key: Char); override;
    procedure MaskEditPressKey(var Key: Char);
    procedure TextEditPressKey(var Key: Char);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxMyComboBoxProperties read GetActiveProperties;
    property Properties: TcxMyComboBoxProperties read GetProperties
      write SetProperties;
  end;

  TcxMyFilterComboBoxHelper = class(TcxFilterDropDownEditHelper)
  public
    class function GetFilterEditClass: TcxCustomEditClass; override;
    class procedure InitializeProperties(AProperties,
      AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean); override;
  end;

implementation

constructor TcxMyComboBoxProperties.Create(AOwner: TPersistent);
begin
  inherited;
  fSpacer := '_';
  fSeparator := ' ';
  fIsolator := '';
end;

procedure TcxMyComboBoxProperties.Assign(Source: TPersistent);
begin
  if Source is TcxMyComboBoxProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxMyComboBoxProperties do
      begin
        Self.WordMode := WordMode;
        Self.Spacer := Spacer;
        Self.Separator := Separator;
        Self.Isolator := Isolator;
        Self.OnBeforeGetItems := OnBeforeGetItems;
      //  Self.DropDownListStyle := DropDownListStyle;
      //  Self.DropDownRows := DropDownRows;
      //  Self.ItemHeight := ItemHeight;
      //  Self.Revertable := Revertable;
      //
      //  Self.OnDrawItem := OnDrawItem;
      //  Self.OnMeasureItem := OnMeasureItem;
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

class function TcxMyComboBoxProperties.GetContainerClass: TcxContainerClass;
begin
  result := tcxMyComboBox;
end;

function TcxMyEditRepositoryComboBoxItem.GetProperties: TcxMyComboBoxProperties;
begin
  Result := inherited Properties as TcxMyComboBoxProperties;
end;

procedure TcxMyEditRepositoryComboBoxItem.SetProperties(Value: TcxMyComboBoxProperties);
begin
  inherited Properties := Value;
end;

class function TcxMyEditRepositoryComboBoxItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxMyComboBoxProperties;
end;

class function TcxMyComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  result := tcxMyComboBoxProperties;
end;

function TcxMyComboBox.GetActiveProperties: TcxMyComboBoxProperties;
begin
  Result := TcxMyComboBoxProperties(InternalGetActiveProperties);
end;

function TcxMyComboBox.GetProperties: TcxMyComboBoxProperties;
begin
  Result := TcxMyComboBoxProperties(FProperties);
end;

procedure TcxMyComboBox.SetProperties(Value: TcxMyComboBoxProperties);
begin
  FProperties.Assign(Value);
end;

function tcxMyComboBox.GetWord(s: string; var sstart: integer;
  slen: integer; full: boolean = false): string;
var
  n,i,j,astart,aend,ssStart: integer;

begin
  if not properties.WordMode then
  begin
    result := s;
    Exit;
  end;

//  s := DisplayValue;

  if SelLength < 0 then
    n := sstart + slen + 1
  else
    n := sstart + 1;

  ssStart := 1;
  astart := 1;
  aend := 0;

  if Properties.Isolator <> '' then
  begin
    j := PosEx(Properties.Isolator,s);

    while j > 0 do
    begin
      if j < n then
        astart := j + 1;

      j := PosEx(Properties.Isolator,s,j + 1);

      if j = 0 then
      begin
        j := 1;
        Break;
      end else if j < n then
      begin
        ssStart := j + 1;
        j := PosEx(Properties.Isolator,s,j + 1);
      end else
      begin
        aend := j;
        Break;
      end;
    end;
  end else
    j := 0;

  if j = 0 then
  begin
    i := PosEx(properties.Separator,s,ssStart);
    if i > 0 then
      while i > 0 do
      begin
        if i < n then
          astart := i + 1
        else
        begin
          aend := i;
          Break;
        end;

        i := PosEx(properties.Separator,s,i + 1);
      end;
  end;

  if aend = 0 then
    if full then
      aend := length(s) + 1
    else
      aend := sstart + 1;
{  if aend > SelStart then
    aend := SelStart + SelLength;        }

  if (slen > 0) and (aend > sstart) then
    aend := sstart + 1;

  result := copy(s,astart,aend-astart);

  sStart := sStart - aStart + 1;
  //InternalEditValue := copy(s,1,astart) + wrd + copy(s,aend,length(Text)-aend+1);
  //result := astart + length(wrd);
end;

function tcxMyComboBox.ChangeWord(wrd: string): integer;
var
  s: string;
  n,i,j,astart,aend,sStart: integer;
begin
  wrd := Properties.Isolator + wrd + Properties.Isolator;

  s := DisplayValue;
  if SelLength < 0 then
    n := SelStart + SelLength + 1
  else
    n := SelStart + 1;

  sStart := 1;
  aStart := 0;
  aEnd := 0;

  if Properties.Isolator <> '' then
  begin
    j := PosEx(Properties.Isolator,s);

    while j > 0 do
    begin
      if j < n then
        astart := j - 1;

      j := PosEx(Properties.Isolator,s,j + 1);

      if j = 0 then
      begin
        j := 1;
        Break;
      end else if j < n then
      begin
        sStart := j + 1;
        j := PosEx(Properties.Isolator,s,j + 1);
      end else
      begin
        aend := j + 1;
        Break;
      end;
    end;
  end else
    j := 0;

  if j = 0 then
  begin
    i := PosEx(Properties.Separator,s,sStart);

    if i > 0 then
      while i > 0 do
      begin
        if i < n then
          astart := i
        else
        begin
          aend := i;
          Break;
        end;

        i := PosEx(Properties.Separator,s,i + 1);
      end;
  end;

  if aend = 0 then
    aend := length(DisplayValue) + 1;

{    if astart<>aend then
    result := trim(Copy(s,astart,aend-astart)) + ' '
  else
    result := '';  }

  DataBinding.DisplayValue := copy(s,1,astart) + wrd + copy(s,aend,length(s)-aend+1);
  result := astart + length(wrd);
end;

procedure tcxMyComboBox.HandleSelectItem(Sender: TObject); //override;

var
  ANewEditValue: TcxEditValue;
  AEditValueChanged: Boolean;
  n: integer;
begin
  if (Properties.DropDownListStyle <> lsEditList)
  or not properties.WordMode then
  begin
    inherited;
    Exit;
  end;


  ANewEditValue := LookupKeyToEditValue(ILookupData.CurrentKey);
  AEditValueChanged := not VarEqualsExact(EditValue, ANewEditValue);
  if AEditValueChanged and not DoEditing then
    Exit;
  SaveModified;
  LockLookupDataTextChanged;
  try
    n := ChangeWord(ANewEditValue);
  finally
    UnlockLookupDataTextChanged;
    RestoreModified;
  end;
  if AEditValueChanged then
    ModifiedAfterEnter := True;

  SelStart := n;

  ShortRefreshContainer(False);
end;

procedure tcxMyComboBox.TextEditPressKey(var Key: Char);

  function FillFromList(var AFindText: string): Boolean;
  var
    ATail: string;
    L: Integer;
    S: string;
  begin
    S := AFindText;
    if InnerTextEdit.ImeLastChar <> #0 then
      S := S + InnerTextEdit.ImeLastChar;

    if Assigned(Properties.OnBeforeGetItems) then
      Properties.OnBeforeGetItems(Self,S,Properties.Items);

{    if S = '' then
    begin
      Result := false;
      FindSelection := false;
      Exit;
    end;   }

    Result := ILookupData.Locate(S, ATail, False);
    if Result then
    begin
      AFindText := S;
      if InnerTextEdit.ImeLastChar <> #0 then
      begin
        L := Length(AFindText);
        Insert(Copy(AFindText, L, 1), ATail, 1);
        Delete(AFindText, L, 1);
      end;
    end;
    FindSelection := Result;
    if AFindText = '' then
    begin
      if (TcxCustomTextEditProperties(ActiveProperties).EditingStyle <> esFixedList)
      and not Properties.WordMode then
        InternalSetDisplayValue('');
      FindSelection := False;
    end;
    if Result then
    begin
      L := ChangeWord(AFindText + ATail);
      //DataBinding.DisplayValue := AFindText + ATail;
      SelStart := L - length(ATail) - length(Properties.fIsolator);//Length(AFindText);
      SelLength := Length(ATail) + length(Properties.fIsolator);
    end;
    UpdateDrawValue;
  end;

  function CanContinueIncrementalSearch: Boolean;
  begin
    Result := TcxCustomTextEditProperties(ActiveProperties).EditingStyle in [esEditList, esFixedList];
    if not Result then
      Result := (SelLength = 0) {and (SelStart = Length(DisplayValue))} or
        FindSelection or (SelLength > 0);
  end;

var
  AEditingStyle: TcxEditEditingStyle;
  AFindText: string;
  AFound: Boolean;
  APrevCurrentKey: TcxEditValue;
  APrevFindSelection: Boolean;
  sStart: integer;
begin
  AEditingStyle := TcxCustomTextEditProperties(ActiveProperties).EditingStyle;
  InnerTextEdit.InternalUpdating := True;
  ValidateKeyPress(Key);

  if (Key = #0) then
    exit;

  //else if (AEditingStyle <> esEditList)
  //and properties.WordMode and (Key = properties.Spacer) then
  //begin
  //  DroppedDown := false;
  //  Exit;
  //end;

  UnlockLookupDataTextChanged;
  KeyboardAction := True;
  if AEditingStyle = esFixedList then
    case Key of
      #8:
        if not TcxCustomTextEditProperties(ActiveProperties).FixedListSelection then
        begin
          Key := #0;
          FindSelection := False;
        end;
    end;

  APrevCurrentKey := ILookupData.CurrentKey;
  APrevFindSelection := FindSelection;
  AFound := False;
  LockClick(True);
  try
    if Key = #8 then
    begin
        if TcxCustomTextEditProperties(ActiveProperties).UseLookupData then
        begin
          if TcxCustomTextEditProperties(ActiveProperties).CanIncrementalSearch then
          begin
            if ((AEditingStyle = esEditList) or (AEditingStyle = esEdit) and Properties.WordMode)
            and (Length(DisplayValue) > 0) and not FindSelection then
            begin
              //SelLength := Length(DisplayValue) - SelStart;
              FindSelection := True;
            end;
            if FindSelection then
            begin
              sStart := SelStart;
              AFindText := GetWord(DisplayValue,sStart,SelLength);//Copy(DisplayValue, 1, Length(DisplayValue) - SelLength);
              SetLength(AFindText, Length(AFindText) - Length(AnsiLastChar(AFindText)));
              LockLookupDataTextChanged;
              AFound := FillFromList(AFindText);
            end;
            if AEditingStyle = esFixedList then
              Key := #0;
          end else
            if Assigned(Properties.OnBeforeGetItems) then
            begin
              AFindText := DisplayValue;
              sStart := SelStart;
              if SelLength > 0 then
              begin
                Delete(AFindText,SelStart+1,SelLength);
                Properties.OnBeforeGetItems(Self,GetWord(AFindText,sStart,0),Properties.Items);
              end else
              begin
                Delete(AFindText,SelStart,1);
                dec(sStart,1 + length(Properties.Isolator));
                Properties.OnBeforeGetItems(Self,GetWord(AFindText,sStart,0),Properties.Items);
              end;
            end;
        end;
    end
    else
      if IsTextChar(Key) then
      begin
        if TcxCustomTextEditProperties(ActiveProperties).UseLookupData then
        begin
          if TcxCustomTextEditProperties(ActiveProperties).CanIncrementalSearch and CanContinueIncrementalSearch then
          begin
            LockLookupDataTextChanged;
            AFound := False;
            AFindText := DisplayValue;
            sStart := SelStart;
            if SelLength > 0 then
              AFindText := GetWord(AFindText,sStart,SelLength){Copy(AFindText, 1, SelStart)} + Key
            else
              if AEditingStyle = esFixedList then
                if FindSelection then
                begin
                  AFindText := AFindText + Key;
                  AFound := FillFromList(AFindText);
                  if not AFound then
                    AFindText := Key;
                end
                else
                  AFindText := Key
              else
                Insert(Key, AFindText, SelStart + 1);
            if not AFound then
            begin
              inc(sStart);
              AFindText := GetWord(AFindText,sStart, 0);
              AFound := FillFromList(AFindText);
            end;
            if (AEditingStyle = esFixedList) and not TcxCustomTextEditProperties(ActiveProperties).FixedListSelection and not AFound then
            begin
              AFindText := Key;
              AFound := FillFromList(AFindText);
            end;
          end else
            if Assigned(Properties.OnBeforeGetItems) then
            begin
              sStart := SelStart;
              AFindText := GetWord(DisplayValue,sStart,SelLength);
              Insert(Key,AFindText,SelStart+1);
              Properties.OnBeforeGetItems(Self,AFindText,Properties.Items);
            end;
          if (AEditingStyle in [esEditList, esFixedList]) and not AFound then
          begin
            Key := #0;
            if (AEditingStyle = esEditList) and (DisplayValue <> '') or
                (AEditingStyle = esFixedList) and TcxCustomTextEditProperties(ActiveProperties).FixedListSelection and APrevFindSelection then
              FindSelection := True;
          end;
        end;
      end;
  finally
    LockClick(False);
    KeyboardAction := False;
    if TcxCustomTextEditProperties(ActiveProperties).UseLookupData and not VarEqualsExact(APrevCurrentKey,
      ILookupData.CurrentKey) then
        DoClick;
  end;
  if AFound then
    Key := #0;
  if Key <> #0 then
    InnerTextEdit.InternalUpdating := False;
end;

procedure tcxMyComboBox.MaskEditPressKey(var Key: Char);
begin
  if not ActiveProperties.IsMasked then
  begin
    TextEditPressKey(Key);
    Exit;
  end;

  if (Key = #9) or (Key = #27) then
    Key := #0
  else if not ValidateKeyPress(Key) then
    Key := #0
  else
  begin
    if Key <> #13 then
    begin
      if not ActiveProperties.IsMasked then
        TextEditPressKey(Key)
      else
      begin
        if (Key = #3) or (Key = #22) or (Key = #24) then // ^c ^v ^x
        begin
          TextEditPressKey(Key)
        end
        else
        begin
          if Key = #8 then  // Backspace
          begin
            if not Mode.PressBackSpace then
              Key := #0;
          end
          else
            if not Mode.PressSymbol(Key) then
              Key := #0;
        end;
      end;
    end;
  end;
end;

procedure tcxMyComboBox.DoEditKeyPress(var Key: Char);
var
  lastkey: char;
begin
  if (Properties.DropDownListStyle <> lsEditList)
  or not properties.WordMode then
  begin
    inherited;
    Exit;
  end;

  lastkey := key;

  if IsTextChar(Key) and ActiveProperties.ImmediateDropDownWhenKeyPressed and
    not HasPopupWindow then
  begin
    //DroppedDown := True;

    if TcxMyComboBoxProperties(ActiveProperties).PopupWindowCapturesFocus and (TranslateKey(Word(Key)) <> VK_RETURN) and
      CanDropDown and (GetPopupFocusedControl <> nil) then
    begin
      PostMessage(PopupWindow.Handle, DXM_POPUPCONTROLKEY, Integer(Key), 0);
      Key := #0;
    end;
  end;

  if Key <> #0 then
    MaskEditPressKey(Key);

 if (IsTextChar(lastkey) or properties.WordMode and (lastkey = #8))
 and ActiveProperties.ImmediateDropDownWhenKeyPressed
 and not HasPopupWindow then
  DroppedDown := true
 else
  if HasPopupWindow and (Properties.Items.Count = 0) then
    DroppedDown := false;

end;

class function TcxMyFilterComboBoxHelper.GetFilterEditClass: TcxCustomEditClass;
begin
  Result := TcxMyComboBox;
end;

class procedure TcxMyFilterComboBoxHelper.InitializeProperties(AProperties,
  AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean);
begin
  inherited InitializeProperties(AProperties, AEditProperties, AHasButtons);
  with TcxCustomComboBoxProperties(AProperties) do
  begin
    ButtonGlyph := nil;
    DropDownRows := 8;
    DropDownListStyle := lsEditList;
    ImmediateDropDownWhenKeyPressed := False;
    PopupAlignment := taLeftJustify;
    Revertable := False;
  end;
end;

initialization

  FilterEditsController.Register(TcxMyComboBoxProperties, TcxMyFilterComboBoxHelper);

finalization
  FilterEditsController.Unregister(TcxMyComboBoxProperties, TcxMyFilterComboBoxHelper);


end.
