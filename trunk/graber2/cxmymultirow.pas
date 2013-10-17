unit cxmymultirow;

interface

uses Classes, Types, cxVGrid, cxVGridViewInfo, cxVGridUtils;

type

  TcxMyMultiEditorRow = class;

  tcxMyMultiEditorRowHeaderInfo = class(tcxMultiEditorRowHeaderInfo)
  private
    function GetRow: TcxMyMultiEditorRow;
  protected
    procedure CalcRowCaptionsInfo; override;
    property Row: TcxMyMultiEditorRow read GetRow;
  end;

  TcxMyMultiEditorRow = class(TcxMultiEditorRow)
  private
    FFirstEditorHeader: boolean; // AR
  public
    function CreateHeaderInfo: TcxCustomRowHeaderInfo; override;
  published
    property FirstEditorHeader: boolean read FFirstEditorHeader
      write FFirstEditorHeader default False; // AR
    procedure Assign(Source: TPersistent); override; // AR
  end;

implementation

procedure TcxMyMultiEditorRow.Assign(Source: TPersistent);
begin
  if Source is TcxMyMultiEditorRow then
    Self.FirstEditorHeader := TcxMyMultiEditorRow(Source).FirstEditorHeader;
  inherited Assign(Source);
end;

function TcxMyMultiEditorRow.CreateHeaderInfo: TcxCustomRowHeaderInfo;
begin
  Result := tcxMyMultiEditorRowHeaderInfo.Create(Self);
end;

function tcxMyMultiEditorRowHeaderInfo.GetRow: TcxMyMultiEditorRow;
begin
  Result := TcxMyMultiEditorRow(inherited Row);
end;

procedure tcxMyMultiEditorRowHeaderInfo.CalcRowCaptionsInfo;
var
  I: Integer;
  R: TRect;
  ARects: TcxRectList;
  ACaptionInfo: TcxRowCaptionInfo;
begin
  CalcSeparatorWidth(ViewInfo.DividerWidth);
  CalcSeparatorStyle;
  ARects := TcxMultiEditorRowViewInfo.GetCellRects(Row, HeaderCellsRect,
    SeparatorInfo.Width);
  if ARects <> nil then
    try
      // AR begin
      if Row.FirstEditorHeader and (ARects.Count > 1) then
      begin
        ACaptionInfo := CalcCaptionInfo(Row.Properties.Editors[0],
          HeaderCellsRect);
        CaptionsInfo.Add(ACaptionInfo);
      end
      else
      begin
        for I := 0 to ARects.Count - 1 do
        begin
          R := ARects[I];
          if R.Left < HeaderCellsRect.Right then
          begin
            ACaptionInfo := CalcCaptionInfo(Row.Properties.Editors[I], R);
            ACaptionInfo.RowCellIndex := I;
            CaptionsInfo.Add(ACaptionInfo);
          end;
        end;
        CalcSeparatorRects(ARects);
      end;
      // AR end
    finally
      ARects.Free;
    end;
end;

end.
