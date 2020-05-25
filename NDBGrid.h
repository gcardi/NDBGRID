//---------------------------------------------------------------------------

#ifndef NDBGridH
#define NDBGridH
//---------------------------------------------------------------------------

#include <SysUtils.hpp>
#include <Controls.hpp>
#include <Classes.hpp>
#include <Forms.hpp>
#include <VCL.DBGrids.hpp>
#include <Grids.hpp>

#include <memory>

//---------------------------------------------------------------------------

class PACKAGE TNColumnTitle;

class PACKAGE TNColumn : public TColumn
{
private:
    TNColumnTitle* GetColumnTitle();
protected:
    virtual TColumnTitle* __fastcall CreateTitle();
public:
    __fastcall TNColumn( TCollection* Collection );
    __property TNColumnTitle* BtnColumnTitle = { read = GetColumnTitle };
__published:
};
//---------------------------------------------------------------------------

class PACKAGE TNColumnTitle : public TColumnTitle
{
private:
    int sortLevel_;
    bool sortDesc_;

    void __fastcall SetSortLevel( int Val );
    void __fastcall SetSortDesc( bool Val );
protected:
public:
    __fastcall TNColumnTitle( TNColumn* Column );
    virtual void __fastcall Assign( TPersistent* Source );
    void __fastcall ResetAttributes();
__published:
	__property int SortLevel = { read = sortLevel_,
                                 write = SetSortLevel, default = -1 };
    __property bool SortDesc = { read = sortDesc_,
                                 write = SetSortDesc, default = 0 };
};
//---------------------------------------------------------------------------

class PACKAGE TCustomNDBGrid;

class PACKAGE TNDBGridColumns : public TDBGridColumns
{
private:
    TCustomNDBGrid* __fastcall GeTNGrid();
    TNColumn* __fastcall GeTNColumn( int Index );
    void __fastcall SeTNColumn( int Index, TNColumn* Value );
protected:
public:
    __fastcall TNDBGridColumns( TCustomDBGrid* Grid, System::TMetaClass* ColumnClass );
    void ResetTitleAttributes();
    HIDESBASE TNColumn* __fastcall Add();
    __property TCustomNDBGrid* TitleBtnGrid = { read = GeTNGrid };
    __property TNColumn* TitleBtnItems[int Index] = {
        read = GeTNColumn, write= SeTNColumn
    };
    TNColumn* ColumnByFieldName( String FieldName );
    TNColumn* ColumnByOrigin( String Origin );

    AnsiString GetColumnSettings()
    _DEPRECATED_ATTRIBUTE1("Use GetColumnSettingsAsBytes instead");

    void SetColumnSettings( AnsiString Settings )
    _DEPRECATED_ATTRIBUTE1("Use SetColumnSettingsAsBytes instead");

    TBytes GetColumnSettingsAsBytes();
    void SetColumnSettingsAsBytes( TBytes Settings );

    int GetNextAvailableSortLevel();
    __property int NextAvailableSortLevel = { read = GetNextAvailableSortLevel };
};
//---------------------------------------------------------------------------

typedef void __fastcall (__closure *TNDBGridClickEvent)(
                  System::TObject* Sender, TMouseButton Button,
                  Classes::TShiftState Shift, int X, int Y,
                  TNColumn* Column
);

typedef void __fastcall (__closure *TNDBGridClickingEvent)(
                  System::TObject* Sender, TMouseButton Button,
                  Classes::TShiftState Shift, int X, int Y,
                  TNColumn* Column, bool& Cliccable
);

typedef void __fastcall (__closure *TNDBGridDrawTitleEvent)(
                  System::TObject* Sender, int ACol, int ARow,
                  const System::Types::TRect &ARect,
                  Grids::TGridDrawState AState );

enum TNDBGridIndicatorState {
    nisNone, nisSelected, nisEdit, nisInsert, nisMultiSelected,
    nisMultiSelectedAndCurrentRow
};

