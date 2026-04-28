unit NDBGrid;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  System.Generics.Collections,
  Vcl.Controls, Vcl.Graphics, Vcl.Forms, Vcl.ImgList, Vcl.Themes,
  Vcl.Grids, Vcl.DBGrids,
  Data.DB;

{$R EnhDbGridRunPkg_resources.res}

type
  TNColumnTitle = class;

  TNColumn = class(TColumn)
  private
    function GetColumnTitle: TNColumnTitle;
  protected
    function CreateTitle: TColumnTitle; override;
  public
    constructor Create(Collection: TCollection); override;
    property BtnColumnTitle: TNColumnTitle read GetColumnTitle;
  end;

  TNColumnTitle = class(TColumnTitle)
  private
    FSortLevel: Integer;
    FSortDesc: Boolean;
    procedure SetSortLevel(Val: Integer);
    procedure SetSortDesc(Val: Boolean);
  public
    constructor Create(Column: TNColumn); reintroduce;
    procedure Assign(Source: TPersistent); override;
    procedure ResetAttributes;
  published
    property SortLevel: Integer read FSortLevel write SetSortLevel default -1;
    property SortDesc: Boolean read FSortDesc write SetSortDesc default False;
  end;

  TCustomNDBGrid = class;

  TNDBGridColumns = class(TDBGridColumns)
  private
    function GetTNGrid: TCustomNDBGrid;
    function GetTNColumn(Index: Integer): TNColumn;
    procedure SetTNColumn(Index: Integer; Value: TNColumn);
    function GetNextAvailableSortLevel: Integer;
  public
    constructor Create(Grid: TCustomDBGrid; ColumnClass: TColumnClass);
    procedure ResetTitleAttributes;
    function Add: TNColumn; reintroduce;
    function ColumnByFieldName(const FieldName: string): TNColumn;
    function ColumnByOrigin(const Origin: string): TNColumn;
    function GetColumnSettingsAsBytes: TBytes;
    procedure SetColumnSettingsAsBytes(const Settings: TBytes);
    property TitleBtnGrid: TCustomNDBGrid read GetTNGrid;
    property TitleBtnItems[Index: Integer]: TNColumn read GetTNColumn write SetTNColumn;
    property NextAvailableSortLevel: Integer read GetNextAvailableSortLevel;
  end;

  TNDBGridClickEvent = procedure(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; Column: TNColumn) of object;

  TNDBGridClickingEvent = procedure(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; Column: TNColumn;
    var Cliccable: Boolean) of object;

  TNDBGridDrawTitleEvent = procedure(Sender: TObject; ACol, ARow: Integer;
    const ARect: TRect; AState: TGridDrawState) of object;

  TNDBGridIndicatorState = (nisNone, nisSelected, nisEdit, nisInsert,
    nisMultiSelected, nisMultiSelectedAndCurrentRow);

  TNDBGridDrawIndicatorEvent = procedure(Sender: TObject; ACol, ARow: Integer;
    const ARect: TRect; AState: TGridDrawState;
    IndicatorState: TNDBGridIndicatorState) of object;

  TNDBGridCanEditModifyEvent = procedure(Sender: TObject;
    var CanModify: Boolean) of object;

  TNDBGRIDBeforeAutosetEvent = procedure(Sender: TObject;
    var SaveSettings: Boolean) of object;

  TNDBGRIDBeforeAutoHintEvent = procedure(Sender: TObject;
    var Allow: Boolean) of object;

  TNDBGridCellDblClickLocation = (ncdclDataCell, ncdclIndicator, ncdclTitle);

  TNDBGRIDCellDblClickEvent = procedure(Sender: TObject;
    Location: TNDBGridCellDblClickLocation) of object;

  TCustomNDBGrid = class(TCustomDBGrid)
  private
    FColDown: Integer;
    FRowDown: Integer;
    FSizingActive: Boolean;
    FOnAdvTitleClick: TNDBGridClickEvent;
    FOnDrawTitle: TNDBGridDrawTitleEvent;
    FOnCellDblClick: TNDBGRIDCellDblClickEvent;
    FOnCanEditModify: TNDBGridCanEditModifyEvent;
    FOrderByPrefix: string;
    FTitleBtnAutoSet: Boolean;
    FOnDrawIndicator: TNDBGridDrawIndicatorEvent;
    FOnBeforeAutoSet: TNDBGRIDBeforeAutosetEvent;
    FOnBeforeAutoHint: TNDBGRIDBeforeAutoHintEvent;
    FOnAfterAutoSet: TNotifyEvent;
    FOnAdvTitleClicking: TNDBGridClickingEvent;
    FGridHintWindow: THintWindow;
    FGridCurrentHintCol: Integer;
    FGridCurrentHintRow: Integer;
    FCellAutoHintEnabled: Boolean;
    FTitleHeight: Integer;
    FImgListArrows: TImageList;
    FOnTopLeftChanged: TNotifyEvent;
    procedure CreateArrows;
    procedure AddArrows(ImgList: TImageList; Instance: NativeUInt;
      Color: TColor; OldColor: TColor = clBlack;
      const UpArrowResName: string = 'NTITLE_UP_ARROW_FLAT';
      const DownArrowResName: string = 'NTITLE_DOWN_ARROW_FLAT');
    procedure HdrButton(X, Y: Integer);
    function GetTNColumns: TNDBGridColumns;
    procedure SetTNColumns(const Val: TNDBGridColumns);
    procedure ReadOrderByPrefix(Reader: TReader);
    procedure WriteOrderByPrefix(Writer: TWriter);
    procedure TitleButtonsAutoSet(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer; Column: TNColumn);
    procedure DoDrawIndicator(ACol, ARow: Integer; const ARect: TRect;
      AState: TGridDrawState);
    procedure DoDrawTitle(ACol, ARow: Integer; const ARect: TRect;
      AState: TGridDrawState);
    function RowIsMultiSelected: Boolean;
    procedure ClearGridHintWindow;
    procedure SetTitleHeight(Val: Integer);
    procedure ShowAutoHintIfNeeded(X, Y: Integer);
    procedure WriteTextEx(ACanvas: TCanvas; const ARect: TRect;
      DX, DY: Integer; const Text: string; Alignment: TAlignment;
      ARightToLeft: Boolean);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure DblClick; override;
    procedure DrawCell(ACol, ARow: Integer; ARect: TRect;
      AState: TGridDrawState); override;
    procedure KeyPress(var Key: Char); override;
    function CanEditModify: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure TopLeftChanged; override;
    function SelectCell(ACol, ARow: Integer): Boolean; override;
    procedure LinkActive(Value: Boolean); override;
    procedure LayoutChanged; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure WndProc(var Message: TMessage); override;
    procedure SetColumnAttributes; override;
    procedure Scroll(Distance: Integer); override;

    property OnAdvTitleClick: TNDBGridClickEvent
      read FOnAdvTitleClick write FOnAdvTitleClick;
    property OnCanEditModify: TNDBGridCanEditModifyEvent
      read FOnCanEditModify write FOnCanEditModify;
    property OrderByPrefix: string read FOrderByPrefix write FOrderByPrefix;
    property TitleBtnAutoSet: Boolean
      read FTitleBtnAutoSet write FTitleBtnAutoSet;
    property OnBeforeAutoSet: TNDBGRIDBeforeAutosetEvent
      read FOnBeforeAutoSet write FOnBeforeAutoSet;
    property OnBeforeAutoHint: TNDBGRIDBeforeAutoHintEvent
      read FOnBeforeAutoHint write FOnBeforeAutoHint;
    property OnAfterAutoSet: TNotifyEvent
      read FOnAfterAutoSet write FOnAfterAutoSet;
    property OnAdvTitleClicking: TNDBGridClickingEvent
      read FOnAdvTitleClicking write FOnAdvTitleClicking;
    property CellAutoHintEnabled: Boolean
      read FCellAutoHintEnabled write FCellAutoHintEnabled;
    property TitleHeight: Integer read FTitleHeight write SetTitleHeight;
    property OnDrawIndicator: TNDBGridDrawIndicatorEvent
      read FOnDrawIndicator write FOnDrawIndicator;
    property OnDrawTitle: TNDBGridDrawTitleEvent
      read FOnDrawTitle write FOnDrawTitle;
    property OnCellDblClick: TNDBGRIDCellDblClickEvent
      read FOnCellDblClick write FOnCellDblClick;
    property OnTopLeftChanged: TNotifyEvent
      read FOnTopLeftChanged write FOnTopLeftChanged;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure NormalizeColumnIndexes;
    function GetOrderByClause: string;
    procedure RefreshDataset(DataSet: TDataSet = nil);
    function CreateColumns: TDBGridColumns; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure CheckColumnsConsistency;
    procedure DefaultDrawCell(ACol, ARow: Integer; const ARect: TRect;
      AState: TGridDrawState);
    procedure DrawTitleCell(ACol, ARow: Integer; const Rect: TRect;
      Column: TColumn; AState: TGridDrawState);
    property TitleBtnColumns: TNDBGridColumns
      read GetTNColumns write SetTNColumns;
  end;

  TNDBGridSaveSettings = class
  private
    FGrid: TCustomNDBGrid;
    FColumns: TBytes;
    FLeftCol: Integer;
    FFixedCols: Integer;
  public
    constructor Create(Grid: TCustomNDBGrid);
    destructor Destroy; override;
  end;

  TNDBGrid = class(TCustomNDBGrid)
  public
    constructor Create(AOwner: TComponent); override;
    function RawToDataColumn(ACol: Integer): Integer; reintroduce;
    function DataToRawColumn(ACol: Integer): Integer; reintroduce;
    function Sizing(X, Y: Integer): Boolean; reintroduce;
    property Canvas;
    property SelectedRows;
    property TitleBtnColumns;
    property InplaceEditor;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property CellAutoHintEnabled;
    property Columns;
    property Constraints;
    property Ctl3D;
    property DataSource;
    property DefaultDrawing;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FixedColor default clBtnFace;
    property FixedCols;
    property Font;
    property ImeMode;
    property ImeName;
    property LeftCol;
    property OnAdvTitleClick;
    property OnAdvTitleClicking;
    property OnAfterAutoSet;
    property OnBeforeAutoSet;
    property OnBeforeAutoHint;
    property OnCanEditModify;
    property OnCellClick;
    property OnCellDblClick;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawColumnCell;
    property OnDrawDataCell;
    property OnDrawIndicator;
    property OnDrawTitle;
    property OnEditButtonClick;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;
    property OnTopLeftChanged;
    property Options;
    property OrderByPrefix stored False;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TitleBtnAutoSet;
    property TitleFont;
    property TitleHeight default 0;
    property Visible;
  end;

