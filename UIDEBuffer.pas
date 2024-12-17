unit UIDEBuffer;

interface

uses System.Classes, ToolsAPI;

function EditBufferToString(editBuffer : IOTAEditBuffer) : String;
function GetIDEBuffer : TStringList;
function GetIDENamedBuffer(const bufName : String) : TStringList;
procedure SetIDEBuffer(aList : TStringList);
function IDEHasBuffer(const bufName : String) : Boolean;

function GetIDEProjectName: String;
function GetIDECurrentFile: String;
function GetIDECurrentView : IOTAEditView;
function GetIDECurrentLine : Integer;
function GetIDEView(const viewName : string) : IOTAEditView;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses Windows, SysUtils, Messages;

// GetIDECurrentLine
//
function GetIDECurrentLine : Integer;
var
   editorServices : IOTAEditorServices;
   editBuffer : IOTAEditBuffer;
   editPosition : IOTAEditPosition;
begin
   editorServices:=(BorlandIDEServices as IOTAEditorServices);
   editBuffer:=editorServices.TopBuffer;
   if Assigned(editBuffer) and (not editBuffer.IsReadOnly) then begin
      editPosition:=editBuffer.EditPosition;
      Result:=editPosition.Row;
   end else Result:=1;
end;

function GetIDEProjectName: String;
var
   proj : IOTAProject;
begin
   proj:=GetActiveProject;
   if proj<>nil then
      Result:=proj.GetFileName
   else Result:='';
end;

function GetIDECurrentFile: String;
var
   buffer : IOTAEditBuffer;
begin
   buffer:=(BorlandIDEServices as IOTAEditorServices).TopBuffer;
   if buffer<>nil then
      Result:=buffer.FileName
   else Result:='';
end;

function GetIDECurrentView: IOTAEditView;
begin
   Result:=(BorlandIDEServices as IOTAEditorServices).TopView;
end;

function GetIDEView(const viewName : string) : IOTAEditView;
var
   module : IOTAModule;
begin
   module:=(BorlandIDEServices as IOTAModuleServices).FindModule(viewName);
   if (module<>nil) and (module.ModuleFileCount>0) then begin
      module.Show;
      Result:=(module.ModuleFileEditors[0] as IOTASourceEditor).GetEditView(0);
   end else Result:=nil;
end;

function IDEHasBuffer(const bufName : String) : Boolean;
var
   module : IOTAModule;
begin
   module:=(BorlandIDEServices as IOTAModuleServices).FindModule(bufName);
   Result:=(module<>nil);
end;

function GetIDEBuffer : TStringList;
var
   editorServices : IOTAEditorServices;
   editBuffer : IOTAEditBuffer;
begin
   Result:=TStringList.Create;
   editorServices:=(BorlandIDEServices as IOTAEditorServices);
   editBuffer := editorServices.TopBuffer;
   if Assigned(editBuffer) and (not editBuffer.IsReadOnly) then
      Result.Text := EditBufferToString(editBuffer);
end;

// EditBufferToString
//
function EditBufferToString(editBuffer : IOTAEditBuffer) : String;
const
   cReadSize = 1024;
var
   editReader : IOTAEditReader;
   p, n : Integer;
   buf : AnsiString;
begin
   editReader:=editBuffer.CreateReader;
   Result:='';
   p:=0;
   repeat
      SetLength(buf, cReadSize);
      n := editReader.GetText(p, PAnsiChar(buf), cReadSize);
      Inc(p, n);
      SetLength(buf, n);
      Result := Result + String(buf);
   until n < cReadSize;
end;

// StringToEditBuffer
//
procedure StringToEditBuffer(const src : String; editBuffer : IOTAEditBuffer);
var
   editWriter : IOTAEditWriter;
   oldContent : String;
   buf : AnsiString;
   n : Integer;
   nMatchBegin, nMatchEnd : Integer;
begin
   oldContent:=EditBufferToString(editBuffer);
   if src=oldContent then Exit;

   n:=Length(src);
   if n>Length(oldContent) then
      n:=Length(oldContent);

   nMatchBegin:=1;
   while (nMatchBegin<=n) and (src[nMatchBegin]=oldContent[nMatchBegin]) do
      Inc(nMatchBegin);
   Dec(nMatchBegin);
   nMatchEnd:=0;
   while (nMatchEnd<n) and (src[Length(src)-nMatchEnd]=oldContent[Length(oldContent)-nMatchEnd]) do
      Inc(nMatchEnd);

   editWriter:=editBuffer.CreateUndoableWriter;
   editWriter.CopyTo(nMatchBegin);
   editWriter.DeleteTo(nMatchBegin+Length(oldContent)-nMatchBegin-nMatchEnd);
   buf:=AnsiString(Copy(src, nMatchBegin+1, Length(src)-nMatchBegin-nMatchEnd));
   editWriter.Insert(PAnsiChar(buf));
   editWriter.CopyTo(nMatchEnd);
end;

function GetIDENamedBuffer(const bufName : String) : TStringList;
var
   module : IOTAModule;
   sourceEditor : IOTASourceEditor;
   buffer : IOTAEditBuffer;
begin
   Result:=TStringList.Create;
   module:=(BorlandIDEServices as IOTAModuleServices).FindModule(bufName);
   if (module<>nil) and (module.ModuleFileCount>0) then begin
      sourceEditor:=(module.ModuleFileEditors[0] as IOTASourceEditor);
      if (sourceEditor<>nil) and (sourceEditor.EditViewCount>0) then begin
         buffer:=sourceEditor.EditViews[0].GetBuffer;
         if buffer<>nil then
            Result.Text:=EditBufferToString(buffer);
      end;
   end;
end;

procedure SetIDEBuffer(aList : TStringList);
var
   editorServices : IOTAEditorServices;
   editBuffer : IOTAEditBuffer;
begin
   editorServices:=(BorlandIDEServices as IOTAEditorServices);
   editBuffer:=editorServices.TopBuffer;
   if Assigned(editBuffer) and (not editBuffer.IsReadOnly) then
      StringToEditBuffer(aList.Text, editBuffer);
end;

end.