typedef void __fastcall (__closure *TNDBGridDrawIndicatorEvent)(
                  System::TObject* Sender, int ACol, int ARow,
                  const System::Types::TRect &ARect, Grids::TGridDrawState AState,
                  TNDBGridIndicatorState IndicatorState
);

typedef void __fastcall (__closure *TNDBGridCanEditModifyEvent)(
    System::TObject* Sender, bool& CanModify
);

typedef void __fastcall (__closure *TNDBGRIDBeforeAutosetEvent)(
	System::TObject* Sender, bool& SaveSettings
);

typedef void __fastcall (__closure *TNDBGRIDBeforeAutoHintEvent)(
	System::TObject* Sender, bool& Allow
);

enum TNDBGridCellDblClickLocation { ncdclDataCell, ncdclIndicator, ncdclTitle };

typedef void __fastcall (__closure *TNDBGRIDCellDblClickEvent)(
    System::TObject* Sender, TNDBGridCellDblClickLocation Location
);

class PACKAGE TCustomNDBGrid : public TCustomDBGrid
{
private:
    friend class TNDBGridSaveSettings;

    int colDown_;
    int rowDown_;
    bool sizingActive_;
	std::unique_ptr<Graphics::TBitmap> const titleUpArrow_;
    std::unique_ptr<Graphics::TBitmap> const titleDownArrow_;
    TNDBGridClickEvent onAdvTitleClick_;
    TNDBGridDrawTitleEvent onDrawTitle_;
    TNDBGRIDCellDblClickEvent onCellDblClick_;
    TNDBGridCanEditModifyEvent onCanEditModify_;
    bool oldLinkActiveValueAssigned_;
    bool oldLinkActiveValue_;
    String orderByPrefix_;
    bool titleBtnAutoSet_;
    TNDBGridDrawIndicatorEvent onDrawIndicator_;
	TNDBGRIDBeforeAutosetEvent onBeforeAutoSet_;
	TNDBGRIDBeforeAutoHintEvent onBeforeAutoHint_;
	TNotifyEvent onAfterAutoSet_;
    TNDBGridClickingEvent onAdvTitleClicking_;
    std::unique_ptr<THintWindow> gridHintWindow_;
    int gridCurrentHintCol_;
    int gridCurrentHintRow_;
    bool cellAutoHintEnabled_;
    bool mouseInControl_;
    int titleHeight_;
    std::unique_ptr<TImageList> imglistArrows_;
    TNotifyEvent onTopLeftChanged_;

    void CreateArrows();
    void AddArrows( TImageList& ImgList, NativeUInt Instance,
                    TColor Color, TColor OldColor = clBlack,
                    String UpArrowResName = _T( "NTITLE_UP_ARROW_FLAT" ),
                    String DownArrowResName = _T( "NTITLE_DOWN_ARROW_FLAT" ) );
    void HdrButton( int X, int Y );
    TNDBGridColumns* __fastcall GeTNColumns() const;
    void __fastcall SeTNColumns( TNDBGridColumns* Val );
	void __fastcall ReadOrderByPrefix( TReader* const Reader );
    void __fastcall WriteOrderByPrefix( TWriter* const Writer );
    void TitleButtonsAutoSet( TMouseButton Button, TShiftState Shift,
                              int X, int Y, TNColumn *Column );
    void DoDrawIndicator( int ACol, int ARow, const System::Types::TRect &ARect,
                          Grids::TGridDrawState AState );
    void DoDrawTitle( int ACol, int ARow, const System::Types::TRect &ARect,
                      Grids::TGridDrawState AState );
    bool RowIsMultiSelected() const;
    void ClearGridHintWindow();
    void __fastcall SetTitleHeight( int Val );
    void ShowAutoHintIfNeeded( int X, int Y );
    void WriteText( TCanvas* ACanvas, const System::Types::TRect &Rect,
                    int DX, int DY, UnicodeString Text,
                    TAlignment Alignment, bool ARightToLeft );
protected:
    DYNAMIC void __fastcall MouseDown( Vcl::Controls::TMouseButton Button,
                                       Classes::TShiftState Shift,
                                       int X, int Y);
    DYNAMIC void __fastcall MouseUp( Vcl::Controls::TMouseButton Button,
                                     Classes::TShiftState Shift,
                                     int X, int Y);
    DYNAMIC void __fastcall DblClick();
    virtual void __fastcall DrawCell( int ACol, int ARow,
                                      const System::Types::TRect &ARect,
                                      Vcl::Grids::TGridDrawState AState );
    DYNAMIC void __fastcall KeyPress( TCHAR& Key );
    DYNAMIC bool __fastcall CanEditModify();
    DYNAMIC void __fastcall KeyDown( Word &Key, Classes::TShiftState Shift );
    DYNAMIC void __fastcall TopLeftChanged();
    virtual bool __fastcall SelectCell( int ACol, int ARow );
    virtual void __fastcall LinkActive( bool Value );
    virtual void __fastcall LayoutChanged(void);