implementation

uses
  ColTitleAttrs;

type
  TNDBGridCellHintWindow = class(THintWindow)
  private
    FAlignment: TAlignment;
    FDisplayText: string;
    FTextOffsetY: Integer;
  public
    procedure ActivateCellHint(const CellScreenRect: TRect;
      const Text: string; AFont: TFont; AColor: TColor;
      Alignment: TAlignment);
    procedure Paint; override;
  end;

const
  ORDER_BY_PREFIX_DEF = 'order by ';

{ TNDBGridCellHintWindow }

procedure TNDBGridCellHintWindow.ActivateCellHint(const CellScreenRect: TRect;
  const Text: string; AFont: TFont; AColor: TColor; Alignment: TAlignment);
const
  CELL_TEXT_MARGIN = 2;
var
  HintRect: TRect;
  HintWidth: Integer;
begin
  FDisplayText := Text;
  FAlignment := Alignment;
  Color := AColor;
  Canvas.Font.Assign(AFont);
  Font.Assign(AFont);

  HintRect := CellScreenRect;
  OffsetRect(HintRect, 0, -2);
  FTextOffsetY := CELL_TEXT_MARGIN + 1;
  HintWidth := Canvas.TextWidth(Text) + (CELL_TEXT_MARGIN * 2) + 1;
  HintWidth := Max(HintWidth, CellScreenRect.Right - CellScreenRect.Left);

  case Alignment of
    taRightJustify:
      HintRect.Left := CellScreenRect.Right - HintWidth;
    taCenter:
      begin
        HintRect.Left := CellScreenRect.Left -
          ((HintWidth - (CellScreenRect.Right - CellScreenRect.Left)) div 2);
        HintRect.Right := HintRect.Left + HintWidth;
      end;
  else
    HintRect.Right := HintRect.Left + HintWidth;
  end;

  ActivateHint(HintRect, Text);
end;

procedure TNDBGridCellHintWindow.Paint;
const
  CELL_TEXT_MARGIN = 2;
var
  TextRect: TRect;
  TextLeft: Integer;
