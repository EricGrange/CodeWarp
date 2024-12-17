unit FCodeWarpOptions;

interface

uses
  System.Classes,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Controls, Vcl.Menus;

type
  TCodeWarpOptions = class(TForm)
    Button1: TButton;
    PageControl: TPageControl;
    TSParser: TTabSheet;
    TSEntries: TTabSheet;
    TSUI: TTabSheet;
    CBIgnoreForwards: TCheckBox;
    CBIgnoreEZInheritance: TCheckBox;
    CBHideMethodKind: TCheckBox;
    CBHideClassParameters: TCheckBox;
    CBSortTheNode: TCheckBox;
    Label1: TLabel;
    RBWarpToCode: TRadioButton;
    RBExpand: TRadioButton;
    CBHeight: TCheckBox;
    TSVCLPath: TTabSheet;
    Label2: TLabel;
    RBNone: TRadioButton;
    RBDelphi11: TRadioButton;
    RBCustom: TRadioButton;
    EDPath: TEdit;
    Label4: TLabel;
    CBDefaultEntry: TComboBox;
    TabSheet2: TTabSheet;
    RBParseAlways: TRadioButton;
    RBParse8000: TRadioButton;
    RBParse4000: TRadioButton;
    RBParse2000: TRadioButton;
    RBCompareAlways: TRadioButton;
    Label3: TLabel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    CBShowMethodsUnder: TCheckBox;
    CBShowScope: TCheckBox;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    StaticText4: TStaticText;
    Label11: TLabel;
    StaticText5: TStaticText;
    CBIncludeRecordsInClassTree: TCheckBox;
    BBHelp: TBitBtn;
    CBRememberDrills: TCheckBox;
    TSLocalLibs: TTabSheet;
    EDNewEntry: TEdit;
    EDNewPath: TEdit;
    BUAdd: TButton;
    RBDelphi12: TRadioButton;
    StaticText6: TStaticText;
    LVLocalLibs: TListView;
    PMLocalLibs: TPopupMenu;
    MIEditName: TMenuItem;
    MIEditPath: TMenuItem;
    N1: TMenuItem;
    MIRemoveEntry: TMenuItem;
    N2: TMenuItem;
    MIMoveUp: TMenuItem;
    MIMoveDown: TMenuItem;
    EDShortCut: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    CBToolBar: TCheckBox;
    EDNewFilter: TEdit;
    MIEditFilter: TMenuItem;
    CBConsolidateMethodDeclarations: TCheckBox;
    CBWarpPreview: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure RBNoneClick(Sender: TObject);
    procedure RBDelphi11Click(Sender: TObject);
    procedure RBCustomClick(Sender: TObject);
    procedure EDPathChange(Sender: TObject);
    procedure RBParseAlwaysClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BBHelpClick(Sender: TObject);
    procedure BUAddClick(Sender: TObject);
    procedure LVLocalLibsDblClick(Sender: TObject);
    procedure LVLocalLibsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MIEditNameClick(Sender: TObject);
    procedure PMLocalLibsPopup(Sender: TObject);
    procedure MIRemoveEntryClick(Sender: TObject);
    procedure MIMoveUpClick(Sender: TObject);
    procedure MIMoveDownClick(Sender: TObject);
    procedure MIEditFilterClick(Sender: TObject);
  private
    { Déclarations privées }
    oldHintHidePause : Integer;
    procedure LLStringToLV;
    procedure LVToLLString;
  public
    { Déclarations publiques }
  end;

var
  CodeWarpOptions: TCodeWarpOptions;
  vclPath, localLibPath : String;
  compareOption : Integer;

const

   cwrkKey = 'Software\CodeWarp';
   cwrkEDShortCut = 'EDShortCut';

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses  Windows, Graphics, Dialogs, Registry, AboutCodeWarp, SysUtils,
		CodeWarpExpert;

{$R *.DFM}

