unit FCodeWarp;

interface

uses
  Winapi.Windows,
  System.ImageList, System.Classes,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.ToolWin, Vcl.Forms,
  Vcl.Controls, Vcl.ImgList,
  FCodeWarpSearch, UCodeWarpParser, Generics.Collections;

type

  TCodeWarpForm = class(TForm)
    Panel2: TPanel;
    Panel1: TPanel;
    TreeView: TTreeView;
    PaintBox: TPaintBox;
    Panel3: TPanel;
    SpeedButton1: TSpeedButton;
    ILStates: TImageList;
    PAToolButtons: TPanel;
    TBButtons: TToolBar;
    TBClass: TToolButton;
    TBImplem: TToolButton;
    TBProcs: TToolButton;
    TBFuncs: TToolButton;
	 TBProject: TToolButton;
    TBComps: TToolButton;
    TBVCL: TToolButton;
    TBInterf: TToolButton;
    TBLocals: TToolButton;
    TBAbout: TToolButton;
    TBSearch: TToolButton;
    STWarpPreview: TStaticText;
    TIWarpPreview: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TreeViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TreeViewExpanding(Sender: TObject; Node: TTreeNode;
		var AllowExpansion: Boolean);
    procedure TreeViewGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure TreeViewCollapsing(Sender: TObject; Node: TTreeNode;
		var AllowCollapse: Boolean);
    procedure TreeViewKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TreeViewKeyPress(Sender: TObject; var Key: Char);
    procedure FormHide(Sender: TObject);
    procedure TBAboutClick(Sender: TObject);
    procedure TBClassClick(Sender: TObject);
    procedure TBSearchClick(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
		Shift: TShiftState; X, Y: Integer);
	 procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
		Y: Integer);
    procedure TIWarpPreviewTimer(Sender: TObject);
	 procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
  private
	 { Déclarations privées }
	 srchWin : TCodeWarpSearch;
	 packages : TStringList;
	 vclSubDirs, localSubDirs : String;
	 drillMemory, selectedMemory : TStringList;
    FVirtualTree : TVirtualTreeNode;
	 procedure LaunchSearch;
	 function FindUsesFile(fileNode : TTreeNode) : String;
	 procedure ShortCutToEntry(entry : Integer);
	 procedure MakeNodeVisible(aNode : TTreeNode);
	 function GetWarpPreview : String;
  public
	 { Déclarations publiques }
  end;

var
	CodeWarpForm: TCodeWarpForm;
   vLastBuf : TStringList;

implementation

{$R *.DFM}

uses Messages, AboutCodeWarp, CodeWarpExpert, UIDEBuffer, ToolsAPI,
     FCodeWarpOptions, Registry, SysUtils, Dialogs, Graphics;

type
  TFillDirection = (fdTopToBottom, fdBottomToTop, fdLeftToRight, fdRightToLeft);

const
   nvProject = -1;
   nvComponents = -2;
   nvLocalLibs = -3;
   nvVCLSource = -4;
   nvFile = -5;
   nvPackageFile = -6;
   nvUsesFile = -7;
   nvDirectory = -8;
   nvProjectFile = 100000;
   nvProjectFileEnd = nvProjectFile + 99999;
	nvPackageBase = 200000;
   nvPackageBaseEnd = nvPackageBase + 99999;
	csVCLSource = 'VCL Source';

var
   moduleCount : Integer;
   lKeyTime : TDateTime;

// Returned list to be freed by caller !
function GetFileFromBestSource(const fileName : String) : TStringList;
begin
   Result:=nil;
   if IDEHasBuffer(fileName) then begin
      Result:=GetIDENamedBuffer(fileName);
   end else if FileExists(fileName) then begin
      Result:=TStringList.Create;
      Result.LoadFromFile(fileName);
   end;
end;

procedure RememberSelected(sl : TStringList; node : TTreeNode);
begin
   if Assigned(node) then begin
      sl.Add(node.Text);
      RememberSelected(sl, node.Parent);
   end;
end;

function RetrieveSelected(sl : TStringList; i : Integer; firstSibling : TTreeNode) : TTreeNode;
begin
   Result:=nil;
   if i<0 then Exit;
   while Assigned(firstSibling) do begin
      if firstSibling.Text=sl[i] then begin
         if i=0 then
            Result:=firstSibling
         else Result:=RetrieveSelected(sl, i-1, firstSibling.GetFirstChild);
         Break;
      end;
      firstSibling:=firstSibling.GetNextSibling;
   end;
end;

procedure RememberDrill(sl : TStringList; node : TTreeNode);
begin
   while Assigned(node) do begin
      if node.Expanded then begin
         sl.Add(node.Text);
         RememberDrill(sl, node.GetFirstChild);
      end;
      node:=node.GetNextSibling;
   end;
   sl.Add('-');
end;

procedure ApplyRememberedDrill(sl : TStringList; tv : TTreeView);
var
   idx : Integer;
   nodeText : string;
   baseNode : TTreeNode;

   procedure SkipANodeAndItsChildren;
   var
      k : Integer;
   begin
      k:=1; repeat
         Inc(idx);
         if sl[idx]='-' then Dec(k)
         else if sl.Objects[idx]<>Pointer(-1) then Inc(k);
      until (k=0);
   end;

   procedure ApplyDrill(node : TTreeNode);
   var
      curNode : TTreeNode;
      theText : string;
   begin
      if sl[idx]<>'-' then begin
         // le noeud a-t-il un child nommé ainsi ?
         theText:=sl[idx];
         curNode:=node.GetFirstChild;
         while Assigned(curNode) do begin
            if curNode.Text=theText then begin
               // yeah, got it !
               curNode.Expand(False);
               ApplyDrill(curNode);
               Break;
            end;
            curNode:=curNode.GetNextSibling;
         end;
         if curNode=nil then SkipANodeAndItsChildren;
      end;
      Inc(Idx);
   end;

begin
   idx:=0;
