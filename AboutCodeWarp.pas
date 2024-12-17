unit AboutCodeWarp;

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Controls;

type
  TAboutCodeWarpBox = class(TForm)
    Label2: TLabel;
    Bevel1: TBevel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    Button1: TButton;
    Button3: TButton;
    Bevel2: TBevel;
    Label5: TLabel;
    Panel1: TPanel;
    BBHelp: TBitBtn;
    LBCode: TListBox;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Label6: TLabel;
    Label7: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure BBHelpClick(Sender: TObject);
    procedure LBCodeDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  AboutCodeWarpBox: TAboutCodeWarpBox;
  vOptionsChanged : Boolean;

implementation

{$R *.DFM}

uses CodeWarpExpert, FCodeWarpOptions, FCodeWarp, Graphics;

procedure TAboutCodeWarpBox.FormShow(Sender: TObject);
begin
   vOptionsChanged:=False;
end;

procedure TAboutCodeWarpBox.Button1Click(Sender: TObject);
begin
   Close;
end;

procedure TAboutCodeWarpBox.Button3Click(Sender: TObject);
begin
   if Assigned(CodeWarpOptions) then CodeWarpOptions.ShowModal
   else begin
      CodeWarpOptions:=TCodeWarpOptions.Create(nil);
      CodeWarpOptions.ShowModal;
      CodeWarpOptions.Free; CodeWarpOptions:=nil;
   end;
end;

procedure TAboutCodeWarpBox.BBHelpClick(Sender: TObject);
begin
   Application.HelpContext(HelpContext);
end;

procedure TAboutCodeWarpBox.LBCodeDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
   t : String;
begin
   with Control as TListBox do begin
      t:=Items[Index];
      CodeWarpForm.ILStates.Draw(Canvas, Rect.Left, Rect.Top,
                                 StrToInt(Copy(t, 1, 2)));
      with Canvas do begin
         TextOut(Rect.Left+19, Rect.Top+1, Copy(t, 3, MaxInt));
         Pen.Color:=clBtnFace;
         MoveTo(Rect.Left, Rect.Top+16); LineTo(Rect.Right, Rect.Top+16);
      end;
   end;
end;

end.