const
   rkCBIgnoreForwards = 'CBIgnoreForwards';
   rkCBIgnoreEZInheritance = 'CBIgnoreEZInheritance';
   rkCBSortTheNodes = 'CBSortTheNodes';
   rkCBSortFileNodes = 'CBSortFileNodes';
   rkRBWarpToCode = 'RBWarpToCode';
   rkCBHideMethodKind = 'CBHideMethodKind';
   rkCBHideClassParameters = 'CBHideClassParameters';
   rkCBHeight = 'CBHeight';
   rkCBIncludeRecordsInClassTree = 'CBIncludeRecordsInClassTree';
	rkCBShowScope = 'CBShowScope';
   rkCBShowMethodsUnder = 'CBShowMethodsUnder';
   rkCBConsolidateMethDecl = 'CBConsolidateMethDecl';
   rkVCLPath = 'VCLPath';
   rkLocalLibPath = 'LocalLibPath';
   rkCompareOption = 'CompareOption';
   rkCBDefaultEntry = 'CBDefaultEntry';
   rkCBFileParse = 'CBFileParse';
	rkCBRememberDrills = 'CBRememberDrills';
	rkCBToolBar = 'ToolBar';
	rkCBWarpPreview = 'WarpPreview';

	rkRootDir = 'RootDir';
	rkSource = '\Source';

procedure TCodeWarpOptions.LLStringToLV;
var
   i, p : Integer;
   sl : TStringList;
   buf : String;
begin
   sl:=TStringList.Create;
   sl.CommaText:=localLibPath;
   with LVLocalLibs.Items do begin
      BeginUpdate; Clear;
      for i:=0 to sl.Count-1 do with Add do begin
         p:=Pos('¤', sl[i]);
         if p>0 then begin
            Caption:=Copy(sl[i], 1, p-1);
            buf:=Copy(sl[i], p+1, MaxInt);
            p:=Pos('¤', buf);
            if p>0 then begin
               SubItems.Add(Copy(buf, 1, p-1));
               SubItems.Add(Copy(buf, p+1, MaxInt));
            end else begin
               SubItems.Add(buf);
               SubItems.Add('*.pas;*.inc;*.int');
            end;
         end else begin
            Caption:='LocalLibs';
            SubItems.Add(sl[i]);
            SubItems.Add('*.pas;*.inc;*.int');
         end;
      end;
      EndUpdate;
   end;
   sl.Free;
end;

procedure TCodeWarpOptions.LVToLLString;
var
   i : Integer;
   sl : TStringList;
begin
   sl:=TStringList.Create;
   with LVLocalLibs do for i:=0 to Items.Count-1 do with Items[i] do
      sl.Add(Caption+'¤'+SubItems[0]+'¤'+SubItems[1]);
   localLibPath:=sl.CommaText;
   sl.Free;
end;