//   ShowMessage(sl.Text);
   while idx<sl.Count do begin
      nodeText:=sl[idx];
      if nodeText='-' then Break;
      baseNode:=tv.Items.GetFirstNode;
      while Assigned(baseNode) do begin
         if nodeText=baseNode.Text then begin
            baseNode.Expand(False);
            Inc(idx);
            ApplyDrill(baseNode);
            Break;
         end;
         baseNode:=baseNode.GetNextSibling;
      end;
      if baseNode=nil then begin
         SkipANodeAndItsChildren;
         Inc(idx);
      end;
   end;
end;

function EditorShowSource(aSrcName : String) : Boolean;
var
   module : IOTAModule;
begin
   module:=(BorlandIDEServices as IOTAModuleServices).FindModule(aSrcName);
   if module=nil then
      module:=(BorlandIDEServices as IOTAModuleServices).FindModule(ExtractFileName(aSrcName));
   if module=nil then
      (BorlandIDEServices as IOTAActionServices).OpenFile(aSrcName)
   else module.ShowFilename(aSrcName);
   Result:=False;
end;

procedure WarpEditorTo(const fileName : String; col, line : Integer);
var
   editorServices : IOTAEditorServices;
   editBuffer : IOTAEditBuffer;
   editPosition : IOTAEditPosition;
begin
   editorServices:=(BorlandIDEServices as IOTAEditorServices);
   editBuffer:=editorServices.TopBuffer;
   if Assigned(editBuffer) and (not editBuffer.IsReadOnly) then begin
      editPosition:=editBuffer.EditPosition;
      if line>4 then begin
         editPosition.Move(editBuffer.GetLinesInBuffer, col);
         editPosition.Move(line-3, col);
         editPosition.Move(line, col);
      end else editPosition.Move(1, col)
   end;
end;

function ComposeFileName(node : TTreeNode) : String;
var
   i, p : Integer;
   walkingNode : TTreeNode;
   sl : TStringList;
   buf : String;
begin
   Result:=node.Text; node:=node.Parent;
   walkingNode:=nil;
//   ShowMessage(node.Text);
   while node.Data <> nil do begin
      if (node.ImageIndex=19) or (node.ImageIndex=20) then walkingNode:=node;
      Result:=node.Text+'\'+Result;
      node:=node.Parent;
