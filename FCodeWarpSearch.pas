unit FCodeWarpSearch;

interface

uses
  Winapi.Windows,
  System.Classes,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Controls;

type
  TCodeWarpSearch = class(TForm)
    LASearchFrom: TLabel;
    BUFind: TButton;
    BUCancel: TButton;
    CBCaseSensitive: TCheckBox;
    RBDive: TRadioButton;
    RBTraverse: TRadioButton;
    CBSearchText: TComboBox;
    procedure BUFindClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CBSearchTextChange(Sender: TObject);
  private
    { Déclarations privées }
    tv : TTreeView;
    node, lastFound : TTreeNode;
    txt : String;
    caseSensitive, skipNodes, reachedMaxDepth : Boolean;
    function DiveSearch(n : TTreeNode) : TTreeNode;
    function TraverseSearch(n : TTreeNode; depthToGo : Integer) : TTreeNode;
  public
    { Déclarations publiques }
    procedure SearchTreeView(aTreeView : TTreeView; baseNode : TTreeNode);
  end;

implementation

{$R *.DFM}

uses System.SysUtils, FCodeWarpOptions, System.Win.Registry;

const
   rkCBCaseSensitiveSearch = 'CBCaseSensitiveSearch';
   rkRBDiveSearch = 'RBDiveSearch';
   rkSearchMRI = 'SearchMRI';

procedure TCodeWarpSearch.SearchTreeView(aTreeView : TTreeView; baseNode : TTreeNode);
begin
   if not Assigned(aTreeView) then Exit;
   if not Assigned(baseNode) then baseNode:=aTreeView.TopItem;
   if not Assigned(baseNode) then Exit;
   tv:=aTreeView; node:=baseNode;
   lastFound:=node; skipNodes:=True;
   LASearchFrom.Caption:='Searching from "'+baseNode.Text+'"';
   ShowModal;
end;

procedure TCodeWarpSearch.BUFindClick(Sender: TObject);
var
   n : TTreeNode;
   depth, i : Integer;
begin
   // MRUIze (last 16)
   with CBSearchText do begin
      txt:=Text;
      i:=Items.IndexOf(txt);
      if i>0 then
         Items.Move(i, 0)
      else if i<0 then Items.Insert(0, txt);
      while Items.Count>16 do Items.Delete(Items.Count-1);
      Text:=txt;
   end;
   // Perform the Search
   caseSensitive:=CBCaseSensitive.Checked;
   if not caseSensitive then
      txt:=LowerCase(CBSearchText.Text);
   if RBDive.Checked then
      n:=DiveSearch(node)
   else if RBTraverse.Checked then begin
      depth:=-1; repeat
         reachedMaxDepth:=False;
         Inc(depth);
         n:=TraverseSearch(node, depth);
      until Assigned(n) or (not reachedMaxDepth);
   end else n:=nil;
   if Assigned(n) then begin
      n.MakeVisible;
      tv.Selected:=n;
      skipNodes:=True;
      lastFound:=n;
   end else begin
      MessageBox(0, 'No match found.', 'Search', MB_ICONINFORMATION+MB_OK);
      skipNodes:=False;
   end;
end;

function TCodeWarpSearch.DiveSearch(n : TTreeNode) : TTreeNode;
var
   found : Boolean;
   i : Integer;
begin
   if caseSensitive then
      found:=(Pos(txt, n.Text)>0)
   else found:=(Pos(txt, LowerCase(n.Text))>0);
   if found and skipNodes then begin
      found:=False;
      if n=lastFound then skipNodes:=False;
   end;
   if found then
      Result:=n
   else begin
      Result:=nil;
      for i:=0 to n.Count-1 do begin
         Result:=DiveSearch(n.Item[i]);
         if Result<>nil then Break;
      end;
   end;
end;

function TCodeWarpSearch.TraverseSearch(n : TTreeNode; depthToGo : Integer) : TTreeNode;
var
   found : Boolean;
   i : Integer;
begin
   if depthToGo=0 then begin
      reachedMaxDepth:=True;
      if caseSensitive then
         found:=(Pos(txt, n.Text)>0)
      else found:=(Pos(txt, LowerCase(n.Text))>0);
      if found and skipNodes then begin
         found:=False;
         if n=lastFound then skipNodes:=False;
      end;
   end else found:=False;
   if found then
      Result:=n
   else begin
      Result:=nil;
      if depthToGo>0 then for i:=0 to n.Count-1 do begin
         Result:=TraverseSearch(n.Item[i], depthToGo-1);
         if Result<>nil then Break;
      end;
   end;
end;

procedure TCodeWarpSearch.FormShow(Sender: TObject);
begin
   CBSearchText.SetFocus;
end;

procedure TCodeWarpSearch.FormCreate(Sender: TObject);
begin
	with TRegistry.Create do begin
		if OpenKey(cwrkKey, True) then begin
			// Clef ouverte/créée correctement
   		if ValueExists(rkCBCaseSensitiveSearch) then
	   		CBCaseSensitive.Checked:=ReadBool(rkCBCaseSensitiveSearch);
   		if ValueExists(rkRBDiveSearch) then begin
	   		RBDive.Checked:=ReadBool(rkRBDiveSearch);
            RBTraverse.Checked:=not RBDive.Checked;
         end;
   		if ValueExists(rkSearchMRI) then
	   		CBSearchText.Items.Text:=ReadString(rkSearchMRI);
      end;
      Free;
   end;
end;

procedure TCodeWarpSearch.FormDestroy(Sender: TObject);
begin
	with TRegistry.Create do begin
		if OpenKey(cwrkKey, True) then begin
			// Clef ouverte/créée correctement
         WriteBool(rkCBCaseSensitiveSearch, CBCaseSensitive.Checked);
         WriteBool(rkRBDiveSearch, RBDive.Checked);
         WriteString(rkSearchMRI, CBSearchText.Items.Text);
      end;
      Free;
   end;
end;

procedure TCodeWarpSearch.CBSearchTextChange(Sender: TObject);
begin
   skipNodes:=False;
end;

end.
