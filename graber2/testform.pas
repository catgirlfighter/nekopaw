unit testform;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, Vcl.StdCtrls;

type
  Tftestform = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    IdHTTP1: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ftestform: Tftestform;

implementation

{$R *.dfm}


procedure Tftestform.Button1Click(Sender: TObject);
begin
        //FHTTP := CreateHTTP;
        //FSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FHTTP);
        // fSSLHandler.Owner := fHTTP;
        //FHTTP.IOHandler := IdSSLIOHandlerSocketOpenSSL1;
        idHTTP1.Get(edit1.Text);
        //fSocksInfo := tidSocksInfo.Create(FSSLHandler);
        // fSocksInfo.Owner := fSSLHandler;
        //FSSLHandler.TransparentProxy := fSocksInfo;
end;

end.