begin
  Canvas.Font.Assign(Font);
  Canvas.Brush.Color := Color;
  Canvas.FillRect(ClientRect);

  TextRect := ClientRect;
  InflateRect(TextRect, -CELL_TEXT_MARGIN, 0);

  case FAlignment of
    taRightJustify:
      TextLeft := TextRect.Right - Canvas.TextWidth(FDisplayText) - 1;
    taCenter:
      TextLeft := TextRect.Left +
        ((TextRect.Right - TextRect.Left) - Canvas.TextWidth(FDisplayText)) div 2;
  else
    TextLeft := TextRect.Left;
  end;

  Canvas.TextRect(ClientRect, TextLeft, FTextOffsetY, FDisplayText);
  Canvas.Brush.Style := bsClear;
  try
    Canvas.Pen.Color := clBtnShadow;
    Canvas.Rectangle(ClientRect);
  finally
    Canvas.Brush.Style := bsSolid;
  end;
end;

{ TNColumn }

constructor TNColumn.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

function TNColumn.CreateTitle: TColumnTitle;
begin
  Result := TNColumnTitle.Create(Self);
end;

function TNColumn.GetColumnTitle: TNColumnTitle;
begin
  if Title is TNColumnTitle then
    Result := TNColumnTitle(Title)
  else
    Result := nil;
end;

{ TNColumnTitle }

constructor TNColumnTitle.Create(Column: TNColumn);
begin
  inherited Create(Column);
  FSortLevel := -1;
  FSortDesc := False;
end;

procedure TNColumnTitle.ResetAttributes;
begin
  FSortLevel := -1;
  FSortDesc := False;
  if Column.Grid is TCustomNDBGrid then
    TCustomNDBGrid(Column.Grid).InvalidateTitles;
end;

procedure TNColumnTitle.SetSortLevel(Val: Integer);
begin
  if Val <> FSortLevel then
  begin
    FSortLevel := Val;
    if Column.Grid is TCustomNDBGrid then
      TCustomNDBGrid(Column.Grid).InvalidateTitles;
  end;
end;

procedure TNColumnTitle.SetSortDesc(Val: Boolean);
begin
  if Val <> FSortDesc then
  begin
    FSortDesc := Val;
    if Column.Grid is TCustomNDBGrid then
      TCustomNDBGrid(Column.Grid).InvalidateTitles;
  end;
end;

procedure TNColumnTitle.Assign(Source: TPersistent);
begin
  if Source is TNColumnTitle then
  begin
    SortLevel := TNColumnTitle(Source).FSortLevel;
    SortDesc := TNColumnTitle(Source).FSortDesc;
  end;
  inherited Assign(Source);
end;

{ TNDBGridColumns }

constructor TNDBGridColumns.Create(Grid: TCustomDBGrid; ColumnClass: TColumnClass);
begin
  inherited Create(Grid, ColumnClass);
end;

function TNDBGridColumns.Add: TNColumn;
begin
  Result := TNColumn(inherited Add);
end;

function TNDBGridColumns.GetTNGrid: TCustomNDBGrid;
begin
  Result := TCustomNDBGrid(Grid);
end;

function TNDBGridColumns.GetTNColumn(Index: Integer): TNColumn;
begin
  Result := TNColumn(Items[Index]);
end;

procedure TNDBGridColumns.SetTNColumn(Index: Integer; Value: TNColumn);
begin
  Items[Index] := Value;
end;

procedure TNDBGridColumns.ResetTitleAttributes;
var
  Idx: Integer;
begin
  for Idx := 0 to Count - 1 do
    TitleBtnItems[Idx].BtnColumnTitle.ResetAttributes;
end;

function TNDBGridColumns.ColumnByFieldName(const FieldName: string): TNColumn;
var
  Idx: Integer;
  Column: TNColumn;
begin
  for Idx := 0 to Count - 1 do
  begin
    Column := TitleBtnItems[Idx];
    if SameText(FieldName, Column.FieldName) then
      Exit(Column);
  end;
  Result := nil;
end;

function TNDBGridColumns.ColumnByOrigin(const Origin: string): TNColumn;
var
  Idx: Integer;
  Column: TNColumn;
begin
  for Idx := 0 to Count - 1 do
  begin
    Column := TitleBtnItems[Idx];
    if (Column.Field <> nil) and SameText(Origin, Column.Field.Origin) then
      Exit(Column);
  end;
  Result := nil;
end;

function TNDBGridColumns.GetNextAvailableSortLevel: Integer;
var
  Idx, SortLevel, ColumnIndex: Integer;
begin
  ColumnIndex := -1;
  for Idx := 0 to Count - 1 do
  begin
    SortLevel := TitleBtnItems[Idx].BtnColumnTitle.SortLevel;
    if SortLevel > ColumnIndex then
      ColumnIndex := SortLevel;
  end;
  Result := ColumnIndex + 1;
end;

function TNDBGridColumns.GetColumnSettingsAsBytes: TBytes;
var
  MS: TMemoryStream;
begin
  MS := TMemoryStream.Create;
  try
    SaveToStream(MS);
    SetLength(Result, MS.Size);
    if MS.Size > 0 then
      Move(MS.Memory^, Result[0], MS.Size);
  finally
    MS.Free;
  end;
end;

procedure TNDBGridColumns.SetColumnSettingsAsBytes(const Settings: TBytes);
var
  MS: TMemoryStream;
begin
  MS := TMemoryStream.Create;
  try
    if Length(Settings) > 0 then
      MS.WriteBuffer(Settings[0], Length(Settings));
    MS.Position := 0;
    LoadFromStream(MS);
  finally
    MS.Free;
  end;
end;

{ TCustomNDBGrid }

constructor TCustomNDBGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColDown := -1;
  FRowDown := -1;
  FOrderByPrefix := ORDER_BY_PREFIX_DEF;
  FTitleHeight := 0;
  FSizingActive := False;
  CreateArrows;
  ClearGridHintWindow;
end;

destructor TCustomNDBGrid.Destroy;
begin
  FreeAndNil(FImgListArrows);
  FreeAndNil(FGridHintWindow);
  inherited Destroy;
end;

procedure TCustomNDBGrid.CreateArrows;
var
  Bmp: TBitmap;
  LDetails: TThemedElementDetails;
  Color: TColor;
  H: NativeUInt;
