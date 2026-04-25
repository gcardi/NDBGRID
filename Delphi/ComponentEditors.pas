unit ComponentEditors;

interface

uses
  System.Classes, System.TypInfo,
  DesignIntf, DesignEditors;

type
  TPropEditorWithDialog = class
  private
    FPropName: string;
    procedure CheckEditProperty(const Prop: IProperty);
  public
    procedure EditProperty(Component: TPersistent; const PropName: string;
      const Designer: IDesigner);
  end;

procedure EditPropertyDlg(Component: TPersistent; const PropName: string;
  const Designer: IDesigner);

implementation

type
  TDesignerSelectionsAccess = class(TDesignerSelections);

{ TPropEditorWithDialog }

procedure TPropEditorWithDialog.CheckEditProperty(const Prop: IProperty);
begin
  if Prop.GetName = FPropName then
    Prop.Edit;
end;

procedure TPropEditorWithDialog.EditProperty(Component: TPersistent;
  const PropName: string; const Designer: IDesigner);
var
  Selections: TDesignerSelections;
  ISelections: IDesignerSelections;
begin
  FPropName := PropName;
  Selections := TDesignerSelections.Create;
  ISelections := Selections;
  TDesignerSelectionsAccess(Selections).Add(Component);
  GetComponentProperties(ISelections, [tkClass], Designer, CheckEditProperty);
end;

{ EditPropertyDlg }

procedure EditPropertyDlg(Component: TPersistent; const PropName: string;
  const Designer: IDesigner);
var
  Edt: TPropEditorWithDialog;
begin
  Edt := TPropEditorWithDialog.Create;
  try
    Edt.EditProperty(Component, PropName, Designer);
  finally
    Edt.Free;
  end;
end;

end.