    friend TNColumnTitle;

    DYNAMIC void __fastcall MouseMove( Classes::TShiftState Shift, int X, int Y );

    virtual void __fastcall WndProc( Winapi::Messages::TMessage &Message );

    __property TNDBGridClickEvent OnAdvTitleClick = {
        read = onAdvTitleClick_, write = onAdvTitleClick_
    };
    __property TNDBGridCanEditModifyEvent OnCanEditModify = {
        read = onCanEditModify_, write = onCanEditModify_
    };
    __property String OrderByPrefix = {
        read = orderByPrefix_, write = orderByPrefix_
    };
    __property bool TitleBtnAutoSet = {
        read = titleBtnAutoSet_, write = titleBtnAutoSet_
    };
	__property TNDBGRIDBeforeAutosetEvent OnBeforeAutoSet = {
		read = onBeforeAutoSet_, write = onBeforeAutoSet_
	};
	__property TNDBGRIDBeforeAutosetEvent OnBeforeAutoHint = {
		read = onBeforeAutoHint_, write = onBeforeAutoHint_
	};
	__property TNotifyEvent OnAfterAutoSet = {
        read = onAfterAutoSet_, write = onAfterAutoSet_
    };
    __property TNDBGridClickingEvent OnAdvTitleClicking = {
        read = onAdvTitleClicking_, write = onAdvTitleClicking_
    };
    __property bool CellAutoHintEnabled = {
        read = cellAutoHintEnabled_, write = cellAutoHintEnabled_
    };
    __property int TitleHeight = {
        read = titleHeight_, write = SetTitleHeight
    };
    virtual void __fastcall SetColumnAttributes();
    virtual void __fastcall Scroll( int Distance );
    __property TNDBGridDrawIndicatorEvent OnDrawIndicator = {
        read = onDrawIndicator_, write = onDrawIndicator_
    };
    __property TNDBGridDrawTitleEvent OnDrawTitle = {
        read = onDrawTitle_, write = onDrawTitle_
    };
    __property TNDBGRIDCellDblClickEvent OnCellDblClick = {
        read = onCellDblClick_, write = onCellDblClick_
    };
    __property TNotifyEvent OnTopLeftChanged = {
        read = onTopLeftChanged_, write = onTopLeftChanged_
    };
public:
    __fastcall TCustomNDBGrid( TComponent* Owner );
    void __fastcall NormalizeColumnIndexes();
    String __fastcall GetOrderByClause() const;
    void __fastcall RefreshDataset( TDataSet* DataSet = 0 );
    DYNAMIC TDBGridColumns* __fastcall CreateColumns();
    virtual void __fastcall DefineProperties( TFiler *Filer );
    void __fastcall CheckColumnsConsistency();
    __property TNDBGridColumns* TitleBtnColumns = {
        read = GeTNColumns, write = SeTNColumns
    };
    void DefaultDrawCell( int ACol, int ARow, const System::Types::TRect &ARect,
                          Vcl::Grids::TGridDrawState AState );
    void DrawTitleCell( int ACol, int ARow, const System::Types::TRect &ARect,
                        TColumn* Column, Vcl::Grids::TGridDrawState AState );
__published:
};
//---------------------------------------------------------------------------