begin
  FreeAndNil(FImgListArrows);
  FImgListArrows := TImageList.Create(nil);
  H := HInstance;

  Bmp := TBitmap.Create;
  try
    Bmp.LoadFromResourceName(H, 'NTITLE_UP_ARROW');
    FImgListArrows.Width := Bmp.Width;
    FImgListArrows.Height := Bmp.Height;
    FImgListArrows.AddMasked(Bmp, clLtGray);
    Bmp.LoadFromResourceName(H, 'NTITLE_DOWN_ARROW');
    FImgListArrows.AddMasked(Bmp, clLtGray);
  finally
    Bmp.Free;
  end;

  if StyleServices.Enabled then
  begin
    if StyleServices.IsSystemStyle then
    begin
      AddArrows(FImgListArrows, H, TColor(ColorToRGB(TitleFont.Color)));
    end
    else
    begin
      LDetails := StyleServices.GetElementDetails(tgFixedCellNormal);
      StyleServices.GetElementColor(LDetails, ecTextColor, Color);
      AddArrows(FImgListArrows, H, Color);

      LDetails := StyleServices.GetElementDetails(tgFixedCellHot);
      StyleServices.GetElementColor(LDetails, ecTextColor, Color);
      AddArrows(FImgListArrows, H, Color);

      LDetails := StyleServices.GetElementDetails(tgFixedCellPressed);
      StyleServices.GetElementColor(LDetails, ecTextColor, Color);
      AddArrows(FImgListArrows, H, Color);
    end;
  end;
end;

procedure TCustomNDBGrid.AddArrows(ImgList: TImageList; Instance: NativeUInt;
  Color: TColor; OldColor: TColor;
  const UpArrowResName: string; const DownArrowResName: string);
var
  Bmp: TBitmap;
begin
  Bmp := TBitmap.Create;
  try
    Bmp.Handle := CreateMappedRes(THandle(Instance), PChar(UpArrowResName),
      [OldColor], [Color]);
    ImgList.AddMasked(Bmp, Bmp.TransparentColor);
    Bmp.Handle := CreateMappedRes(THandle(Instance), PChar(DownArrowResName),
      [OldColor], [Color]);
    ImgList.AddMasked(Bmp, Bmp.TransparentColor);
  finally
    Bmp.Free;
  end;
end;

function TCustomNDBGrid.RowIsMultiSelected: Boolean;
var
  Idx: Integer;
begin
  Result := (dgMultiSelect in Options) and DataLink.Active and
    SelectedRows.Find(DataLink.DataSource.DataSet.Bookmark, Idx);
end;

procedure TCustomNDBGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  MC: TGridCoord;
  FirstDataCol: Integer;
  Column: TNColumn;
  Cliccable: Boolean;
begin
  if Button = mbLeft then
  begin
    MC := MouseCoord(X, Y);
    FSizingActive := Sizing(X, Y);
    if not FSizingActive then
    begin
      FirstDataCol := DataToRawColumn(0);
      if MC.X >= FirstDataCol then
        Column := TitleBtnColumns.TitleBtnItems[MC.X - FirstDataCol]
      else
        Column := nil;
      Cliccable := True;
      if Assigned(FOnAdvTitleClicking) then
        FOnAdvTitleClicking(Self, Button, Shift, X, Y, Column, Cliccable);
      if Cliccable then
        HdrButton(MC.X, MC.Y)
      else
      begin
        HdrButton(-1, -1);
        Exit;
      end;
    end
    else
      HdrButton(-1, -1);
  end
  else
    HdrButton(-1, -1);
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TCustomNDBGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  FirstDataCol: Integer;
  MC: TGridCoord;
  Column: TNColumn;
  SaveSettings: Boolean;
  Snapshot: TNDBGridSaveSettings;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    FirstDataCol := DataToRawColumn(0);
    if (FColDown >= 0) or (FRowDown >= 0) then
    begin
      MC := MouseCoord(X, Y);
      if (MC.X = FColDown) and (MC.Y = 0) and (Y >= 0) then
      begin
        if MC.X >= FirstDataCol then
          Column := TitleBtnColumns.TitleBtnItems[MC.X - FirstDataCol]
        else
          Column := nil;
        if (not FSizingActive) and (Column <> nil) then
        begin
          if Assigned(FOnAdvTitleClick) then
            FOnAdvTitleClick(Self, Button, Shift, X, Y, Column)
          else if FTitleBtnAutoSet then
          begin
            SaveSettings := True;
            if Assigned(FOnBeforeAutoSet) then
              FOnBeforeAutoSet(Self, SaveSettings);
            TitleButtonsAutoSet(Button, Shift, X, Y, Column);
            Snapshot := nil;
            try
              if SaveSettings then
                Snapshot := TNDBGridSaveSettings.Create(Self);
              if Assigned(FOnAfterAutoSet) then
                FOnAfterAutoSet(Self);
            finally
              Snapshot.Free;
            end;
          end;
        end;
      end;
    end;
  end;
  HdrButton(-1, -1);
  FSizingActive := False;
end;

procedure TCustomNDBGrid.DblClick;
var
  Coord: TGridCoord;
  Where: TNDBGridCellDblClickLocation;
begin
  inherited DblClick;
  Coord := MouseCoord(HitTest.X, HitTest.Y);
  if (Coord.X >= 0) and (Coord.Y >= 0) then
  begin
    if (dgTitles in Options) and (Coord.Y = 0) then
      Where := ncdclTitle
    else if (dgIndicator in Options) and (Coord.X = 0) then
      Where := ncdclIndicator
    else
      Where := ncdclDataCell;
    if Assigned(FOnCellDblClick) then
      FOnCellDblClick(Self, Where);
  end;
end;

procedure TCustomNDBGrid.HdrButton(X, Y: Integer);
begin
  if (FColDown >= 0) or (FRowDown >= 0) then
    InvalidateCell(FColDown, FRowDown);
  if dgTitles in Options then
  begin
    FColDown := X;
    FRowDown := Y;
  end
  else
  begin
    FColDown := -1;
    FRowDown := -1;
  end;
end;

function TCustomNDBGrid.CreateColumns: TDBGridColumns;
begin
  Result := TNDBGridColumns.Create(Self, TNColumn);
end;

function TCustomNDBGrid.GetTNColumns: TNDBGridColumns;
begin
  if Columns is TNDBGridColumns then
    Result := TNDBGridColumns(Columns)
  else
    Result := nil;
end;

procedure TCustomNDBGrid.SetTNColumns(const Val: TNDBGridColumns);
begin
  Columns := Val;
end;

