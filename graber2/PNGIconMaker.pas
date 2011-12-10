unit PNGIconMaker;

interface

uses  SysUtils, Types, Windows, Graphics, PNGImage, common;

type

  TPNGIconMaker = class
    private
      FN: Byte;
      FIcon: TIcon;
      FBGSTR,FNUMSTR: String;
    public
      constructor Create(const BGSTR,NUMSTR: String);
      destructor Destroy; override;
      function MakeIcon(n: byte): TIcon;
      property N: Byte read FN;
      property Icon: TIcon read FIcon;
      property BGSTR: String read FBGSTR write FBGSTR;
      property NUMSTR: String read FNUMSTR write FNUMSTR;
  end;



implementation

constructor TPNGIconMaker.Create(const BGSTR,NUMSTR: String);
begin
  inherited Create;
  FIcon := TIcon.Create;
  FBGSTR := BGSTR;
  FNUMSTR := NUMSTR;
//  FIcon.Handle := LoadIcon(hInstance,PWideChar('ZICON'));
  FIcon.Width := 16;
  FIcon.Height := 16;
  FN := 1;
//  MakeIcon(0);
end;

destructor TPNGIconMaker.Destroy;
begin
  FreeAndNil(FIcon);
  inherited Destroy;
end;

function TPNGIconMaker.MakeIcon(n: byte): TIcon;
var
  BG,NUM: TPNGIMAGE;

begin

  Result := FIcon;

  if n > 99 then
    n := 99;

  if FN = N then
    Exit;

  BG := TPNGIMAGE.Create;
  NUM := TPNGIMAGE.Create;

  BG.LoadFromResourceName(hInstance,FBGSTR);

  NUM.LoadFromResourceName(hInstance,FNUMSTR+IntToStr((N div 10)));
  NUM.Draw(BG.Canvas,Rect(3,4,NUM.Width+3,NUM.Height+4));

  NUM.LoadFromResourceName(hInstance,FNUMSTR+IntToStr((N mod 10)));
  NUM.Draw(BG.Canvas,Rect(8,4,NUM.Width+8,NUM.Height+4));

  if not FIcon.HandleAllocated then
    DestroyIcon(FIcon.Handle);

  FIcon.Handle := PngToIcon(BG);
  FN := N;

  FreeAndNil(BG);
  FreeAndNil(NUM);
end;

end.
