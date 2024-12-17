unit UCodeWarpParser;

interface

uses
   System.Classes,
   Vcl.ComCtrls,
   Generics.Collections;

type
   TVirtualTreeNode = class
      Caption : String;
      ImageIndex : Integer;
      Line : Integer;
      Children : array of TVirtualTreeNode;
      TreeNode : TTreeNode;

      destructor Destroy; override;

      function AddChild(const aCaption : String; imageIndex, line : Integer) : TVirtualTreeNode;
      function Count : Integer; inline;
      function GetFirstChild : TVirtualTreeNode;
      function GetLastChild : TVirtualTreeNode;
      procedure AlphaSort;

      procedure MapToTreeView(treeView : TTreeView; parent : TTreeNode);
      procedure Expand(treeView : TTreeView);
   end;

function ParseLines(bufLines : TStrings; rootNode : TVirtualTreeNode;
                    procList : TList<TVirtualTreeNode>) : TVirtualTreeNode;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

// A few weird things used for self-test
uses {IFDEF X} FCodeWarpOptions,
   // doodle,
   (* omega, // *) Dialogs, // { alpha ,}
   SysUtils;

// Destroy
//
destructor TVirtualTreeNode.Destroy;
begin
   for var i := 0 to High(Children) do
      FreeAndNil(Children[i]);
end;

// AddChild
//
function TVirtualTreeNode.AddChild(const aCaption : String; imageIndex, line : Integer) : TVirtualTreeNode;
var
   n : Integer;
begin
   Result := TVirtualTreeNode.Create;
   Result.Caption := aCaption;
   Result.ImageIndex := imageIndex;
   Result.Line := line;
   n := Length(Children);
   SetLength(Children, n+1);
   Children[n] := Result;
end;

// Count
//
function TVirtualTreeNode.Count : Integer;
begin
   Result := Length(Children);
end;

// GetFirstChild
//
function TVirtualTreeNode.GetFirstChild : TVirtualTreeNode;
begin
   Result := Children[0];
end;

// GetLastChild
//
function TVirtualTreeNode.GetLastChild : TVirtualTreeNode;
begin
   Result := Children[High(Children)];
end;

// AlphaSort
//
procedure TVirtualTreeNode.AlphaSort;
begin
   for var i := 0 to Count-2 do begin
      var k := i;
      for var j := i + 1 to Count-1 do begin
         if CompareText(Children[j].Caption, Children[k].Caption) < 0 then
            k := j;
      end;
      if k <> i then begin
         var tmp := Children[k];
         Children[k] := Children[i];
         Children[i] := tmp;
      end;
   end;
end;

// MapToTreeView
//
procedure TVirtualTreeNode.MapToTreeView(treeView : TTreeView; parent : TTreeNode);
begin
   for var i := 0 to Count-1 do begin
      var child := Children[i];
      child.TreeNode := treeView.Items.AddChildObject(parent, child.Caption, child);
      child.TreeNode.ImageIndex := child.ImageIndex;
      if child.Count > 0 then begin
         treeView.Items.AddChild(child.TreeNode, '-autoexpand');
      end;
   end;
end;

// Expand
//
procedure TVirtualTreeNode.Expand(treeView : TTreeView);
begin
   MapToTreeView(treeView, TreeNode);
end;

function CleanUpComments(const src : String) : String;
var
   i : Integer;
   str : TStringStream;
   inCPPCom, inParCom, inAccCom : Boolean;
begin
   str:=TStringStream.Create('');
   inCPPCom:=False; inParCom:=False; inAccCom:=False;
   i:=1; while i<Length(src) do begin
      case src[i] of
         '/' : if (not (inParCom or inAccCom)) and (src[i+1]='/') then inCPPCom:=True;
         '{' : if (not inCPPCom) then inAccCom:=True;
         '}' : if inAccCom then inAccCom:=False;
         '(' : if (not inCPPCom) and (src[i+1]='*') then inParCom:=True;
         '*' : if inParCom and (src[i+1]=')') then begin inParCom:=False; Inc(i); end;
         #13 : inCPPCom:=False;
      else
         if not (inParCom or inCPPCom or inAccCom) then str.Write(src[i], 1);
      end;
      Inc(i);
   end;
   if not (inParCom or inCPPCom or inAccCom) then str.Write(src[i], 1);
   Result:=str.DataString; str.Free;
end;

function NormalizePascalLine(const line : String) : String;
var
   c, lc : Char;
   i, k, len : Integer;
   inString : Boolean;
begin
   len:=Length(line);
   SetLength(Result, len);
   k:=1; lc:=#9; inString:=False;
   for i:=1 to len do begin
      c:=line[i];
      case c of
         '''' : begin
               inString:=not inString;
               lc:=c; Result[k]:=c; Inc(k);
            end;
         #9, ' ' : if inString then begin
               lc:=c; Result[k]:=c; Inc(k);
            end else if lc<>#9 then begin
               lc:=#9; Result[k]:=' '; Inc(k);
            end;
      else
         lc:=c; Result[k]:=c; Inc(k);
      end;
   end;
   SetLength(Result, k-1);
end;

function FindStuff(const str : String; firstChar : Char;
                   const alternatives : array of String; const endChars : String) : Integer;
var
   i, p, la : Integer;
   subStr, alt : String;
begin
   Result:=0;
   for p:=1 to Length(str) do if str[p]=firstChar then begin
      subStr:=Copy(str, p+1, MaxInt);
      for i:=Low(alternatives) to High(alternatives) do begin
         alt:=alternatives[i]; la:=Length(alt);
         if Copy(subStr, 1, la)=alt then
            if (Length(subStr)=la) or (Pos(subStr[la+1], endChars)>0) then begin
               Result:=p;
               Exit;
            end;
      end;
   end;
end;

function PackClassName(const aClassName : String) : String;
var
   p1, p2 : Integer;
   genTypes : String;
begin
   p1:=Pos('<', aClassName);
   if p1>0 then begin
      p2:=Pos('>', aClassName);
      genTypes:=Copy(aClassName, p1+1, p2-p1-1);
      p2:=Pos(':', genTypes);
      if p2>0 then
         genTypes:=Copy(genTypes, 1, p2-1);
      Result:=Trim(Copy(aClassName, 1, p1-1))+'<'+Trim(genTypes)+'>';
   end else Result:=aClassName;
end;

function ParseLines(bufLines : TStrings; rootNode : TVirtualTreeNode;
                    procList : TList<TVirtualTreeNode>) : TVirtualTreeNode;
const
   scopeStrings : array [11..14] of string = ('private', 'protected', 'public', 'published');
var
   beforeInterf, inImplem, isOfObject, inClassFuncProc, flagBasicClass : Boolean;
   node, nInterface, nProcs, nFuncs, nClasses, nImplementation, newNode : TVirtualTreeNode;
   sl, usesList : TStringList;
   i, k, foundScope, ptPos, img : Integer;
   s, sstart, ls, lls, classString, lastClass, usesString : string;
begin
   // Prepare TreeView
   sl := TStringList.Create;
   sl.Sorted := True;
   inImplem := False;
   beforeInterf := True;

   if rootNode = nil then
      Result := TVirtualTreeNode.Create
   else Result := rootNode;

   nClasses        := Result.AddChild('1. Classes', 1, 0);
   nInterface      := Result.AddChild('2. Interface', 9, 0);
   nImplementation := Result.AddChild('3. Implementation', 2, 0);
   nProcs          := Result.AddChild('4. Procedures', 3, 0);
   nFuncs          := Result.AddChild('5. Functions', 4, 0);

   // parse all the lines
   for i := 0 to bufLines.Count-1 do begin
      if bufLines[i] = '' then continue;
      s := NormalizePascalLine(bufLines[i]);
      ls := LowerCase(s);
      if beforeInterf and (ls='interface') then begin
         beforeInterf := False;
         nInterface.Line := i;
         continue;
      end;
      if (lastClass <> '') and (ls = 'end;') then begin
         lastClass := '';
         continue;
      end;
      // section specific tags
      if not inImplem then begin
         if ls = 'implementation' then begin
            lastClass:='';
            inImplem:=True;
            nProcs.Line := i;
            nFuncs.Line := i;
            nImplementation.Line := i;
            continue;
         end else if ls = 'type' then begin
            lastClass := '';
            nInterface.AddChild(ls, 9, i);
            continue;
         end;
      end else begin
         if ls='initialization' then begin
            lastClass:='';
            nImplementation.AddChild(ls, 2, i);
            continue;
         end else if ls='finalization' then begin
            lastClass:='';
            nImplementation.AddChild(ls, 2, i);
            continue;
         end else if ls='type' then begin
            lastClass:='';
            nImplementation.AddChild(ls, 2, i);
            continue;
         end;
      end;
      // class scopes lookup
      if lastClass <> '' then begin
         foundScope:=0;
         for k:=11 to 14 do if ls=scopeStrings[k] then begin
            foundScope:=k; Break;
         end;
         if foundScope>0 then begin
            if CodeWarpOptions.CBShowScope.Checked then begin
               k:=sl.IndexOf(lastClass);
               if k>=0 then begin
                  node:=TVirtualTreeNode(sl.Objects[k]);
                  node.AddChild(ls, foundScope, i);
               end;
            end;
            if inImplem then begin
               node:=nImplementation.GetLastChild;
               if node.ImageIndex=1 then begin // 1 is class Index
                  node.AddChild(ls, foundScope, i);
               end;
            end else begin
               node:=nInterface.GetLastChild;
               if node.ImageIndex=1 then begin // 1 is class Index
                  node.AddChild(ls, foundScope, i);
               end;
            end;
         end;
      end else begin
         // outside of class tokens
         if Trim(Copy(ls, 1, 5))='uses' then begin
            if inImplem then begin
               newNode := nImplementation.AddChild('uses', 2, i);
            end else begin
               newNode := nInterface.AddChild('uses', 9, i);
            end;
            k:=i;
            usesString:='';
            repeat
               usesString := usesString + #13 + bufLines[k];
               Inc(k);
               ptPos := Pos(';', usesString);
            until (ptPos>0) or (k=bufLines.Count);
            if ptPos > 0 then
               usesString := Copy(usesString, 1, ptPos-1);
            usesString:=Trim(usesString);
            usesString:=CleanUpComments(Copy(usesString, 6, MaxInt));
            usesList:=TStringList.Create;
            usesList.CommaText:=usesString; k:=0;
            while k < usesList.Count do begin
               if AnsiChar(usesList[k][1]) in ['a'..'z', 'A'..'Z'] then begin
                  node := newNode.AddChild(usesList[k], 16, -7);
                  node.AddChild('token', 0, 0);
                  if k < usesList.Count-1 then
                     if LowerCase(usesList[k+1])='in' then
                        Inc(k, 2);
               end;
               Inc(k);
            end;
            usesList.Free;
         end;
      end;
      // procs, funcs, const etc...
      if Copy(ls, 1, 6)='class ' then begin
         inClassFuncProc:=True;
         s:=Copy(s, 7, MaxInt);
         ls:=LowerCase(s);
         classString:='class ';
      end else begin
         inClassFuncProc:=False;
         classString:='';
      end;
      sstart:=Copy(ls, 1, 9);
      if lastClass='' then begin
         if (sstart='procedure') or (sstart='function ') then begin
            ptPos:=Pos('.', s);
            isOfObject:=(ptPos>0);
            if ls[1]='p' then begin
               node:=nProcs; img:=3;
               if isOfObject then ls:=Trim(Copy(s, 11, ptPos-11));
            end else begin
               node:=nFuncs; img:=4;
               if isOfObject then ls:=Trim(Copy(s, 10, ptPos-10));
            end;
            if inClassFuncProc then img:=img+4;
            if CodeWarpOptions.CBHideClassParameters.Checked then begin
               k:=Pos('(', s)-1;
               if k<1 then k:=Pos(':', s)-1;
               if k<1 then k:=Pos(';', s)-1;
               if k>=1 then s:=Copy(s, 1, k);
            end else if CodeWarpOptions.CBConsolidateMethodDeclarations.Checked then begin
               k:=i+1;
               while (k<bufLines.Count) and (Length(s)<255) and ((Pos(')', s)<1)
                     or (Pos(';', Copy(s, Pos(')', s), MaxInt))<1)) do begin
                  s:=s+' '+Trim(bufLines[k]);
                  Inc(k);
               end;
            end;
            newNode:=nil;
            if not inImplem then begin
               if not isOfObject then begin
                  if CodeWarpOptions.CBHideMethodKind.Checked then
                     s:=Copy(s, Pos(' ', s)+1, MaxInt);
                  nInterface.AddChild(classString + s, img, i);
               end;
            end else begin
               if (not isOfObject) or CodeWarpOptions.CBShowMethodsUnder.Checked then begin
                  if CodeWarpOptions.CBHideMethodKind.Checked then
                     newNode := node.AddChild(Copy(s, Pos(' ', s)+1), img, i)
                  else newNode := node.AddChild(classString+s, img, i)
               end;
               if isOfObject then begin
                  k:=sl.IndexOf(ls);
                  if k>=0 then begin
                     node := TVirtualTreeNode(sl.Objects[k]);
                     if CodeWarpOptions.CBHideMethodKind.Checked then
                        newNode := node.AddChild(Copy(s, ptPos+1), img, i)
                     else newNode := node.AddChild(classString+s, img, i)
                  end;
               end;
            end;
            if Assigned(newNode) and Assigned(procList) then procList.Add(newNode);
         end else if (sstart='construct') or (sstart='destructo') then begin
            ptPos:=Pos('.', s);
            isOfObject:=(ptPos>0);
            if sstart[1]='c' then begin
               img:=5;
               ls:=Copy(s, 13, ptPos-13);
            end else begin
               img:=6;
               ls:=Copy(s, 12, ptPos-12);
            end;
            if CodeWarpOptions.CBHideMethodKind.Checked then
               s:=Copy(s, ptPos+1, MaxInt);
            if CodeWarpOptions.CBHideClassParameters.Checked then begin
               k:=Pos('(', s)-1;
               if k<1 then k:=Pos(':', s)-1;
               if k<1 then k:=Pos(';', s)-1;
               if k>=1 then s:=Copy(s, 1, k);
            end;
            newNode:=nil;
            if not inImplem then begin
               if not isOfObject then
                  nInterface.AddChild(s, img, i)
            end else if isOfObject then begin
               k := sl.IndexOf(ls);
               if k >= 0 then begin
                  node := TVirtualTreeNode(sl.Objects[k]);
                  newNode := node.AddChild(s, img, i);
               end;
            end;
            if Assigned(newNode) and Assigned(procList) then
               procList.Add(newNode);
         end
      end;
      // class records & other type definitions
      if Pos('=', ls) > 0 then begin
         if FindStuff(ls, '=', [' class', 'class', ' interface', 'interface',
                                ' dispinterface', 'dispinterface'], ' (;')>0 then begin
            lastClass:='';
            if Pos('class', ls) > 0 then img:=1 else img:=23;
            flagBasicClass := (Pos(';', ls)>0);
            with CodeWarpOptions do if CBIgnoreEZInheritance.Checked
                  or CBIgnoreForwards.Checked then begin
               if flagBasicClass then begin
                  k:=Pos('(', ls);
                  if CBIgnoreEZInheritance.Checked and (k>0) then continue;
                  if CBIgnoreForwards.Checked and (k<=0) then continue;
               end;
            end;
            lls:=Trim(Copy(s, 1, Pos('=', s)-1));
            if Pos('<', lls)>0 then
               ls:=Trim(Copy(ls, 1, Pos('<', ls)))
            else ls:=lls;
            if Pos(' ', ls) < 1 then begin
               s:=Trim(s);
               if inImplem then
                  nImplementation.AddChild(s, img, i)
               else nInterface.AddChild(s, img, i);
               node := nClasses.AddChild(s, img, i);
               sl.AddObject(PackClassName(lls), node);
               if not flagBasicClass then
                  lastClass := ls;
            end;
         end else begin
            if FindStuff(ls, '=', ['= record', '=record', '= packed record',
                                    '=packed record'], ' ')>0 then begin
               lastClass := '';
               ls := Trim(Copy(s, 1, Pos('=', s)-1));
               if Pos(' ', ls) < 1 then begin
                  s := Trim(s);
                  if inImplem then
                     nImplementation.AddChild(s, 10, i)
                  else nInterface.AddChild(s, 10, i);
                  if CodeWarpOptions.CBIncludeRecordsInClassTree.Checked then
                     nClasses.AddChild(s, 10, i);
               end;
            end;
         end;
      end;
   end;
   sl.Free;
   if CodeWarpOptions.CBSortTheNode.Checked then begin
      // Manual AlphaSort requests are BY FAR the quickest way to sort the tree
      nClasses.AlphaSort;
      nInterface.AlphaSort;
      nProcs.AlphaSort;
      nFuncs.AlphaSort;
      for i:=0 to nClasses.Count-1 do
         if nClasses.Children[i].Count > 1 then
            nClasses.Children[i].AlphaSort;
   end;
//   if nClasses.Count = 1 then
//      nClasses.GetFirstChild.Expand(False);
end;

end.