class TNDBGridSaveSettings {
public:
	TNDBGridSaveSettings( TCustomNDBGrid& Grid )
        : grid_( Grid ),
          columns_( Grid.TitleBtnColumns->GetColumnSettingsAsBytes() ),
          leftCol_( Grid.LeftCol ), fixedCols_( Grid.FixedCols ) {}
    ~TNDBGridSaveSettings() throw() {
        grid_.TitleBtnColumns->SetColumnSettingsAsBytes( columns_ );
        grid_.FixedCols = fixedCols_;
        grid_.LeftCol = leftCol_;
    }
private:
    TCustomNDBGrid& grid_;
    TBytes columns_;
    int leftCol_;
    int fixedCols_;

    TNDBGridSaveSettings( TNDBGridSaveSettings const & );
    TNDBGridSaveSettings& operator=( TNDBGridSaveSettings const & );
};

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

class PACKAGE TNDBGrid : public TCustomNDBGrid
{
    typedef  TCustomNDBGrid  inherited;
public:
    __fastcall TNDBGrid( TComponent* Owner );
    __property Canvas;
    __property SelectedRows;
    __property TitleBtnColumns;
    __property InplaceEditor;
    using TCustomNDBGrid::CellRect;
    using TCustomNDBGrid::RawToDataColumn;
    using TCustomNDBGrid::DataToRawColumn;
    using TCustomNDBGrid::Sizing;
__published:
    __property Align;
    __property Anchors;
    __property BiDiMode;
    __property BorderStyle;
    __property Color;
    __property CellAutoHintEnabled;
    __property Columns;
    __property Constraints;
    __property Ctl3D;
    __property DataLink;
    __property DataSource;
    __property DefaultDrawing;
    __property DragCursor;
    __property DragKind;
    __property DragMode;
    __property Enabled;
    __property FixedColor = { default = -2147483633 };
    __property FixedCols;
    __property Font;
    __property ImeMode;
    __property ImeName;
    __property LeftCol;
    __property OnAdvTitleClick;
    __property OnAdvTitleClicking;
    __property OnAfterAutoSet;
	__property OnBeforeAutoSet;
    __property OnBeforeAutoHint;
    __property OnCanEditModify;
    __property OnCellClick;
    __property OnCellDblClick;
    __property OnColEnter;
    __property OnColExit;
    __property OnColumnMoved;
    __property OnDblClick;
    __property OnDragDrop ;
    __property OnDragOver;
    __property OnDrawColumnCell;
    __property OnDrawDataCell;
    __property OnDrawIndicator;
    __property OnDrawTitle;
    __property OnEditButtonClick;
    __property OnEndDock;
    __property OnEndDrag;
    __property OnEnter;
    __property OnExit;
    __property OnKeyDown;
    __property OnKeyPress;
    __property OnKeyUp;
	__property OnMouseActivate;
	__property OnMouseDown;
	__property OnMouseEnter;
	__property OnMouseLeave;
	__property OnMouseMove;
	__property OnMouseUp;
	__property OnMouseWheel;
	__property OnMouseWheelDown;
	__property OnMouseWheelUp;
    __property OnStartDock;
    __property OnStartDrag;
    __property OnTitleClick;
    __property OnTopLeftChanged;
    __property Options;
    __property OrderByPrefix = { stored = false };
    __property ParentBiDiMode;
    __property ParentColor;
    __property ParentCtl3D;
    __property ParentFont;
    __property ParentShowHint;
    __property PopupMenu;
    __property ReadOnly;
    __property ShowHint;
    __property TabOrder;
    __property TabStop;
    __property TitleBtnAutoSet;
    __property TitleFont;
    __property TitleHeight = { default = 0 };
    __property Visible;
};
#endif