procedure TCodeWarpOptions.FormCreate(Sender: TObject);
begin
	Application.HintHidePause:=10000;
	PageControl.ActivePage:=TSParser;

   var reg := TRegistry.Create;
   try
		reg.RootKey:=HKEY_LOCAL_MACHINE;
		if reg.OpenKey('Software\Embarcadero\BDS\22.0', False) then
			if reg.ValueExists(rkRootDir) then
				RBDelphi11.Caption := reg.ReadString(rkRootDir) + rkSource;
      reg.CloseKey;
		if reg.OpenKey('Software\Embarcadero\BDS\23.0', False) then
			if reg.ValueExists(rkRootDir) then
				RBDelphi12.Caption := reg.ReadString(rkRootDir) + rkSource;
		RBDelphi11.Enabled := DirectoryExists(RBDelphi11.Caption);
		RBDelphi12.Enabled := DirectoryExists(RBDelphi12.Caption);
		reg.CloseKey;
   finally
		reg.Free;
	end;
	// Registry Session : Software\CodeWarp
	with TRegistry.Create do begin
		if OpenKey(cwrkKey, True) then begin
			// Clef ouverte/créée correctement
   		if ValueExists(rkCBIgnoreForwards) then
	   		CBIgnoreForwards.Checked:=ReadBool(rkCBIgnoreForwards)
		   else CBIgnoreForwards.Checked:=False;
		   if ValueExists(rkCBIgnoreEZInheritance) then
	   		CBIgnoreEZInheritance.Checked:=ReadBool(rkCBIgnoreEZInheritance)
   		else CBIgnoreEZInheritance.Checked:=False;
		   if ValueExists(rkCBSortTheNodes) then
	   		CBSortTheNode.Checked:=ReadBool(rkCBSortTheNodes)
   		else CBSortTheNode.Checked:=False;
   		if ValueExists(rkRBWarpToCode) then
	   		RBWarpToCode.Checked:=ReadBool(rkRBWarpToCode)
		   else RBWarpToCode.Checked:=False;
         RBExpand.Checked:=not RBWarpToCode.Checked;
		   if ValueExists(rkCBHideMethodKind) then
	   		CBHideMethodKind.Checked:=ReadBool(rkCBHideMethodKind)
   		else CBHideMethodKind.Checked:=True;
		   if ValueExists(rkCBHideClassParameters) then
	   		CBHideClassParameters.Checked:=ReadBool(rkCBHideClassParameters)
   		else CBHideClassParameters.Checked:=False;
		   if ValueExists(rkCBHeight) then
	   		CBHeight.Checked:=ReadBool(rkCBHeight)
   		else CBHeight.Checked:=False;
         if ValueExists(rkCBIncludeRecordsInClassTree) then
            CBIncludeRecordsInClassTree.Checked:=ReadBool(rkCBIncludeRecordsInClassTree)
         else CBIncludeRecordsInClassTree.Checked:=False;
         if ValueExists(rkCBShowScope) then
            CBShowScope.Checked:=ReadBool(rkCBShowScope)
         else CBShowScope.Checked:=False;
         if ValueExists(rkCBShowMethodsUnder) then
            CBShowMethodsUnder.Checked:=ReadBool(rkCBShowMethodsUnder)
         else CBShowMethodsUnder.Checked:=True;
         if ValueExists(rkVCLPath) then
            vclPath := ReadString(rkVCLPath)
         else vclPath := RBDelphi12.Caption;
         EDPath.Enabled:=False; EDPath.Color:=clBtnFace; EDPath.Text:='';
         if vclPath='' then
            RBNone.Checked:=True
         else if lowercase(vclPath)=lowercase(RBDelphi11.Caption) then begin
            vclPath:=RBDelphi11.Caption;
            RBDelphi11.Checked:=True;
         end else if lowercase(vclPath)=lowercase(RBDelphi12.Caption) then begin
            vclPath:=RBDelphi12.Caption;
            RBDelphi12.Checked:=True;
			end else begin
            EDPath.Text:=vclPath;
            RBCustom.Checked:=True;
         end;
         if ValueExists(rkLocalLibPath) then
            localLibPath:=ReadString(rkLocalLibPath)
         else localLibPath:='';
         LLStringToLV;
         if ValueExists(rkCompareOption) then
            compareOption:=ReadInteger(rkCompareOption)
         else compareOption:=2;
         case compareOption of
           1 : RBParse8000.Checked:=True;
           2 : RBParse4000.Checked:=True;
           3 : RBParse2000.Checked:=True;
           4 : RBCompareAlways.Checked:=True;
         else ;
           RBParseAlways.Checked:=True;
         end;
         if ValueExists(rkCBDefaultEntry) then
            CBDefaultEntry.ItemIndex:=ReadInteger(rkCBDefaultEntry)
         else CBDefaultEntry.ItemIndex:=0;
		   if ValueExists(rkCBRememberDrills) then
	   		CBRememberDrills.Checked:=ReadBool(rkCBRememberDrills)
   		else CBRememberDrills.Checked:=False;
		   if ValueExists(rkCBToolBar) then
	   		CBToolBar.Checked:=ReadBool(rkCBToolBar)
   		else CBToolBar.Checked:=True;

		   if ValueExists(cwrkEDShortCut) then
	   		EDShortCut.Text:=ReadString(cwrkEDShortCut)
   		else EDShortCut.Text:='CTRL+W';

		   if ValueExists(rkCBConsolidateMethDecl) then
	   		CBConsolidateMethodDeclarations.Checked:=ReadBool(rkCBConsolidateMethDecl)
   		else CBConsolidateMethodDeclarations.Checked:=False;
			if ValueExists(rkCBWarpPreview) then
				CBWarpPreview.Checked:=ReadBool(rkCBWarpPreview)
   		else CBWarpPreview.Checked:=False;
		end else begin
			// Impossible d'ouvrir/créer la clef
			ShowMessage('Registry Access Failed : '+cwrkKey);
			Halt;
		end;
		Free;
	end;
