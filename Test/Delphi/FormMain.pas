unit FormMain;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.Actions, System.RegularExpressions,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.DBGrids, Vcl.Grids,
  Vcl.ActnList, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus, Vcl.ActnPopup,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.StdActns,
  Vcl.Buttons, Vcl.ComCtrls, Vcl.DBCtrls, Vcl.ExtCtrls, Vcl.ImgList,
  Vcl.Menus, Vcl.Themes, Vcl.ToolWin,
  Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.UI,
  FireDAC.Stan.Intf, FireDAC.UI.Intf, FireDAC.VCLUI.Wait,
  NDBGrid,
  DataMod;

type
  TForm1 = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    DBNavigator1: TDBNavigator;
    Panel2: TPanel;
    NDBGrid1: TNDBGrid;
    Splitter1: TSplitter;
    Panel3: TPanel;
    ActionManager1: TActionManager;
    FileExit1: TFileExit;
    ActionMainMenuBar1: TActionMainMenuBar;
    PopupMenu1: TPopupActionBar;
    Exit1: TMenuItem;
    comboboxStyle: TComboBox;
    Panel5: TPanel;
    Label1: TLabel;
    Button1: TButton;
    ColorBox1: TColorBox;
    Panel4: TPanel;
    Panel6: TPanel;
    Button2: TButton;
    ColorBox2: TColorBox;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure NDBGrid1AfterAutoSet(Sender: TObject);
    procedure comboboxStyleChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure NDBGrid1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DBGrid1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    FDmDatabase: TdmDatabase;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  StyleNames: TStringList;
  StyleName: string;
begin
  FDmDatabase := TdmDatabase.Create(nil);
  DataSource1.DataSet := FDmDatabase.FDQuery1;

  ColorBox1.Selected := NDBGrid1.TitleFont.Color;
  ColorBox2.Selected := NDBGrid1.FixedColor;

  StyleNames := TStringList.Create;
  try
    for StyleName in TStyleManager.StyleNames do
      StyleNames.Append(StyleName);
    comboboxStyle.Items.Assign(StyleNames);
  finally
    StyleNames.Free;
  end;
  comboboxStyle.ItemIndex :=
    comboboxStyle.Items.IndexOf(TStyleManager.ActiveStyle.Name);

  FDmDatabase.FDQuery1.Open;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FDmDatabase.Free;
end;

procedure TForm1.comboboxStyleChange(Sender: TObject);
begin
  TStyleManager.SetStyle(comboboxStyle.Text);
end;

procedure TForm1.NDBGrid1AfterAutoSet(Sender: TObject);
var
  Grid: TNDBGrid;
  OrderByClause: string;
  DataSet: TFDQuery;
  CmdText: TStringList;
  Re: TRegEx;
  Idx: Integer;
begin
  Grid := Sender as TNDBGrid;
  OrderByClause := Grid.GetOrderByClause;
  if not (Grid.DataSource.DataSet is TFDQuery) then
    Exit;

  DataSet := TFDQuery(Grid.DataSource.DataSet);
  CmdText := TStringList.Create;
  try
    CmdText.Assign(DataSet.SQL);

    DataSet.Close;
    try
      OutputDebugString(PChar(Grid.OrderByPrefix));

      Re := TRegEx.Create('^\s*' + Grid.OrderByPrefix + '.*$');
      for Idx := 0 to CmdText.Count - 1 do
        if Re.IsMatch(CmdText[Idx]) then begin
          CmdText[Idx] := OrderByClause;
          DataSet.SQL.Assign(CmdText);
          Exit;
        end;

      CmdText.Append(OrderByClause);
      DataSet.SQL.Assign(CmdText);
    finally
      DataSet.Open;
    end;
  finally
    CmdText.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  NDBGrid1.TitleFont.Color := ColorBox1.Selected;
  DBGrid1.TitleFont.Color := ColorBox1.Selected;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  NDBGrid1.FixedColor := ColorBox2.Selected;
  DBGrid1.FixedColor := ColorBox2.Selected;
end;

procedure TForm1.NDBGrid1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if (not NDBGrid1.Sizing(X, Y)) and (ssLeft in Shift) then
    NDBGrid1.BeginDrag(False);
end;

procedure TForm1.DBGrid1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
end;

end.
