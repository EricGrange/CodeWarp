unit CodeWarpExpert;

interface

uses Windows, Classes, ToolsAPI, Menus, SysUtils; //ExptIntf, ToolIntf,

type

   TCodeWarpExpert = class(TNotifierObject, IOTAWizard, IOTAMenuWizard)
      private
//         FCounter: Integer;
      protected
         // IOTAWizard
         function GetIDString: string;
         function GetName: string;
         function GetState: TWizardState;
         procedure Execute;
         // IOTAMenuWizard}
         function GetMenuText: string;
      public
         constructor Create;
         destructor Destroy; override;
   end;

   // TCWKeyBinding
   //
   TCWKeyBinding = class (TNotifierObject, IOTAKeyboardBinding)
      procedure KeyProcWarp(const Context: IOTAKeyContext; KeyCode: TShortcut; var BindingResult: TKeyBindingResult);

      procedure BindKeyboard(const BindingServices: IOTAKeyBindingServices);
      function GetBindingType : TBindingType;
      function GetDisplayName : String;
      function GetName : String;
   end;


var
   vWarpShortCut : Integer = $4057; // Ctr+Maj+W

//function CodeWarpIniFileName : String;
//procedure LoadCodeWarpSettings;
//procedure SaveCodeWarpSettings;

procedure SetShortCut(aShortCut : Integer);
function GetShortCut: Integer;

procedure Register;

//var                                w
//   isNotRegistered : Boolean;
//   cDontForgetToRegister : string = 'CodeWarp Trial Expired !'+#13#10
//                                    +'Don''t Forget to Register !';

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses Dialogs, FCodeWarp, AboutCodeWarp, FCodeWarpOptions,
	Registry, ExtCtrls;

var
//	vCodeWarpExpert   : TCodeWarpExpert;
//	fToolServices     : TIToolServices = nil;
	timer             : TTimer;
//	fMainMenu         : TIMainMenuIntf = nil;
//	fAMenuItem        : TIMenuItemIntf = nil;
//   fMenuParent       : TIMenuItemIntf = nil;
//	itemIndex, shortcut          : Integer;


function TCodeWarpExpert.GetIDString: string;
begin
   Result:='CodeWarp';
end;

function TCodeWarpExpert.GetName: string;
begin
   Result:='CodeWarp';
end;

function TCodeWarpExpert.GetState: TWizardState;
begin
   Result:=[wsEnabled];
end;

function TCodeWarpExpert.GetMenuText: string;
begin
   Result:='CodeWarp';
end;

procedure TCodeWarpExpert.Execute;
begin
	if not Assigned(CodeWarpForm) then
    CodeWarpForm:=TCodeWarpForm.Create(nil);

  if not Assigned(AboutCodeWarpBox) then
	 AboutCodeWarpBox:=TAboutCodeWarpBox.Create(nil);

//  AboutCodeWarpBox.ShowModal;
  CodeWarpForm.ShowModal;
end;

{procedure TCodeWarpExpert.OnMenuClick(Sender : TIMenuItemIntf);
begin
  if not Assigned(CodeWarpForm) then
		CodeWarpForm:=TCodeWarpForm.Create(nil);

	CodeWarpForm.ShowModal;
end;}

constructor TCodeWarpExpert.Create;
begin

end;

destructor TCodeWarpExpert.Destroy;
begin
{ ASC
  Moved the code from the finalization-section into the destructor because there it was
  never exwecuted.
}
  if Assigned(timer) then timer.Free;
  if Assigned(AboutCodeWarpBox) then AboutCodeWarpBox.Free;
  if Assigned(CodeWarpForm) then CodeWarpForm.Free;

{  if Assigned(fToolServices) then begin
    fMainMenu:=fToolServices.GetMainMenu;
    if Assigned(fMainMenu) then begin
      fAMenuItem:=fMainMenu.FindMenuItem(TCodeWarpExpert.ClassName+'Item');
      if Assigned(fAMenuItem) then begin
        fAMenuItem.SetShortCut(0);
        fAMenuItem.DestroyMenuItem;
      end
      else
        ShowMessage('Item wasn''t assigned !');
    end
    else
      ShowMessage('Unable to retrieve MainMenu !');
  end
  else
    ShowMessage('ToolServices Unavailable !'); }

  inherited;
end;

{ ASC
  Changed a little bit here to make shure 'shortcut' is bind to the CodeWarp-menuitem.
}
{procedure TCodeWarpExpert.ForceShortcut(Sender : TObject);
begin
  if (GetShortCut <> shortcut)
     or (timer.Tag > 4)
  then begin
    timer.Tag:=timer.Tag + 1;
    SetShortCut(shortcut);
  end
  else begin
    timer.Enabled:=False;
    FreeAndNil(timer);
  end;
end;                 }

var
   vKeyBindingIndex : Integer;

procedure Register;
begin
   RegisterPackageWizard(TCodeWarpExpert.Create);

   vKeyBindingIndex:=(BorlandIDEServices as IOTAKeyboardServices).AddKeyboardBinding(TCWKeyBinding.Create);