end;

procedure TCodeWarpOptions.FormDestroy(Sender: TObject);
begin
   Application.HintHidePause:=oldHintHidePause;
end;

procedure TCodeWarpOptions.Button1Click(Sender: TObject);
var
   sc : Integer;
begin
   sc:=TextToShortCut(EDShortCut.Text);
   if ShortCutToText(sc)='' then begin
      MessageDlg('Shortcut syntax is Invalid.'+#13#10+'Correct it please.',
                 mtError, [mbOK], 0);
      Exit;
   end else EDShortCut.Text:=ShortCutToText(sc);
   SetShortCut(sc);
   vOptionsChanged:=True;
   LVToLLString;
	// Registry Session : Software\CodeWarp
	with TRegistry.Create do begin
		if OpenKey(cwrkKey, True) then begin
			// Clef ouverte/créée correctement
			WriteBool(rkCBIgnoreForwards, CBIgnoreForwards.Checked);
   		WriteBool(rkCBIgnoreEZInheritance, CBIgnoreEZInheritance.Checked);
   		WriteBool(rkCBSortTheNodes, CBSortTheNode.Checked);
   		WriteBool(rkRBWarpToCode, RBWarpToCode.Checked);
   		WriteBool(rkCBHideMethodKind, CBHideMethodKind.Checked);
   		WriteBool(rkCBHideClassParameters, CBHideClassParameters.Checked);
         WriteBool(rkCBHeight, CBHeight.Checked);
         WriteBool(rkCBIncludeRecordsInClassTree, CBIncludeRecordsInClassTree.Checked);
         WriteBool(rkCBShowScope, CBShowScope.Checked);
         WriteBool(rkCBShowMethodsUnder, CBShowMethodsUnder.Checked);
         WriteString(rkVCLPath, vclPath);
         WriteString(rkLocalLibPath, localLibPath);
         WriteInteger(rkCompareOption, compareOption);
         WriteInteger(rkCBDefaultEntry, CBDefaultEntry.ItemIndex);
         WriteBool(rkCBRememberDrills, CBRememberDrills.Checked);
         WriteBool(rkCBToolBar, CBToolBar.Checked);
         WriteString(cwrkEDShortCut, EDShortCut.Text);
			WriteBool(rkCBConsolidateMethDecl, CBConsolidateMethodDeclarations.Checked);
			WriteBool(rkCBWarpPreview, CBWarpPreview.Checked);
 	 end else begin
			// Impossible d'ouvrir/créer la clef
			ShowMessage('Registry Access Fail : '+cwrkKey);
			Halt;
		end;
		Free;
	end;
   Close;
end;

procedure TCodeWarpOptions.RBNoneClick(Sender: TObject);
begin
   vclPath:=''; EDPath.Enabled:=False; EDPath.Color:=clBtnFace;
end;

procedure TCodeWarpOptions.RBDelphi11Click(Sender: TObject);
begin
	vclPath:=(Sender as TRadioButton).Caption;
	EDPath.Enabled:=False; EDPath.Color:=clBtnFace;
end;

procedure TCodeWarpOptions.RBCustomClick(Sender: TObject);
begin
	vclPath:=EDPath.Text; EDPath.Enabled:=True; EDPath.Color:=clWindow;