procedure TCustomNDBGrid.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if (Key <> #0) and (Ord(Key) = VK_ESCAPE) and ((FColDown >= 0) or (FRowDown >= 0)) then
    HdrButton(-1, -1);
  ClearGridHintWindow;
end;

function TCustomNDBGrid.CanEditModify: Boolean;
begin
  Result := inherited CanEditModify;
  if Assigned(FOnCanEditModify) then
    FOnCanEditModify(Self, Result);
end;

procedure TCustomNDBGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  ClearGridHintWindow;
end;

procedure TCustomNDBGrid.NormalizeColumnIndexes;
var
  Cols: TNDBGridColumns;
  Attrs: TColumnTitleAttrsCont;
  Idx, Level: Integer;
  FieldName: string;
  Column: TNColumn;
  Title: TNColumnTitle;
begin
  Cols := TitleBtnColumns;
  Attrs := TColumnTitleAttrsCont.Create(Cols);
  try
    Level := 0;
    for Idx := 0 to Attrs.Count - 1 do
    begin
      FieldName := Attrs[Idx].FieldName;
      Column := Cols.ColumnByFieldName(FieldName);
      if Column <> nil then
      begin
        Title := Column.BtnColumnTitle;
        Title.SortLevel := Level;
        Inc(Level);
      end
      else
      begin
        Column := Cols.ColumnByOrigin(FieldName);
        if Column <> nil then
        begin
          Title := Column.BtnColumnTitle;
          Title.SortLevel := Level;
          Inc(Level);
        end;
      end;
    end;
  finally
    Attrs.Free;
  end;
end;

function TCustomNDBGrid.GetOrderByClause: string;
var
  Cols: TNDBGridColumns;
  Attrs: TColumnTitleAttrsCont;
  Idx: Integer;
  OrderByPre: string;
begin
  Result := '';
  Cols := TitleBtnColumns;
  Attrs := TColumnTitleAttrsCont.Create(Cols);
  try
    for Idx := 0 to Attrs.Count - 1 do
    begin
      if Result <> '' then
        Result := Result + ', ';
      Result := Result + Attrs[Idx].FieldName;
      if Attrs[Idx].Descending then
        Result := Result + ' desc';
    end;
    if Result <> '' then
    begin
      OrderByPre := Trim(FOrderByPrefix);
      if OrderByPre <> '' then
        OrderByPre := OrderByPre + ' ';
      Result := OrderByPre + Result;
    end;
  finally
    Attrs.Free;
  end;
end;

procedure TCustomNDBGrid.RefreshDataset(DataSet: TDataSet);
var
  Snapshot: TNDBGridSaveSettings;
begin
  if DataSet = nil then
  begin
    if DataSource <> nil then
    begin
      DataSet := DataSource.DataSet;
      DataSet.Close;
      DataSet.Open;
    end;
  end
  else if DataSet.Active then
  begin
    Snapshot := TNDBGridSaveSettings.Create(Self);
    try
      DataSet.Close;
      DataSet.Open;
    finally
      Snapshot.Free;
    end;
  end;
end;

procedure TCustomNDBGrid.ReadOrderByPrefix(Reader: TReader);
begin
  FOrderByPrefix := Reader.ReadString;
end;

procedure TCustomNDBGrid.WriteOrderByPrefix(Writer: TWriter);
begin
  Writer.WriteString(FOrderByPrefix);
end;

procedure TCustomNDBGrid.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('OrderByPrefix',
    ReadOrderByPrefix, WriteOrderByPrefix,
    FOrderByPrefix <> ORDER_BY_PREFIX_DEF);
end;

procedure TCustomNDBGrid.TitleButtonsAutoSet(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Column: TNColumn);
var
  Title: TNColumnTitle;
begin
  if ssAlt in Shift then
    TitleBtnColumns.ResetTitleAttributes
  else
  begin
    Title := Column.BtnColumnTitle;
    if Title.SortLevel >= 0 then
      Title.SortDesc := not Title.SortDesc
    else
    begin
      if ssCtrl in Shift then
        Title.SortLevel := TitleBtnColumns.NextAvailableSortLevel
      else
      begin
        TitleBtnColumns.ResetTitleAttributes;
        Title.SortLevel := 0;
      end;
    end;
  end;
  NormalizeColumnIndexes;
end;

procedure TCustomNDBGrid.TopLeftChanged;
begin
  if LeftCol < FixedCols then
    LeftCol := FixedCols;
  inherited TopLeftChanged;
  if Assigned(FOnTopLeftChanged) then
    FOnTopLeftChanged(Self);
end;

procedure TCustomNDBGrid.LinkActive(Value: Boolean);
begin
  inherited LinkActive(Value);
  if Value then
    CheckColumnsConsistency;
end;

procedure TCustomNDBGrid.CheckColumnsConsistency;
var
  DataSet: TDataSet;
  FieldCount, ColumnCount, Idx: Integer;
  FieldList, ColumnList: TArray<string>;
  AllMatch: Boolean;
begin
  if DataSource = nil then
    Exit;
  DataSet := DataSource.DataSet;
  if DataSet <> nil then
  begin
    FieldCount := DataSet.Fields.Count;
    ColumnCount := TitleBtnColumns.Count;
    if ColumnCount = FieldCount then
    begin
      SetLength(FieldList, FieldCount);
      SetLength(ColumnList, FieldCount);
      for Idx := 0 to FieldCount - 1 do
      begin
        FieldList[Idx] := DataSet.Fields[Idx].FieldName;
        ColumnList[Idx] := TitleBtnColumns.Items[Idx].FieldName;
      end;
      TArray.Sort<string>(FieldList);
      TArray.Sort<string>(ColumnList);
      AllMatch := True;
      for Idx := 0 to FieldCount - 1 do
        if not SameText(FieldList[Idx], ColumnList[Idx]) then
        begin
          AllMatch := False;
          Break;
        end;
      if AllMatch then
        Exit;
    end;
  end;
  TitleBtnColumns.Clear;
end;

procedure TCustomNDBGrid.ClearGridHintWindow;
begin
  FreeAndNil(FGridHintWindow);
  FGridCurrentHintCol := -1;
  FGridCurrentHintRow := -1;
end;

procedure TCustomNDBGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  ShowAutoHintIfNeeded(X, Y);
end;

procedure TCustomNDBGrid.ShowAutoHintIfNeeded(X, Y: Integer);
var
  FirstDataCol, ACol, ARow, OldActive: Integer;
  TextWidth: Integer;
  MC: TGridCoord;
  Column: TColumn;
  DisplayText: string;
  CRect: TRect;
  HintFont: TFont;
  OldFont: TFont;
  CellScreenPos: TPoint;
  CellScreenRect: TRect;
  ActivateAutoHint: Boolean;
begin
  if FCellAutoHintEnabled and MouseInClient and
    PtInRect(ClientRect, Point(X, Y)) then
  begin
    FirstDataCol := DataToRawColumn(0);
    MC := MouseCoord(X, Y);
    ACol := MC.X - FirstDataCol;
    ARow := MC.Y - 1;

    if DataLink.Active then
    begin
      if (ARow >= 0) and (ACol >= 0) then
      begin
        Column := Columns.Items[ACol];

        OldActive := DataLink.ActiveRecord;
        try
          DataLink.ActiveRecord := ARow;

          if Column.Field <> nil then
          begin
            if (FGridCurrentHintCol <> MC.X) or (FGridCurrentHintRow <> MC.Y) then
              ClearGridHintWindow;
            DisplayText := Column.Field.DisplayText;
            CRect := CellRect(MC.X, MC.Y);
            HintFont := TFont.Create;
            try
              OldFont := TFont.Create;
              try
                OldFont.Assign(Canvas.Font);
                Canvas.Font.Assign(Self.Font);
                if Column.Font <> nil then
                  Canvas.Font.Assign(Column.Font);
                HintFont.Assign(Canvas.Font);
                TextWidth := Canvas.TextWidth(DisplayText);
                Canvas.Font.Assign(OldFont);
              finally
                OldFont.Free;
              end;
              if TextWidth > (CRect.Right - CRect.Left) then
              begin
                if FGridHintWindow = nil then
                begin
                  FGridHintWindow := TNDBGridCellHintWindow.Create(nil);
                  CellScreenPos := ClientToScreen(Point(CRect.Left, CRect.Top));
                  CellScreenRect := Rect(CellScreenPos.X, CellScreenPos.Y,
                    CellScreenPos.X + (CRect.Right - CRect.Left),
                    CellScreenPos.Y + (CRect.Bottom - CRect.Top));
                  ActivateAutoHint := True;
                  if Assigned(FOnBeforeAutoHint) then
                    FOnBeforeAutoHint(Self, ActivateAutoHint);
                  if ActivateAutoHint then
                    TNDBGridCellHintWindow(FGridHintWindow).ActivateCellHint(
                      CellScreenRect, DisplayText, HintFont, Color,
                      Column.Alignment);
                  FGridCurrentHintCol := MC.X;
                  FGridCurrentHintRow := MC.Y;
                end;
              end;
            finally
              HintFont.Free;
            end;
          end;
        finally
          DataLink.ActiveRecord := OldActive;
        end;
      end
      else
        ClearGridHintWindow;
    end;
  end;
end;

procedure TCustomNDBGrid.SetColumnAttributes;
begin
  if (FTitleHeight <> 0) and (FixedRows > 0) then
    RowHeights[0] := Max(FTitleHeight, RowHeights[0]);
  inherited SetColumnAttributes;
end;

procedure TCustomNDBGrid.SetTitleHeight(Val: Integer);
begin
  if FTitleHeight <> Val then
  begin
    FTitleHeight := Val;
    BeginLayout;
    EndLayout;
  end;
end;

procedure TCustomNDBGrid.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    CM_MOUSELEAVE:
      ClearGridHintWindow;
    CM_STYLECHANGED:
      if (dgTitles in Options) and StyleServices.Enabled then
      begin
        CreateArrows;
        Invalidate;
      end;
  end;
end;

procedure TCustomNDBGrid.LayoutChanged;
begin
  if (dgTitles in Options) and StyleServices.Enabled then
    CreateArrows;
  inherited LayoutChanged;
end;

function TCustomNDBGrid.SelectCell(ACol, ARow: Integer): Boolean;
var
  CursorPos: TPoint;
  MC: TGridCoord;
begin
  CursorPos := ScreenToClient(Mouse.CursorPos);
  MC := MouseCoord(CursorPos.X, CursorPos.Y);
  if (FGridCurrentHintCol <> MC.X) or (FGridCurrentHintRow <> MC.Y) then
    ClearGridHintWindow;
  ShowAutoHintIfNeeded(CursorPos.X, CursorPos.Y);
  Result := inherited SelectCell(ACol, ARow);
end;

procedure TCustomNDBGrid.Scroll(Distance: Integer);
var
  CursorPos: TPoint;
begin
  if Distance <> 0 then
    ClearGridHintWindow;
  CursorPos := ScreenToClient(Mouse.CursorPos);
  ShowAutoHintIfNeeded(CursorPos.X, CursorPos.Y);
  inherited Scroll(Distance);
end;

procedure TCustomNDBGrid.DoDrawIndicator(ACol, ARow: Integer;
  const ARect: TRect; AState: TGridDrawState);
var
  IndicatorState: TNDBGridIndicatorState;
  FirstDataRow, OldActive: Integer;
  MultiSelected: Boolean;
begin
  if Assigned(FOnDrawIndicator) then
  begin
    IndicatorState := nisNone;
    if dgTitles in Options then
      FirstDataRow := 1
    else
      FirstDataRow := 0;
    if (DataLink <> nil) and DataLink.Active then
    begin
      MultiSelected := False;
      if ARow - FirstDataRow >= 0 then
      begin
        OldActive := DataLink.ActiveRecord;
        try
          DataLink.ActiveRecord := ARow - FirstDataRow;
          MultiSelected := RowIsMultiSelected;
        finally
          DataLink.ActiveRecord := OldActive;
        end;
      end;
      if ((ARow - FirstDataRow) = DataLink.ActiveRecord) or MultiSelected then
      begin
        IndicatorState := nisSelected;
        if DataLink.DataSet <> nil then
        begin
          case DataLink.DataSet.State of
            dsEdit: IndicatorState := nisEdit;
            dsInsert: IndicatorState := nisInsert;
            dsBrowse:
              if MultiSelected then
              begin
                if (ARow - FirstDataRow) <> DataLink.ActiveRecord then
                  IndicatorState := nisMultiSelected
                else
                  IndicatorState := nisMultiSelectedAndCurrentRow;
              end
              else
              begin
                if (ARow - FirstDataRow) <> DataLink.ActiveRecord then
                  IndicatorState := nisNone
                else
                  IndicatorState := nisSelected;
              end;
          end;
        end;
      end;
    end;
    FOnDrawIndicator(Self, ACol, ARow, ARect, AState, IndicatorState);
  end
  else
    inherited DrawCell(ACol, ARow, ARect, AState);
end;

procedure TCustomNDBGrid.DefaultDrawCell(ACol, ARow: Integer;
  const ARect: TRect; AState: TGridDrawState);
begin
  inherited DrawCell(ACol, ARow, ARect, AState);
end;

procedure TCustomNDBGrid.DoDrawTitle(ACol, ARow: Integer; const ARect: TRect;
  AState: TGridDrawState);
var
  ColIndex: Integer;
begin
  if Assigned(FOnDrawTitle) then
    FOnDrawTitle(Self, ACol, ARow, ARect, AState)
  else
  begin
    if dgIndicator in Options then
      ColIndex := ACol - 1
    else
      ColIndex := ACol;
    if (ColIndex >= 0) and (ColIndex < Columns.Count) then
      DrawTitleCell(ACol, ARow, ARect, Columns.Items[ColIndex], AState)
    else
      inherited DrawCell(ACol, ARow, ARect, AState);
  end;
end;

procedure TCustomNDBGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
begin
  if (dgTitles in Options) and (ARow = 0) then
    DoDrawTitle(ACol, ARow, ARect, AState)
  else if (dgIndicator in Options) and (ACol = 0) then
    DoDrawIndicator(ACol, ARow, ARect, AState)
  else
    inherited DrawCell(ACol, ARow, ARect, AState);
end;

procedure TCustomNDBGrid.WriteTextEx(ACanvas: TCanvas; const ARect: TRect;
  DX, DY: Integer; const Text: string; Alignment: TAlignment;
  ARightToLeft: Boolean);
const
  AlignFlags: array[TAlignment] of Integer = (
    DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
    DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
    DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX);
  RTL: array[Boolean] of Integer = (0, DT_RTLREADING);
var
  TARect: TRect;
  I: TColorRef;
  LeftPos, Hold: Integer;
  DrawBitmap: TBitmap;
  R, B: TRect;
  DBCanvas: TCanvas;
begin
  TARect := ARect;
  I := ColorToRGB(ACanvas.Brush.Color);
  if GetNearestColor(ACanvas.Handle, I) = I then
  begin
    if (ACanvas.CanvasOrientation = coRightToLeft) and (not ARightToLeft) then
      ChangeBiDiModeAlignment(Alignment);
    case Alignment of
      taLeftJustify:
        LeftPos := TARect.Left + DX;
      taRightJustify:
        LeftPos := TARect.Right - ACanvas.TextWidth(Text) - 3;
    else
      LeftPos := TARect.Left + (TARect.Right - TARect.Left) div 2 -
        ACanvas.TextWidth(Text) div 2;
    end;
    ACanvas.TextRect(TARect, LeftPos, TARect.Top + DY, Text);
  end
  else
  begin
    DrawBitmap := TBitmap.Create;
    try
      DrawBitmap.Width := TARect.Right - TARect.Left;
      DrawBitmap.Height := TARect.Bottom - TARect.Top;
      R := Rect(DX, DY, TARect.Right - TARect.Left - 1,
        TARect.Bottom - TARect.Top - 1);
      B := Rect(0, 0, TARect.Right - TARect.Left,
        TARect.Bottom - TARect.Top);
      DBCanvas := DrawBitmap.Canvas;
      DBCanvas.Font.Assign(ACanvas.Font);
      DBCanvas.Font.Color := ACanvas.Font.Color;
      DBCanvas.Brush.Assign(ACanvas.Brush);
      DBCanvas.Brush.Style := bsSolid;
      DBCanvas.FillRect(B);
      SetBkMode(DBCanvas.Handle, TRANSPARENT);
      if ACanvas.CanvasOrientation = coRightToLeft then
        ChangeBiDiModeAlignment(Alignment);
      DrawText(DBCanvas.Handle, PChar(Text), Length(Text), R,
        AlignFlags[Alignment] or RTL[ARightToLeft]);
      if ACanvas.CanvasOrientation = coRightToLeft then
      begin
        Hold := TARect.Left;
        TARect.Left := TARect.Right;
        TARect.Right := Hold;
      end;
      ACanvas.CopyRect(TARect, DrawBitmap.Canvas, B);
    finally
      DrawBitmap.Free;
    end;
  end;
end;

procedure TCustomNDBGrid.DrawTitleCell(ACol, ARow: Integer; const Rect: TRect;
  Column: TColumn; AState: TGridDrawState);
type
  TOrderByIndicator = (obiNone, obiWindowUp, obiWindowDown,
    obiThemedNormalUp, obiThemedNormalDown, obiThemedHotUp, obiThemedHotDown,
    obiThemedPressedUp, obiThemedPressedDown);
const
  ScrollArrows: array[Boolean, Boolean] of Integer = (
    (DFCS_SCROLLRIGHT, DFCS_SCROLLLEFT),
    (DFCS_SCROLLLEFT, DFCS_SCROLLRIGHT));
var
  MasterCol: TColumn;
  ARect: TRect;
  LFrameOffs: Byte;
  TitleRect, TextRect, ButtonRect, SortTextVisibleRect: TRect;
  LinesOpts: TDBGridOptions;
  I, TitleOffset, DeltaTextRect, SortTextWidth, SortTextX, MinSortColCount,
    Idx: Integer;
  InBiDiMode: Boolean;
  NColumn: TNColumn;
  NColumnTitle: TNColumnTitle;
  Down: Boolean;
  OrderByIndicatorValue: TOrderByIndicator;
  SortText: string;
  InternalDrawingStyle: TGridDrawingStyle;
begin
  ARect := Rect;
  LFrameOffs := 2;
  TitleRect := CalcTitleRect(Column, ARow, MasterCol);

  if MasterCol = nil then
  begin
    Canvas.FillRect(ARect);
    Exit;
  end;

  Canvas.Font.Assign(MasterCol.Title.Font);
  Canvas.Brush.Color := MasterCol.Title.Color;

  LinesOpts := [dgRowLines, dgColLines];
  if LinesOpts <= Options then
  begin
    InflateRect(TitleRect, -1, -1);
    if gdFixed in AState then
    begin
      InflateRect(ARect, -1, -1);
      LFrameOffs := 1;
    end;
  end;

  TextRect := TitleRect;
  I := GetSystemMetrics(SM_CXHSCROLL);
  if ((TextRect.Right - TextRect.Left) > I) and MasterCol.Expandable then
  begin
    TextRect.Right := TextRect.Right - I;
    ButtonRect := TitleRect;
    ButtonRect.Left := TextRect.Right;
    I := SaveDC(Canvas.Handle);
    try
      Canvas.FillRect(ButtonRect);
      InflateRect(ButtonRect, -1, -1);
      IntersectClipRect(Canvas.Handle, ButtonRect.Left, ButtonRect.Top,
        ButtonRect.Right, ButtonRect.Bottom);
      InflateRect(ButtonRect, 1, 1);
      InBiDiMode := Canvas.CanvasOrientation = coRightToLeft;
      if InBiDiMode then
        ButtonRect.Right := ButtonRect.Right + GetSystemMetrics(SM_CXHSCROLL) + 4;
      DrawFrameControl(Canvas.Handle, ButtonRect, DFC_SCROLL,
        ScrollArrows[InBiDiMode, MasterCol.Expanded] or DFCS_FLAT);
    finally
      RestoreDC(Canvas.Handle, I);
    end;
  end;

  TitleOffset := 0;
  if dgTitles in Options then
    Inc(TitleOffset);

  DrawCellBackground(TitleRect, FixedColor, AState, ACol, ARow - TitleOffset);

  if gdPressed in AState then
    Inc(LFrameOffs);

  OrderByIndicatorValue := obiNone;
  DeltaTextRect := 0;
  SortText := '';
  SortTextWidth := 0;

  if Column is TNColumn then
  begin
    NColumn := TNColumn(Column);
    NColumnTitle := NColumn.BtnColumnTitle;
    if NColumnTitle <> nil then
    begin
      if NColumnTitle.SortLevel >= 0 then
      begin
        Down := NColumnTitle.SortDesc;
        if StyleServices.Enabled then
        begin
          if StyleServices.IsSystemStyle then
          begin
            if Down then OrderByIndicatorValue := obiThemedNormalDown
            else OrderByIndicatorValue := obiThemedNormalUp;
          end
          else
          begin
            if gdPressed in AState then
            begin
              if Down then OrderByIndicatorValue := obiThemedPressedDown
              else OrderByIndicatorValue := obiThemedPressedUp;
            end
            else if gdHotTrack in AState then
            begin
              if Down then OrderByIndicatorValue := obiThemedHotDown
              else OrderByIndicatorValue := obiThemedHotUp;
            end
            else
            begin
              if Down then OrderByIndicatorValue := obiThemedNormalDown
              else OrderByIndicatorValue := obiThemedNormalUp;
            end;
          end;
        end
        else
        begin
          if Down then OrderByIndicatorValue := obiWindowDown
          else OrderByIndicatorValue := obiWindowUp;
        end;
        if OrderByIndicatorValue <> obiNone then
        begin
          DeltaTextRect := DeltaTextRect + FImgListArrows.Width + 4;
          MinSortColCount := 0;
          for Idx := 0 to TitleBtnColumns.Count - 1 do
          begin
            if TitleBtnColumns.TitleBtnItems[Idx].BtnColumnTitle.SortLevel >= 0 then
            begin
              if MinSortColCount = 0 then
                Inc(MinSortColCount)
              else
              begin
                SortText := IntToStr(NColumnTitle.SortLevel + 1);
                SortTextWidth := Canvas.TextWidth(SortText);
                DeltaTextRect := DeltaTextRect + SortTextWidth;
                Break;
              end;
            end;
          end;
        end;
      end;
    end;
  end;

  if OrderByIndicatorValue <> obiNone then
  begin
    if ((TitleRect.Right - TitleRect.Left) -
        Canvas.TextWidth(MasterCol.Title.Caption)) >= DeltaTextRect + 12 then
      TextRect.Left := TextRect.Left + DeltaTextRect
    else
      OrderByIndicatorValue := obiNone;
  end;

  if (SortTextWidth <> 0) and (OrderByIndicatorValue <> obiNone) then
    TextRect.Left := TextRect.Left + 8;

  WriteTextEx(Canvas, TextRect, LFrameOffs, LFrameOffs,
    MasterCol.Title.Caption, MasterCol.Title.Alignment, IsRightToLeft);

  if OrderByIndicatorValue <> obiNone then
  begin
    FImgListArrows.Draw(Canvas, Rect.Left + 4,
      (Rect.Top + Rect.Bottom - FImgListArrows.Height) div 2 + 1,
      Ord(OrderByIndicatorValue) - 1);
    if SortTextWidth <> 0 then
    begin
      SortTextX := Rect.Left + FImgListArrows.Width + 4;
      if gdPressed in AState then
        Inc(SortTextWidth);
      SortTextVisibleRect.Left := SortTextX;
      SortTextVisibleRect.Top := TextRect.Top;
      SortTextVisibleRect.Right := SortTextX + SortTextWidth + 1;
      SortTextVisibleRect.Bottom := TextRect.Bottom;
      WriteTextEx(Canvas, SortTextVisibleRect, LFrameOffs, LFrameOffs,
        SortText, taLeftJustify, IsRightToLeft);
    end;
  end;

  InternalDrawingStyle := DrawingStyle;
  if (DrawingStyle = gdsThemed) and (not ThemeControl(Self)) then
    InternalDrawingStyle := gdsClassic;

  if (LinesOpts <= Options) and (InternalDrawingStyle = gdsClassic) and
    (not (gdPressed in AState)) then
  begin
    InflateRect(TitleRect, 1, 1);
    if not TStyleManager.IsCustomStyleActive then
    begin
      DrawEdge(Canvas.Handle, TitleRect, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
      DrawEdge(Canvas.Handle, TitleRect, BDR_RAISEDINNER, BF_TOPLEFT);
    end;
  end;
end;

{ TNDBGridSaveSettings }

constructor TNDBGridSaveSettings.Create(Grid: TCustomNDBGrid);
begin
  inherited Create;
  FGrid := Grid;
  FColumns := Grid.TitleBtnColumns.GetColumnSettingsAsBytes;
  FLeftCol := Grid.LeftCol;
  FFixedCols := Grid.FixedCols;
end;

destructor TNDBGridSaveSettings.Destroy;
begin
  FGrid.TitleBtnColumns.SetColumnSettingsAsBytes(FColumns);
  FGrid.FixedCols := FFixedCols;
  FGrid.LeftCol := FLeftCol;
  inherited Destroy;
end;

{ TNDBGrid }

constructor TNDBGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FixedColor := clBtnFace;
end;

function TNDBGrid.RawToDataColumn(ACol: Integer): Integer;
begin
  Result := inherited RawToDataColumn(ACol);
end;

function TNDBGrid.DataToRawColumn(ACol: Integer): Integer;
begin
  Result := inherited DataToRawColumn(ACol);
end;

function TNDBGrid.Sizing(X, Y: Integer): Boolean;
begin
  Result := inherited Sizing(X, Y);
end;

end.
