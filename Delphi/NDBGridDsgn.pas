unit NDBGridDsgn;

interface

uses
  System.Classes,
  DesignIntf, DesignEditors,
  NDBGrid, ComponentEditors;

{$R EnhDbGridDsgnPkg_resources.res}

type
  TNDBGridComponentEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

procedure Register;

implementation

{ TNDBGridComponentEditor }

function TNDBGridComponentEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

function TNDBGridComponentEditor.GetVerb(Index: Integer): string;
begin
  Result := 'Co&lumns Editor...';
end;

procedure TNDBGridComponentEditor.ExecuteVerb(Index: Integer);
begin
  EditPropertyDlg(Component, 'Columns', Designer);
end;

{ Register }

procedure Register;
begin
  RegisterComponents('Data Controls', [TNDBGrid]);
  RegisterComponentEditor(TNDBGrid, TNDBGridComponentEditor);
end;

end.