{   ShowMessage('Registering CodeWarp');
   fToolServices:=ToolServices;
   if Assigned(fToolServices) then begin
     vCodeWarpExpert:=TCodeWarpExpert.Create;
     RegisterLibraryExpert(vCodeWarpExpert);

     if cAddInMenuItem<>'' then begin
		   fMainMenu:=fToolServices.GetMainMenu;
			 if Assigned(fMainMenu) then
         try
           fAMenuItem:=fMainMenu.FindMenuItem(cAddInMenuItem);
           if fAMenuItem=nil then
             ShowMessage('Invalid Menu Item !')
           else begin
             fMenuParent:=fAMenuItem.GetParent;
             itemIndex:=fAMenuItem.GetIndex;
             if cAddInMenuAppend then
               itemIndex:=itemIndex+1;

             // Registry Session : HKEY_CURRENT_USER\cwrkKey
             shortcut:=TextToShortCut(cAddInMenuShortcut);
             with TRegistry.Create do begin
               RootKey:=HKEY_CURRENT_USER;
               if OpenKey(cwrkKey, True) and ValueExists(cwrkEDShortCut) then
                 // Clef ouverte/créée correctement
                 shortcut:=TextToShortCut(ReadString(cwrkEDShortCut));
               Free;
             end;
             if Assigned(fMenuParent) then begin
               try
                 //with fMenuParent do
                   fMenuParent.InsertItem(itemIndex, cAddInMenuText, TCodeWarpExpert.ClassName+'Item',
                              cAddInMenuHint, shortCut, 0, 0,
                              [mfEnabled, mfVisible], vCodeWarpExpert.OnMenuClick);

                 if timer=nil then begin
                   timer:=TTimer.Create(nil);
                   timer.Interval:=3000;
                   timer.OnTimer:=vCodeWarpExpert.ForceShortcut;
                   timer.Enabled:=True;
                 end;
               finally
                 fMenuParent := nil;
               end;
               fAMenuItem := nil;
             end;
           end;
         finally
				   fMainMenu := nil;
         end
       else
         ShowMessage('No Main Menu !');
		end;
	end;                     }
//   isNotRegistered:=False;
end;

procedure SetShortCut (aShortCut : Integer);
begin
{
	if Assigned(fToolServices) then
    try
      fMainMenu:=fToolServices.GetMainMenu;
      if Assigned(fMainMenu) then
        try
          fAMenuItem:=fMainMenu.FindMenuItem(TCodeWarpExpert.ClassName+'Item');
          if Assigned(fAMenuItem)
            then fAMenuItem.SetShortCut(aShortCut)
            else ShowMessage('Item wasn''t assigned !');
        finally
          fAMenuItem := nil;
        end
      else
        ShowMessage('Unable to retrieve MainMenu !');
    finally
      fMainMenu := nil;
    end
  else
    ShowMessage('ToolServices Unavailable !');
    }
end;

function GetShortCut: Integer;
begin
  Result := 0;
{
	if Assigned(fToolServices) then
    try
      fMainMenu:=fToolServices.GetMainMenu;
      if Assigned(fMainMenu) then
        try
          fAMenuItem:=fMainMenu.FindMenuItem(TCodeWarpExpert.ClassName+'Item');
          if Assigned(fAMenuItem)
            then Result := fAMenuItem.GetShortCut
            else ShowMessage('Item wasn''t assigned !');
        finally
          fAMenuItem := nil;
        end
      else
        ShowMessage('Unable to retrieve MainMenu !');
    finally
      fMainMenu := nil;
    end
  else
    ShowMessage('ToolServices Unavailable !');
    }
end;

// ------------------
// ------------------ TCWKeyBinding ------------------
// ------------------

// BindKeyboard
//
procedure TCWKeyBinding.BindKeyboard(const BindingServices: IOTAKeyBindingServices);
begin
   BindingServices.AddKeyBinding([vWarpShortCut], KeyProcWarp, nil, 0);
end;

// GetBindingType
//
function TCWKeyBinding.GetBindingType : TBindingType;
begin
   Result:=btPartial;
end;

// GetDisplayName
//
function TCWKeyBinding.GetDisplayName : String;
begin
   Result:='CodeWarp KeyBinding';
end;

// GetName
//
function TCWKeyBinding.GetName : String;
begin
   Result:=GetDisplayName;
end;

// KeyProcWarp
//
procedure TCWKeyBinding.KeyProcWarp(const Context: IOTAKeyContext; KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
begin
	if not Assigned(CodeWarpForm) then
    CodeWarpForm:=TCodeWarpForm.Create(nil);

  if not Assigned(AboutCodeWarpBox) then
	 AboutCodeWarpBox:=TAboutCodeWarpBox.Create(nil);

//  AboutCodeWarpBox.ShowModal;
  CodeWarpForm.ShowModal;

  BindingResult:=krHandled;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
finalization
{
   FreeAndNil(timer);
   FreeAndNil(AboutCodeWarpBox);
   FreeAndNil(CodeWarpForm);
   if Assigned(fToolServices) then begin
     fMainMenu:=fToolServices.GetMainMenu;
     if Assigned(fMainMenu) then
       try
         fAMenuItem:=fMainMenu.FindMenuItem(TCodeWarpExpert.ClassName+'Item');
         if Assigned(fAMenuItem) then begin
           fAMenuItem.SetShortCut(0);
           fAMenuItem.DestroyMenuItem;
           fAMenuItem := nil;
         end
         else
           ShowMessage('Item wasn''t assigned !');
       finally
         fMainMenu := nil;
       end
     else
       ShowMessage('Unable to retrieve MainMenu !');
   end
   else
     ShowMessage('ToolServices Unavailable !');
}
//   if isNotRegistered then ShowMessage(cDontForgetToRegister);

end.