//      ShowMessage(node.Text);
   end;
   if Pos(csVCLSource, node.Text)>0 then
      Result:=vclPath+'\'+Result
   else begin
      sl:=TStringList.Create;
      try
         sl.CommaText:=localLibPath;
         if Assigned(walkingNode) and (walkingNode.Data=Pointer(nvLocalLibs)) then begin
            i:=0;
            while walkingNode.GetPrevSibling<>nil do begin
               walkingNode:=walkingNode.GetPrevSibling; Inc(i);
            end;
            p:=Pos('\', Result); if p>0 then Result:=Copy(Result, p+1, MaxInt);
            p:=Pos('¤', sl[i]);
            buf:=Copy(sl[i], p+1, MaxInt);
            p:=Pos('¤', buf); if p>0 then buf:=Copy(buf, 1, p-1);
            Result:=buf+'\'+Result;
         end else begin
            p:=Pos('¤', localLibPath);
            if p>0 then begin
               p:=Pos('¤', sl[0]);
               buf:=Copy(sl[0], p+1, MaxInt);
               p:=Pos('¤', buf); if p>0 then buf:=Copy(buf, 1, p-1);
               Result:=buf+'\'+Result;
            end else Result:=localLibPath+'\'+Result;
         end;
      finally
         sl.Free;
      end;
   end;
end;

function GetStandardSearchPath : String;
begin
   with TRegistry.Create do begin
		OpenKey((BorlandIDEServices as IOTAServices).GetBaseRegistryKey+'\Library', False);
		if ValueExists('SearchPath') then // Delphi 3
			Result:=ReadString('SearchPath')
		else Result:='';
		if ValueExists('Search Path') then // Delphi 4 and 5
			Result:=Result+';'+ReadString('Search Path');
		if ValueExists('BrowsingPath') then // Delphi 3
			Result:=Result+';'+ReadString('BrowsingPath');
		if ValueExists('Browsing Path') then // Delphi 4 and 5
			Result:=Result+';'+ReadString('Browsing Path');
		CloseKey;
      Free;
   end;
end;

function FindDPKFile(packageIndex : Integer; packages : TStrings) : String;
var
   fname, dirList : string;
begin
   if Cardinal(packageIndex) < Cardinal(packages.Count) then
      fname := packages[packageIndex];
   Result := ExtractFileName(copy(fname, 1, Length(fname)-3)+'dpk');
	dirList := '.;'+ExtractFilePath(fname)+';'+GetStandardSearchPath;
	fname := Result;
   Result := FileSearch(fname, dirList);
   if Result = '' then
      Result := fname;
end;

function FindPackageFile(fileNode : TTreeNode; packages : TStrings) : String;
var
   dirList : string;
begin
   dirList:=ExtractFilePath(FindDPKFile(Integer(fileNode.Parent.Data)-nvPackageBase, packages))
            +';.;'+GetStandardSearchPath;
   Result:=FileSearch(fileNode.Text+'.pas', dirList);
   if Result='' then Result:=fileNode.Text+'.pas';
end;

function BuildSubDirList(baseDir : string) : string;
var
   sr : TSearchRec;
   i : Integer;
begin
   Result:=baseDir;
   if Result='' then Exit;
   i:=FindFirst(baseDir+'\*.*', faDirectory, sr);
   while i=0 do begin
      if sr.Name[1]<>'.' then
         Result:=Result+';'+BuildSubDirList(baseDir+'\'+sr.Name);
      i:=FindNext(sr);
   end;
   FindClose(sr);
end;

procedure TCodeWarpForm.FormCreate(Sender: TObject);
begin
   CodeWarpOptions:=TCodeWarpOptions.Create(nil);
   packages:=TStringList.Create;
   drillMemory:=TStringList.Create;
   selectedMemory:=TStringList.Create;
   PaintBox.ControlStyle:=PaintBox.ControlStyle+[csCaptureMouse];
end;

procedure TCodeWarpForm.FormDestroy(Sender: TObject);
begin
   FreeAndNil(FVirtualTree);
   FreeAndNil(CodeWarpOptions);
   FreeAndNil(packages);
   drillMemory.Free;
   srchWin.Free;
   selectedMemory.Free;
end;

procedure TCodeWarpForm.FormShow(Sender: TObject);
var
   shouldCompare : Boolean;
   i, linePick, curLine, nodeLine, bestLine : integer;
   nProject, nComponents, nVCL, nLocalLib : TVirtualTreeNode;
   aNode : TTreeNode;
   bufLines : TStringList;
   zprocList : TList<TVirtualTreeNode>;
begin
//   ShowMessage('here');
	vclSubDirs:=''; localSubDirs:='';

	if CodeWarpOptions.CBWarpPreview.Checked
    then STWarpPreview.Height:=60
	  else STWarpPreview.Height:=0;

  if CodeWarpOptions.CBHeight.Checked
    then Height:=Screen.Height-30
    else Height:=(Screen.Height*2) div 3;

   Top:=(Screen.Height-Height) div 2;
   Left:=(Screen.Width-Width) div 2;
   // Set Up Window
	Caption:=' '+ExtractFileName(GetIDEProjectName)+' - '
            +ExtractFileName(GetIDECurrentFile);
   if Caption='  - ' then Caption:='CodeWarp';
   // Comparison Checks
   bufLines:=GetIDEBuffer;
   if bufLines.Count>0 then begin
      with CodeWarpOptions do case compareOption of
         1 : shouldCompare:=(bufLines.Count>=8000);
         2 : shouldCompare:=(bufLines.Count>=4000);
         3 : shouldCompare:=(bufLines.Count>=2000);
         4 : shouldCompare:=True;
      else
         shouldCompare:=False;
      end;
      if shouldCompare and Assigned(vLastBuf) then begin
			if bufLines.Equals(vLastBuf) then Exit;
      end;
      vLastBuf.Free;
   end;

   TreeView.OnChange := nil;
   SendMessage(TreeView.Handle, WM_SETREDRAW, 0, 0);

   with TreeView.Items do begin
		BeginUpdate;
      Clear;
      if CodeWarpOptions.CBDefaultEntry.ItemIndex = 9 then
         zprocList := TList<TVirtualTreeNode>.Create
      else zprocList := nil;
      if bufLines.Count>0 then begin
         FreeAndNil(FVirtualTree);
         FVirtualTree := ParseLines(bufLines, nil, zprocList);
         nProject := FVirtualTree.AddChild('6. Project '+ExtractFileName(GetIDEProjectName), 15, nvProject);
         nProject.AddChild('token', 0, 0);
      end else nProject := nil;
      nComponents := FVirtualTree.AddChild('7. Components', 18, nvComponents);
      nComponents.AddChild('token', 0, 0);
      if localLibPath <> '' then begin
         nLocalLib := FVirtualTree.AddChild('8. Local Libraries', 16, nvLocalLibs);
         nLocalLib.AddChild('token', 0, 0);
		end else nLocalLib := nil;
      if vclPath <> '' then begin
         nVCL := FVirtualTree.AddChild('9. '+csVCLSource, 21, nvVCLSource);
         nVCL.AddChild('token', 0, 0);
		end else nVCL := nil;

      FVirtualTree.MapToTreeView(TreeView, nil);
      EndUpdate;
   end;

   SendMessage(TreeView.Handle, WM_SETREDRAW, 1, 0);
   TreeView.OnChange := TreeViewChange;

	vLastBuf := bufLines;
   aNode := TreeView.Items.GetFirstNode;
   case CodeWarpOptions.CBDefaultEntry.ItemIndex of
      1, 2, 3, 4 : begin
         i:=CodeWarpOptions.CBDefaultEntry.ItemIndex;
         while i>0 do begin
            aNode:=aNode.GetNextSibling; Dec(i);
         end;
      end;
      5 : nProject.Expand(TreeView);
      6 : nComponents.Expand(TreeView);
      7 : if Assigned(nLocalLib) then
            aNode := nLocalLib.TreeNode
         else aNode := TreeView.Items[0];
      8 : if Assigned(nVCL) then
            aNode := nVCL.TreeNode
         else aNode := TreeView.Items[0];
      9 : begin // closest node
         if zprocList.Count = 0 then begin
				aNode := TreeView.Items[0];
			end else begin
            curLine := GetIDECurrentLine;
            linePick := 0;
            bestLine := -1;
            for i := 0 to zprocList.Count-1 do begin
               nodeLine := zprocList[i].Line;
               if (nodeLine <= curLine) and (nodeLine > bestLine) then begin
                  linePick := i;
                  bestLine := nodeLine;
               end;
            end;
            aNode := zprocList[linePick].TreeNode;
            zprocList.Free;
         end;
      end;
      10 : begin // the previously focused
         aNode:=RetrieveSelected(selectedMemory, selectedMemory.Count-1,
                                 TreeView.Items.GetFirstNode);
//         if Assigned(aNode) then ShowMessage(aNode.Text) else ShowMessage('N/A');
		end;
	else ;
      aNode:=TreeView.Items[0];
   end;
   // drill reconstitution
   if CodeWarpOptions.CBRememberDrills.Checked then
      ApplyRememberedDrill(drillMemory, TreeView);
   // focus node
   if Assigned(aNode) then begin
      MakeNodeVisible(aNode);
      if CodeWarpOptions.CBDefaultEntry.ItemIndex<>10 then
         aNode.Expand(False);
      TreeView.Selected:=aNode;
   end;
   // ToolButtons handling
   PAToolButtons.Visible:=CodeWarpOptions.CBToolBar.Checked;
   if PAToolButtons.Visible then begin
      PAToolButtons.Left:=Width-PAToolButtons.Width-5-GetSystemMetrics(SM_CXVSCROLL);
      TBClass.Enabled:=(TreeView.Items[0].Text[1]='1');
      TBInterf.Enabled:=TBClass.Enabled;  TBImplem.Enabled:=TBClass.Enabled;
      TBProcs.Enabled:=TBClass.Enabled;   TBFuncs.Enabled:=TBClass.Enabled;
		TBProject.Enabled:=TBClass.Enabled;
		TBLocals.Enabled:=Assigned(nLocalLib);
		TBVCL.Enabled:=Assigned(nVCL);
   end;
end;

procedure TCodeWarpForm.FormHide(Sender: TObject);
begin
   if CodeWarpOptions.CBDefaultEntry.ItemIndex=10 then begin
      selectedMemory.Clear;
      RememberSelected(selectedMemory, TreeView.Selected);
   end;
   if CodeWarpOptions.CBRememberDrills.Checked then begin
      drillMemory.Clear;
      RememberDrill(drillMemory, TreeView.Items.GetFirstNode);
   end;
end;

function TCodeWarpForm.FindUsesFile(fileNode : TTreeNode) : String;
var
   dirList : string;
begin
   if vclSubDirs='' then vclSubDirs:=BuildSubDirList(vclPath);
   if localSubDirs='' then localSubDirs:=BuildSubDirList(localLibPath);
	dirList:='.;'+GetStandardSearchPath+';'+localSubDirs+';'+vclSubDirs;
	Result:=FileSearch(fileNode.Text+'.pas', dirList);
   if Result='' then Result:=fileNode.Text+'.pas';
end;

procedure TCodeWarpForm.Button1Click(Sender: TObject);
var
   fname, dpkname : String;
   fileNode : TTreeNode;
begin
   var selected := TreeView.Selected;
   if selected=nil then Exit;
   if (CodeWarpOptions.RBExpand.Checked and Selected.HasChildren)
         and Assigned(Sender) then begin
      Exit;
   end;

   var selectedData := IntPtr(Selected.Data);
   if selectedData=nvPackageFile then begin
      // Package File
      fname:=FindPackageFile(Selected, packages);
      if not EditorShowSource(fname) then Close;
   end else if selectedData=nvFile then begin
      // File (in local libs or vcl)
      fname:=ComposeFileName(Selected);
      if not EditorShowSource(fname) then Close;
   end else if selectedData=nvUsesFile then begin
      // File (in uses clause)
      fname:=FindUsesFile(Selected);
      if not EditorShowSource(fname) then Close;
   end else if (selectedData >= nvPackageBase) and (selectedData < nvPackageBaseEnd) then begin
      // Packet file
      dpkName:=FindDPKFile(selectedData-nvPackageBase, packages);
      if FileExists(dpkName) then begin
         (BorlandIDEServices as IOTAActionServices).OpenFile(dpkName);
         Close;
      end else begin
         Selected.DeleteChildren;
         ShowMessage('CodeWarp : Can''t Find Package Source File "'+dpkName+'".');
      end;
   end else if (selectedData >= nvProjectFile) and (selectedData < nvProjectFileEnd) then begin
      // a project file
//         if not EditorShowSource(ExptIntf.ToolServices.GetUnitName(Integer(Selected.Data)-nvProjectFile)) then Close;
   end else if selectedData>0 then begin
      // a line reference
      var node := Selected;
      fileNode:=nil;
      while (node.Parent<>nil) do begin
         if (node.ImageIndex=16) or (node.ImageIndex=17) then fileNode:=node;
         if Assigned(fileNode) and ((node.ImageIndex=9) or (node.ImageIndex=2)) then Break;
         node:=node.Parent;
      end;
      fname:='';
      case node.ImageIndex of
         15 : begin // project
            if not Assigned(fileNode) then Exit;
            fname:=fileNode.Text;
         end;
         18 : begin // components
            if not Assigned(fileNode) then Exit;
            fname:=FindPackageFile(fileNode, packages);
         end;
         16, 21 : begin // local libs & VCL Source
            if not Assigned(fileNode) then Exit;
            fname:=ComposeFileName(fileNode);
         end;
         9, 2 : begin // uses clause
            if Assigned(fileNode) then
               fname:=FindUsesFile(fileNode);
         end;
      end;
      var vnode := TVirtualTreeNode(Selected.Data);
      //   ShowMessage('Request for line '+IntToStr(vnode.Line+1)+' in "'+fname+'"');
      if (fname='') or FileExists(fname) then begin
         WarpEditorTo(fname, 1, vnode.Line+1);
         Close;
      end else ShowMessage('File not Found !');
   end else if (Sender=nil) and (Now-lKeyTime>1e-4) then begin
      lKeyTime:=Now;
      if Selected.Expanded then
         Selected.Collapse(False)
      else Selected.Expand(False);
   end;
end;

procedure TCodeWarpForm.ShortCutToEntry(entry : Integer);
var
   node : TTreeNode;
begin
   node:=TreeView.Items[0];
	while Assigned(node) and (Integer(node.Text[1])-Integer('1')<>entry) do
		node:=node.GetNextSibling;
   if Assigned(node) then begin
      TreeView.Selected:=node; MakeNodeVisible(node);
      if node.Expanded then node.Collapse(False) else node.Expand(False);
   end;
end;

procedure TCodeWarpForm.MakeNodeVisible(aNode : TTreeNode);
var
   r : TRect;
begin
   if Assigned(aNode) then begin
      aNode.MakeVisible;
      Application.ProcessMessages;
      r:=aNode.DisplayRect(True);
      if not PtInRect(TreeView.ClientRect, Point(r.Left, r.Top)) then begin
         TreeView.TopItem:=aNode;
      end;
   end;
end;

procedure TCodeWarpForm.TreeViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   case Key of
      13 : begin
         Key:=0;
         Button1Click(nil);
      end;
      27 : begin Key:=0; Close; end;
      112 : begin
         TBAboutClick(Self);
         Key:=0;
      end;
      Word('1')..Word('9') : begin
         ShortCutToEntry(Integer(Key)-Integer('1'));
         Key:=0;
      end;
      96, Word('0') : begin
         LaunchSearch;
         Key:=0;
      end;
      Word('F') : if Shift=[ssCtrl] then begin
         LaunchSearch;
         Key:=0;
      end;
      97..105 : begin ShortCutToEntry(Key-97); Key:=0; end;
   else
//      ShowMessage('Key : '+IntToStr(Key)+' = '''+Char(Key)+'''');
   end;
end;

// I took this code somewhere (can't remember...)
//     But don't trust it too much, it's rather slow and fails when color
//     intensity gets close to 255....
procedure GradientFillRect(Canvas: TCanvas; Rect: TRect; BeginColor,
  EndColor: TColor; Direction: TFillDirection; Colors: Byte);
var
  BeginRGBValue: array[0..2] of Byte;    { Begin RGB values }
  RGBDifference: array[0..2] of Integer; { Difference between begin and end RGB values }
  ColorBand: TRect; { Color band rectangular coordinates }
  I: Integer;       { Color band index }
  R, G, B: Byte;    { Color band Red, Green, Blue values }
begin
  case Direction of
    fdTopToBottom, fdLeftToRight: begin
      { Set the Red, Green and Blue colors }
      BeginRGBValue[0] := GetRValue(ColorToRGB(BeginColor));
      BeginRGBValue[1] := GetGValue(ColorToRGB(BeginColor));
      BeginRGBValue[2] := GetBValue(ColorToRGB(BeginColor));
      { Calculate the difference between begin and end RGB values }
      RGBDifference[0] := GetRValue(ColorToRGB(EndColor)) - BeginRGBValue[0];
      RGBDifference[1] := GetGValue(ColorToRGB(EndColor)) - BeginRGBValue[1];
      RGBDifference[2] := GetBValue(ColorToRGB(EndColor)) - BeginRGBValue[2];
    end;
    fdBottomToTop, fdRightToLeft: begin
      { Set the Red, Green and Blue colors }
      { Reverse of TopToBottom and LeftToRight directions }
      BeginRGBValue[0] := GetRValue(ColorToRGB(EndColor));
      BeginRGBValue[1] := GetGValue(ColorToRGB(EndColor));
      BeginRGBValue[2] := GetBValue(ColorToRGB(EndColor));
      { Calculate the difference between begin and end RGB values }
      { Reverse of TopToBottom and LeftToRight directions }
      RGBDifference[0] := GetRValue(ColorToRGB(BeginColor)) - BeginRGBValue[0];
      RGBDifference[1] := GetGValue(ColorToRGB(BeginColor)) - BeginRGBValue[1];
      RGBDifference[2] := GetBValue(ColorToRGB(BeginColor)) - BeginRGBValue[2];
    end;
  end; {case}
  { Calculate the color band's coordinates }
  case Direction of
    fdTopToBottom, fdBottomToTop: begin
      ColorBand.Left := Rect.Left;
      ColorBand.Right := Rect.Right - Rect.Left;
    end;
    fdLeftToRight, fdRightToLeft: begin
      ColorBand.Top := Rect.Top;
      ColorBand.Bottom := Rect.Bottom - Rect.Top;
    end;
  end; {case}
  with Canvas.Pen do begin { Set the pen style and mode }
    Style := psSolid;
    Mode := pmCopy;
  end;
  { Perform the fill }
  if Colors = 0 then Colors := 1;
  for I := 0 to Colors do begin
    case Direction of
      { Calculate the color band's top and bottom coordinates }
      fdTopToBottom, fdBottomToTop: begin
        ColorBand.Top := Rect.Top + MulDiv(I, Rect.Bottom - Rect.Top,
          Colors);
        ColorBand.Bottom := Rect.Top + MulDiv(I + 1, Rect.Bottom -
          Rect.Top, Colors);
      end;
      { Calculate the color band's left and right coordinates }
      fdLeftToRight, fdRightToLeft: begin
        ColorBand.Left := Rect.Left + MulDiv(I, Rect.Right - Rect.Left,
          Colors);
        ColorBand.Right := Rect.Left + MulDiv(I + 1, Rect.Right -
          Rect.Left, Colors);
      end;
    end; {case}
    { Calculate the color band's color }
    if Colors > 1 then begin
      R := BeginRGBValue[0] + MulDiv(I, RGBDifference[0], Colors - 1);
      G := BeginRGBValue[1] + MulDiv(I, RGBDifference[1], Colors - 1);
      B := BeginRGBValue[2] + MulDiv(I, RGBDifference[2], Colors - 1);
    end
    else begin
      { Set to the Begin Color if set to only one color }
      R := BeginRGBValue[0];
      G := BeginRGBValue[1];
      B := BeginRGBValue[2];
    end;
    with Canvas do begin
      Brush.Color := RGB(R, G, B);
      FillRect(ColorBand);
    end;
  end;
end;

procedure TCodeWarpForm.PaintBoxPaint(Sender: TObject);
var
   h : Integer;
begin
   h:=Self.Handle;
   if GetDeviceCaps(GetDC(h), BITSPIXEL)>=15 then begin
      Panel1.Color:=clBtnFace;   Panel3.Color:=clBtnFace;
      GradientFillRect(PaintBox.Canvas, PaintBox.ClientRect, clBlue,
                       clBtnFace,  fdLeftToRight, 64)
   end else with PaintBox, PaintBox.Canvas do begin
      Panel1.Color:=clActiveCaption;
      Panel3.Color:=clActiveCaption;
   end;
   with PaintBox.Canvas do begin
      Brush.Style:=bsClear;
      Font.Color:=clWhite;
      TextOut(4, 0, Caption);
   end;
end;

procedure TCodeWarpForm.FormDeactivate(Sender: TObject);
begin
   Close;
end;

procedure TCodeWarpForm.SpeedButton1Click(Sender: TObject);
begin
   Close;
end;

function EnumProc(Param: Pointer; const FileName, UnitName, FormName: string): Boolean stdcall;
var
   node, child : TTreeNode;
begin
   node:=TTreeNode(Param);
   with ((node.TreeView) as TTreeView).Items do if FormName='' then begin
      if (Pos('.pas', lowercase(FileName))>0) or (Pos('.dpr', lowercase(FileName))>0) then begin
         child:=AddChildObject(node, ExtractFileName(FileName), Pointer(nvProjectFile+moduleCount));
         child.ImageIndex:=16;
         AddChild(child, 'token');
      end;
   end else begin
      child:=AddChildObject(node, ExtractFileName(FileName), Pointer(nvProjectFile+moduleCount));
      child.ImageIndex:=17;
      AddChild(child, 'token');
   end;
   Inc(moduleCount);
   Result:=True;
end;

// RecDirParseToTree
//    Expand a directory structure, dir might be a LocalLibs structure
procedure RecDirParseToTree(node : TTreeNode; dir : string; rootLevel : Boolean);
var
   searchRec: TSearchRec;
   i, p : Integer;
   child : TTreeNode;
   filter : String;
begin
   if rootLevel and (Pos('¤', dir)>0) then begin
      // this is a locallibs structure
      var sl := TStringList.Create; sl.CommaText:=dir;
      if sl.Count>1 then begin
         // multiple local libs, we need sub nodes
         for i:=0 to sl.Count-1 do begin
            p:=Pos('¤', sl[i]);
            child:=TTreeView(node.TreeView).Items.AddChild(node, Copy(sl[i], 1, p-1));
            child.ImageIndex:=19; Child.Data:=Pointer(nvLocalLibs);
            TTreeView(node.TreeView).Items.AddChild(child, 'token');
         end;
         sl.Free;
         Exit;
      end else begin
         // unique local lib, expand directly
         p:=Pos('¤', sl[0]);
         dir:=Copy(sl[0], p+1, MaxInt);
         sl.Free;
      end;
   end;
   p:=Pos('¤', dir);
//   ShowMessage(dir);
   if p>0 then begin
      filter:=LowerCase(Copy(dir, p+1, MaxInt));
      dir:=Copy(dir, 1, p-1);
   end else filter:='*.pas;*.inc;*.int';
   i:=FindFirst(dir+'\*.*', faAnyFile, searchRec);
   while i=0 do begin
      if searchRec.name[1]<>'.' then begin
         if (searchRec.Attr and faDirectory)>0 then begin
            child:=TTreeView(node.TreeView).Items.AddChild(node, searchRec.Name);
            Child.ImageIndex:=19; Child.Data:=Pointer(nvDirectory);
            RecDirParseToTree(child, dir+'\'+searchRec.name+'¤'+filter, False);
         end else if Pos(ExtractFileExt(LowerCase(searchRec.Name)), filter)>0 then begin
            child:=TTreeView(node.TreeView).Items.AddChild(node, searchRec.Name);
            Child.ImageIndex:=16;
            Child.Data:=Pointer(nvFile);
            if (Pos('.pas', LowerCase(searchRec.Name))>0) or (Pos('.int', LowerCase(searchRec.Name))>0) then
               TTreeView(node.TreeView).Items.AddChild(Child, 'token');
         end;
      end;
      i:=FindNext(searchRec);
   end;
   FindClose(SearchRec);
   node.AlphaSort;
end;

procedure ParseDPK(node : TTreeNode; const dpkFile : string);
var
   sl : TStringList;
   i, p : integer;
   allFiles, buf : string;
   child : TTreeNode;
begin
   sl:=GetFileFromBestSource(dpkFile);
   if sl=nil then Exit;
   // lookup "contains" section
   i:=0; while i<sl.Count do
      if Copy(LowerCase(Trim(sl[i])), 1, 8)='contains' then Break else Inc(i);
   Inc(i);
   // make a single csv string from unit refs
   allFiles:='';
   while (i<sl.Count) and (Pos(';', allFiles)<1) do begin
      allFiles:=allFiles+Trim(sl[i]);
      Inc(i);
   end;
   i:=Pos(';', allFiles);
   if i>0 then allFiles:=Copy(allFiles, 1, i-1);
   // Convert csv to items
   sl.Clear;
   while allFiles<>'' do begin
      i:=Pos(',', allFiles);
      if i>0 then begin
         buf:=Copy(allFiles, 1, i-1);
         allFiles:=Copy(allFiles, i+1, MaxInt);
      end else begin
         buf:=allFiles;
         allFiles:='';
      end;
      buf:=Trim(buf);
      if buf<>'' then sl.Add(buf);
   end;
   // add all entries to tree view
   for i:=0 to sl.Count-1 do begin
      p:=Pos(' in ', LowerCase(sl[i]));
      if p>0 then
         buf:=Copy(sl[i], 1, p-1)
      else buf:=sl[i];
      child:=TTreeView(node.TreeView).Items.AddChild(node, buf);
      child.ImageIndex:=16;
      child.Data:=Pointer(nvPackageFile);
      TTreeView(node.TreeView).Items.AddChild(child, 'token');
   end;
   node.AlphaSort;
   sl.Free;
end;

procedure TCodeWarpForm.TreeViewExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var
   i, p : Integer;
   child : TTreeNode;
   fname : string;
   walkingNode : TTreeNode;
begin
   if Node.ImageIndex=19 then begin
      Node.ImageIndex:=20;
   end;
   if (IntPtr(Node.Data)>=0) and (IntPtr(Node.Data)<nvProjectFile) then Exit;
   if Node.Data=Pointer(nvProject) then begin
      TreeView.Items.BeginUpdate;
      // Project Units/Forms
      Node.Data:=nil;
      Node.DeleteChildren;
      moduleCount:=0;
      //fToolServices.EnumProjectUnits(EnumProc, node);
      Node.AlphaSort;
      TreeView.Items.EndUpdate;
   end else if Node.Data=Pointer(nvComponents) then begin
      if Node.Count=1 then begin
         // Installed Components Packets
         TreeView.Items.BeginUpdate;
         Node.Data:=nil; Node.DeleteChildren;
         with TRegistry.Create do begin
            OpenKey((BorlandIDEServices as IOTAServices).GetBaseRegistryKey+'\Known Packages', True);
            GetValueNames(packages);
            for i:=0 to packages.Count-1 do with TreeView.Items do begin
               child:=AddChildObject(node, ReadString(packages[i]), Pointer(nvPackageBase+i));
               child.ImageIndex:=18;
               AddChild(child, 'token');
            end;
            CloseKey; Free;
         end;
         Node.AlphaSort;
         TreeView.Items.EndUpdate;
      end;
   end else if Node.Data=Pointer(nvLocalLibs) then begin
      // Local Libs
      TreeView.Items.BeginUpdate;
      if Node.Parent=nil then begin
         // this is the root local libs node
         Node.Data:=nil; Node.DeleteChildren;
         RecDirParseToTree(node, localLibPath, True);
      end else if Node.Count=1 then begin
         // this is a sub local libs nodes
         Node.DeleteChildren;
         var sl := TStringList.Create;
         try
            sl.CommaText:=localLibPath;
            i:=0; walkingNode:=node;
            while walkingNode.GetPrevSibling<>nil do begin
               walkingNode:=walkingNode.GetPrevSibling; Inc(i);
            end;
            p:=Pos('¤', sl[i]);
            RecDirParseToTree(Node, Copy(sl[i], p+1, MaxInt), False);
         finally
            sl.Free;
         end;
      end;
      TreeView.Items.EndUpdate;
   end else if Node.Data=Pointer(nvVCLSource) then begin
      // VCL Source
      TreeView.Items.BeginUpdate;
      Node.Data:=nil; Node.DeleteChildren;
      RecDirParseToTree(node, vclPath, False);
      TreeView.Items.EndUpdate;
   end else if IntPtr(Node.Data)=nvFile then begin
      if Node.Count=1 then begin
         // File (from vcl or local libs)
         TreeView.Items.BeginUpdate;
         var sl : TStringList := nil;
         try
            fname:=ComposeFileName(Node);
            sl:=GetFileFromBestSource(fname);
            if sl<>nil then begin
               with TreeView.Items do begin
                  BeginUpdate;
                  node.DeleteChildren;
                  var sub := ParseLines(sl, TVirtualTreeNode(node.Data), nil);
                  sub.MapToTreeView(TreeView, node);
                  EndUpdate;
               end;
            end else begin
               node.DeleteChildren;
               ShowMessage('CodeWarp : File "'+fname+'" not found.');
            end;
         finally
            sl.Free;
         end;
         TreeView.Items.EndUpdate;
      end;
   end else if IntPtr(Node.Data)=nvUsesFile then begin
      if Node.Count=1 then begin
         // File (from uses)
         TreeView.Items.BeginUpdate;
         var sl := TStringList.Create;
         try
            fname:=FindUsesFile(Node);
            sl:=GetFileFromBestSource(fname);
            if sl<>nil then begin
               with TreeView.Items do begin
                  BeginUpdate;
                  node.DeleteChildren;
                  var sub := ParseLines(sl, TVirtualTreeNode(node.Data), nil);
                  sub.MapToTreeView(TreeView, node);
                  EndUpdate;
               end;
            end else begin
               node.DeleteChildren;
               ShowMessage('CodeWarp : File "'+fname+'" not found.');
            end;
         finally
            sl.Free;
         end;
         TreeView.Items.EndUpdate;
      end;
   end else if (IntPtr(Node.Data)>=nvProjectFile) and (IntPtr(Node.Data)<nvProjectFile+5000) then begin
      if Node.Count=1 then begin
         // Project File
         TreeView.Items.BeginUpdate;
         var sl := TStringList.Create;
         try
//            fname:=ExptIntf.ToolServices.GetUnitName(Integer(Node.Data)-nvProjectFile);
//            sl:=GetFileFromBestSource(fname);
//            if sl<>nil then begin
//               with TreeView.Items do begin
//                  BeginUpdate;
//                  node.DeleteChildren;
//                  ParseLines(sl, node, TreeView, nil);
//                  EndUpdate;
//               end;
//            end;
         finally
            sl.Free;
         end;
         TreeView.Items.EndUpdate;
      end;
   end else if (IntPtr(Node.Data)>=nvPackageBase) and (IntPtr(Node.Data)<nvPackageBase+5000) then begin
      if Node.Count=1 then begin
         // Components / Package (dpk)
         TreeView.Items.BeginUpdate;
         with TreeView.Items do begin
            BeginUpdate;
            node.DeleteChildren;
            ParseDPK(node, FindDPKFile(IntPtr(node.Data)-nvPackageBase, packages));
            EndUpdate;
         end;
         TreeView.Items.EndUpdate;
      end;
   end else if IntPtr(Node.Data)=nvPackageFile then begin
      if Node.Count=1 then begin
         // Package File
         TreeView.Items.BeginUpdate;
         var sl := TStringList.Create;
         try
            fname := FindPackageFile(Node, packages);
            sl := GetFileFromBestSource(fname);
            if sl <> nil then begin
               with TreeView.Items do begin
                  BeginUpdate;
                  node.DeleteChildren;
                  var sub := ParseLines(sl, TVirtualTreeNode(node.Data), nil);
                  sub.MapToTreeView(TreeView, node);
                  EndUpdate;
               end;
            end;
         finally
            sl.Free;
         end;
         TreeView.Items.EndUpdate;
      end;
   end else if (Node.Count = 1) and (Node.getFirstChild.Text = '-autoexpand') then begin
      TreeView.Items.BeginUpdate;
      Node.DeleteChildren;
      TVirtualTreeNode(Node.Data).MapToTreeView(TreeView, Node);
      TreeView.Items.EndUpdate;
   end;
   MakeNodeVisible(node);
end;

procedure TCodeWarpForm.TreeViewGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
   if Node.SelectedIndex<>Node.ImageIndex then
      Node.SelectedIndex:=Node.ImageIndex;
end;

procedure TCodeWarpForm.TreeViewCollapsing(Sender: TObject;
  Node: TTreeNode; var AllowCollapse: Boolean);
begin
   AllowCollapse:=True;
   if Node.ImageIndex=20 then begin
      Node.ImageIndex:=19;
   end;
end;

procedure TCodeWarpForm.TreeViewKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   lKeyTime := 0;
   Key := 0;
end;

procedure TCodeWarpForm.TreeViewKeyPress(Sender: TObject; var Key: Char);
begin
   case Key of
      #6, #32, #27, #13, '0'..'9' : Key:=#0;
   end;
end;

procedure TCodeWarpForm.TBAboutClick(Sender: TObject);
begin
   AboutCodeWarpBox:=TAboutCodeWarpBox.Create(nil);
   AboutCodeWarpBox.ShowModal; AboutCodeWarpBox.Free; AboutCodeWarpBox:=nil;
   if vOptionsChanged then begin
      if Assigned(vLastBuf) then
         vLastBuf.Clear;
      FormShow(Self);
   end;
   drillMemory.Clear;
   TreeView.Selected:=TreeView.Items[0];
end;

procedure TCodeWarpForm.TBClassClick(Sender: TObject);
begin
   ShortCutToEntry((Sender as TComponent).Tag);
end;

procedure TCodeWarpForm.TBSearchClick(Sender: TObject);
begin
   LaunchSearch;
end;

procedure TCodeWarpForm.LaunchSearch;
begin
   if not Assigned(srchWin) then srchWin:=TCodeWarpSearch.Create(Self);
   srchWin.SearchTreeView(TreeView, TreeView.Selected);
end;

procedure TCodeWarpForm.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if PaintBox.Tag<>MaxInt then begin
      var p := PaintBox.ClientToScreen(Point(x, y));
      PaintBox.Tag:=p.x;
      PaintBox.DesignInfo:=p.y;
   end;
end;

procedure TCodeWarpForm.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
   dx, dy : Integer;
   p : TPoint;
begin
   if (PaintBox.Tag<>MaxInt) and (Shift=[ssLeft]) then begin
      p:=PaintBox.ClientToScreen(Point(x, y));
      dx:=p.x-PaintBox.Tag;
		dy:=p.y-PaintBox.DesignInfo;
		PaintBox.Tag:=MaxInt;
      SetBounds(Left+dx, Top+dy, Width, Height);
      PaintBox.Tag:=p.x;
		PaintBox.DesignInfo:=p.y;
	end;
end;

function TCodeWarpForm.GetWarpPreview : String;
var
	fname, dpkname : String;
	node, fileNode : TTreeNode;

	function GetLineText(sl : TStrings; lineNb : Integer; pickedLine : Boolean) : String;
	begin
		if Cardinal(lineNb) < Cardinal(sl.Count) then
			if pickedLine then
				Result := Format('%5d>>%s'#13#10, [ lineNb+1, sl[lineNb] ])
			else Result := Format('%5d: %s'#13#10, [ lineNb+1, sl[lineNb] ])
		else Result := #13#10;
	end;

begin
	Result:='';
	with TreeView do begin
		if Selected=nil then Exit;
		if Selected.Data=Pointer(nvPackageFile) then begin
			// Package File
			fname:=FindPackageFile(Selected, packages);
			Result:=#13#10#13#10+'PackageFile : '+fname+#13#10#13#10;
		end else if Selected.Data=Pointer(nvFile) then begin
			// File (in local libs or vcl)
			fname:=ComposeFileName(Selected);
			Result:=#13#10#13#10+'File : '+fname+#13#10#13#10;
		end else if Selected.Data=Pointer(nvUsesFile) then begin
			// File (in uses clause)
			fname:=FindUsesFile(Selected);
			Result:=#13#10#13#10+'File : '+fname+#13#10#13#10;
		end else if IntPtr(Selected.Data) >= nvPackageBase then begin
			// Packet file
			dpkName:=FindDPKFile(IntPtr(Selected.Data)-nvPackageBase, packages);
//			if FileExists(dpkName) then begin
			Result:=#13#10#13#10+'PacketFile : '+dpkName+#13#10#13#10;
		end else if IntPtr(Selected.Data)>=nvProjectFile then begin
			// a project file
//			fname:=ExptIntf.ToolServices.GetUnitName(Integer(Selected.Data)-nvProjectFile);
//			Result:=#13#10#13#10+'ProjectFile : '+fname+#13#10#13#10;
		end else if IntPtr(Selected.Data)>0 then begin
			// a line reference
         node:=Selected; fileNode:=nil;
         while node.Parent<>nil do begin
            if (node.ImageIndex=16) or (node.ImageIndex=17) then fileNode:=node;
				if Assigned(fileNode) and ((node.ImageIndex=9) or (node.ImageIndex=2)) then Break;
				node:=node.Parent;
			end;
			fname:='';
         case node.ImageIndex of
            15 : begin // project
					if not Assigned(fileNode) then Exit;
					fname:=fileNode.Text;
				end;
				18 : begin // components
					if not Assigned(fileNode) then Exit;
					fname:=FindPackageFile(fileNode, packages);
					if fname='' then fname:='*';
				end;
				16, 21 : begin // local libs & VCL Source
					if not Assigned(fileNode) then Exit;
					fname:=ComposeFileName(fileNode);
				end;
				9, 2 : begin // uses clause
					if Assigned(fileNode) then
						fname:=FindUsesFile(fileNode);
				end;
			end;
			var warpLine := TVirtualTreeNode(Selected.Data).Line;
			if fname='' then begin
				for var i := warpLine-2 to warpLine+2 do
					Result := Result + GetLineText(vLastBuf, i, (i=warpLine));
			end else begin
				if FileExists(fname) then begin
					var fileStuff:=TStringList.Create;
					try
						fileStuff.LoadFromFile(fname);
						for var i:=warpLine-2 to warpLine+2 do
							Result:=Result+GetLineText(fileStuff, i, (i=warpLine));
					finally
						fileStuff.Free;
					end;
				end else	Result:=#13#10#13#10+'File : '+fname+', Line : '+IntToStr(Integer(Selected.Data)+1)+#13#10#13#10;
			end;
		end;
	end;
end;

procedure TCodeWarpForm.TIWarpPreviewTimer(Sender: TObject);
begin
	TIWarpPreview.Enabled := False;
	STWarpPreview.Caption := GetWarpPreview;
end;

procedure TCodeWarpForm.TreeViewChange(Sender: TObject; Node: TTreeNode);
begin
	if CodeWarpOptions.CBWarpPreview.Checked then begin
		TIWarpPreview.Enabled:=False;
		TIWarpPreview.Enabled:=True;
	end;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

	vLastBuf := nil;

finalization

   FreeAndNil(vLastBuf);

end.