end;

procedure TCodeWarpOptions.EDPathChange(Sender: TObject);
begin
   if EDPath.Enabled then vclPath:=EDPath.Text;
   if Copy(vclPath, Length(vclPath), 1)='\' then
      vclPath:=Copy(vclPath, 1, Length(vclPath)-1);
end;

procedure TCodeWarpOptions.RBParseAlwaysClick(Sender: TObject);
begin
   compareOption:=(Sender as TRadioButton).Tag;
end;

procedure TCodeWarpOptions.BBHelpClick(Sender: TObject);
begin
   Application.HelpContext(HelpContext);
end;

procedure TCodeWarpOptions.BUAddClick(Sender: TObject);
begin
   with LVLocalLibs.Items.Add do begin
      if EDNewEntry.Text='' then
         Caption:='NewEntry'
      else Caption:=EDNewEntry.Text;
      SubItems.Add(EDNewPath.Text);
      SubItems.Add(EDNewFilter.Text);
   end;
end;

procedure TCodeWarpOptions.LVLocalLibsDblClick(Sender: TObject);
begin
   if LVLocalLibs.Selected<>nil then with LVLocalLibs.Selected do
      SubItems[0]:=InputBox('Local Libs', 'Enter Path for '+Caption, SubItems[0]);
end;

procedure TCodeWarpOptions.MIEditFilterClick(Sender: TObject);
begin
   if LVLocalLibs.Selected<>nil then with LVLocalLibs.Selected do
      SubItems[1]:=InputBox('Local Libs', 'Enter File Filter for '+Caption, SubItems[1]);
end;

procedure TCodeWarpOptions.LVLocalLibsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   with LVLocalLibs do begin
      if IsEditing or (Selected=nil) then Exit;
		if (Key=VK_DELETE) or (KEY=VK_BACK) then
         if MessageDlg('Remove Entry "'+Selected.Caption+'" ?',
      	              mtConfirmation, [mbYes, mbNo], 0) = mrYes then
            Selected.Free;
   end;
end;

procedure TCodeWarpOptions.PMLocalLibsPopup(Sender: TObject);
begin
   MIEditName.Enabled:=(LVLocalLibs.Selected<>nil);
   MIEditPath.Enabled:=MIEditName.Enabled;
end;

procedure TCodeWarpOptions.MIEditNameClick(Sender: TObject);
begin
   with LVLocalLibs do if Selected<>nil then Selected.EditCaption;
end;

procedure TCodeWarpOptions.MIRemoveEntryClick(Sender: TObject);
var
   key : Word;
begin
   key:=VK_DELETE;
   LVLocalLibsKeyDown(Sender, key, []);
end;

procedure TCodeWarpOptions.MIMoveUpClick(Sender: TObject);
var
   i : Integer;
   sl : TStringList;
begin
   if LVLocalLibs.Selected<>nil then begin
		i:=LVLocalLibs.Selected.Index;
      if i>0 then begin
         LVToLLString;
         sl:=TStringList.Create; sl.CommaText:=localLibPath;
         sl.Exchange(i, i-1);
         localLibPath:=sl.CommaText;
         sl.Free;
         LLStringToLV;
         LVLocalLibs.Selected:=LVLocalLibs.Items[i-1];
      end;
   end;
end;

procedure TCodeWarpOptions.MIMoveDownClick(Sender: TObject);
var
   i : Integer;
	sl : TStringList;
begin
   if LVLocalLibs.Selected<>nil then begin
      i:=LVLocalLibs.Selected.Index;
      if i<LVLocalLibs.Items.Count-1 then begin
         LVToLLString;
         sl:=TStringList.Create; sl.CommaText:=localLibPath;
         sl.Exchange(i, i+1);
         localLibPath:=sl.CommaText;
         sl.Free;
         LLStringToLV;
         LVLocalLibs.Selected:=LVLocalLibs.Items[i+1];
      end;
   end;
end;

end.
