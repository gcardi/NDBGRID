//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include <memory>
#include <vector>
#include <algorithm>

#include <Themes.hpp>

#include "NDBGrid.h"
#include "ColTitleAttrs.h"

using std::unique_ptr;
using std::vector;
using std::sort;
using std::equal;
using std::max;

//#pragma resource "RuntimeRes.res"

#pragma package(smart_init)
//---------------------------------------------------------------------------
// ValidCtrCheck is used to assure that the components created do not have
// any pure virtual functions.
//
//---------------------------------------------------------------------------

static inline void ValidCtrCheck(TNDBGrid *)
{
    new TNDBGrid(NULL);
}
//---------------------------------------------------------------------------

/*
namespace Ndbgrid
{
    void __fastcall PACKAGE Register()
    {
         TComponentClass classes[1] = {__classid(TNDBGrid)};
         RegisterComponents("Data Controls", classes, 0);
    }
}
*/
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

__fastcall TNColumn::TNColumn( TCollection* Collection )
    : TColumn( Collection )
{
}
//---------------------------------------------------------------------------

TColumnTitle* __fastcall TNColumn::CreateTitle()
{
    return new TNColumnTitle( this );
}
//---------------------------------------------------------------------------

TNColumnTitle* TNColumn::GetColumnTitle()
{
    return dynamic_cast<TNColumnTitle*>( Title );
}
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

__fastcall TNColumnTitle::TNColumnTitle( TNColumn* Column )
    : TColumnTitle( Column ), sortLevel_( -1 ), sortDesc_( false )
{
}
//---------------------------------------------------------------------------

void __fastcall TNColumnTitle::ResetAttributes()
{
    sortLevel_ = -1;
    sortDesc_ = false;

    if ( TCustomNDBGrid* const TitleBtnGrid = dynamic_cast<TCustomNDBGrid*>( Column->Grid ) )
        TitleBtnGrid->InvalidateTitles();
}
//---------------------------------------------------------------------------

void __fastcall TNColumnTitle::SetSortLevel( int Val )
{
    if ( Val != sortLevel_ ) {
        sortLevel_ = Val;
        if ( TCustomNDBGrid* const TitleBtnGrid = dynamic_cast<TCustomNDBGrid*>( Column->Grid ) )
            TitleBtnGrid->InvalidateTitles();
    }
}
//---------------------------------------------------------------------------

void __fastcall TNColumnTitle::SetSortDesc( bool Val )
{
    if ( Val != sortDesc_ ) {
        sortDesc_ = Val;
        if ( TCustomNDBGrid* const TitleBtnGrid = dynamic_cast<TCustomNDBGrid*>( Column->Grid ) )
            TitleBtnGrid->InvalidateTitles();
    }
}
//---------------------------------------------------------------------------

void __fastcall TNColumnTitle::Assign( TPersistent* Source )
{
    if ( TNColumnTitle* const Title = dynamic_cast<TNColumnTitle*>( Source ) ) {
        SortLevel = Title->sortLevel_;
        SortDesc = Title->sortDesc_;
    }
    TColumnTitle::Assign( Source );
}
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

__fastcall TNDBGridColumns::TNDBGridColumns( TCustomDBGrid* Grid,
                                             System::TMetaClass* ColumnClass )
    : TDBGridColumns( Grid, ColumnClass )
{
}
//---------------------------------------------------------------------------

TNColumn* __fastcall TNDBGridColumns::Add()
{
    return static_cast<TNColumn*>( TDBGridColumns::Add() );
}
//---------------------------------------------------------------------------

TCustomNDBGrid* __fastcall TNDBGridColumns::GeTNGrid()
{
    return static_cast<TCustomNDBGrid*>( Grid );
}
//---------------------------------------------------------------------------

TNColumn* __fastcall TNDBGridColumns::GeTNColumn( int Index )
{
    return static_cast<TNColumn*>( Items[Index] );
}
//---------------------------------------------------------------------------

void __fastcall TNDBGridColumns::SeTNColumn( int Index, TNColumn* Value )
{
    Items[Index] = Value;
}
//---------------------------------------------------------------------------

void TNDBGridColumns::ResetTitleAttributes()
{
    for ( int Idx = 0 ; Idx < Count ; ++Idx )
        TitleBtnItems[Idx]->BtnColumnTitle->ResetAttributes();
}
//---------------------------------------------------------------------------

TNColumn* TNDBGridColumns::ColumnByFieldName( String Name )
{
    for ( int Idx = 0 ; Idx < Count ; ++Idx ) {
        TNColumn* Column = TitleBtnItems[Idx];
        if ( Name == Column->FieldName )
            return Column;
    }
    return 0;
}
//---------------------------------------------------------------------------

TNColumn* TNDBGridColumns::ColumnByOrigin( String Name )
{
    for ( int Idx = 0 ; Idx < Count ; ++Idx ) {
        TNColumn* Column = TitleBtnItems[Idx];
        if ( Name == Column->Field->Origin )
            return Column;
    }
    return 0;
}
//---------------------------------------------------------------------------

int TNDBGridColumns::GetNextAvailableSortLevel()
{
    int ColumnIndex = -1;

    for ( int Idx = 0 ; Idx < Count ; ++Idx ) {
        TNColumn* Column = TitleBtnItems[Idx];
        int SortLevel = Column->BtnColumnTitle->SortLevel;

        if ( SortLevel > ColumnIndex )
            ColumnIndex = SortLevel;
    }
    return ColumnIndex + 1;
}
//---------------------------------------------------------------------------

/*
AnsiString TNDBGridColumns::GetColumnSettings()
{
    unique_ptr<TMemoryStream> const MS( new TMemoryStream );
    SaveToStream( MS.get() );
    return AnsiString( static_cast<char*>( MS->Memory ), MS->Size );
}
//---------------------------------------------------------------------------

void TNDBGridColumns::SetColumnSettings( AnsiString Settings )
{
    unique_ptr<TMemoryStream> const MS( new TMemoryStream );
    MS->Write( Settings.c_str(), Settings.Length() );
    MS->Seek( 0, soFromBeginning );
    LoadFromStream( MS.get() );
}
//---------------------------------------------------------------------------
*/

TBytes TNDBGridColumns::GetColumnSettingsAsBytes()
{
    unique_ptr<TMemoryStream> const MS( new TMemoryStream );
    SaveToStream( MS.get() );
    TBytes Buffer;
    const DynArrInt Len = MS->Size;
    Buffer.Length = Len;
    const System::Byte* Src = static_cast<System::Byte*>( MS->Memory );
    for ( DynArrInt Idx = 0 ; Idx < Len ; ++Idx ) {
        Buffer[Idx] = *Src++;
    }
    return Buffer;
}
//---------------------------------------------------------------------------

void TNDBGridColumns::SetColumnSettingsAsBytes( TBytes Settings )
{
    unique_ptr<TMemoryStream> const MS( new TMemoryStream );
    const DynArrInt Len = Settings.Length;
    MS->Size = Len;
    System::Byte* Dst = static_cast<System::Byte*>( MS->Memory );
    for ( DynArrInt Idx = 0 ; Idx < Len ; ++Idx ) {
        *Dst++ = Settings[Idx];
    }
    MS->Seek( 0, soFromBeginning );
    LoadFromStream( MS.get() );
}

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

#define  ORDER_BY_PREFIX_DEF  "order by "

//---------------------------------------------------------------------------

__fastcall TCustomNDBGrid::TCustomNDBGrid(TComponent* Owner)
    : TCustomDBGrid( Owner ),
      colDown_( -1 ), rowDown_( -1 ),
      onAdvTitleClick_( 0 ), onDrawTitle_( 0 ), onCanEditModify_( 0 ),
      oldLinkActiveValueAssigned_( false ), oldLinkActiveValue_( false ),
      orderByPrefix_( ORDER_BY_PREFIX_DEF ), titleBtnAutoSet_( false ),
      onBeforeAutoSet_( 0 ), onAfterAutoSet_( 0 ), onAdvTitleClicking_( 0 ),
      cellAutoHintEnabled_( false ), mouseInControl_( false ),
      titleHeight_( 0 ), sizingActive_( false ), onCellDblClick_( 0 ),
      onTopLeftChanged_( 0 )
{
    CreateArrows();
    ClearGridHintWindow();
}
//---------------------------------------------------------------------------

void TCustomNDBGrid::CreateArrows()
{
    imglistArrows_.reset( new TImageList( 0 ) );

	auto h = reinterpret_cast<THandle>( HInstance );

	{
        unique_ptr<TBitmap> Bmp( new TBitmap() );
		Bmp->LoadFromResourceName( h, _D( "NTITLE_UP_ARROW" ) );
        imglistArrows_->Width = Bmp->Width;
        imglistArrows_->Height = Bmp->Height;

        imglistArrows_->AddMasked( Bmp.get(), clLtGray );

		Bmp->LoadFromResourceName( h, _D( "NTITLE_DOWN_ARROW" ) );
        imglistArrows_->AddMasked( Bmp.get(), clLtGray );
    }

    if ( StyleServices()->Enabled ) {
        if ( StyleServices()->IsSystemStyle ) {
            AddArrows(
                *imglistArrows_,
                h,
                TColor( ColorToRGB( TitleFont->Color ) )
            );
        }
        else {
            TColor Color;

            TThemedElementDetails LDetails =
               StyleServices()->GetElementDetails( tgFixedCellNormal );
            StyleServices()->GetElementColor( LDetails, ecTextColor, Color );
            AddArrows( *imglistArrows_, h, Color );

            LDetails =
               StyleServices()->GetElementDetails( tgFixedCellHot );
            StyleServices()->GetElementColor( LDetails, ecTextColor, Color );
            AddArrows( *imglistArrows_, h, Color );

            LDetails =
               StyleServices()->GetElementDetails( tgFixedCellPressed );
            StyleServices()->GetElementColor( LDetails, ecTextColor, Color );
            AddArrows( *imglistArrows_, h, Color );
        }
    }
}
//---------------------------------------------------------------------------

void TCustomNDBGrid::AddArrows( TImageList& ImgList, NativeUInt Instance,
                                TColor Color, TColor OldColor,
                                String UpArrowResName, String DownArrowResName )
{
    unique_ptr<TBitmap> Bmp( new TBitmap() );

    Bmp->Handle =
        CreateMappedRes(
            Instance, UpArrowResName.c_str(),
            &OldColor, 0, &Color, 0
        );

    ImgList.AddMasked( Bmp.get(), Bmp->TransparentColor );

    Bmp->Handle =
        CreateMappedRes(
            Instance, DownArrowResName.c_str(),
            &OldColor, 0, &Color, 0
        );

    ImgList.AddMasked( Bmp.get(), Bmp->TransparentColor );
}
//---------------------------------------------------------------------------

bool TCustomNDBGrid::RowIsMultiSelected() const
{
    int Index;
    return Options.Contains( dgMultiSelect ) && DataLink->Active &&
           SelectedRows->Find( DataLink->DataSource->DataSet->Bookmark, Index );
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::MouseDown( Controls::TMouseButton Button,
                                           Classes::TShiftState Shift,
                                           int X, int Y )
{
    if ( Button == mbLeft ) {
        TGridCoord MC( MouseCoord( X, Y ) );
        sizingActive_ = Sizing( X, Y );
        if ( !sizingActive_ ) {
            const int FirstDataCol = DataToRawColumn( 0 );
            TNColumn* const Column =
                MC.X >= FirstDataCol ?
                  TitleBtnColumns->TitleBtnItems[MC.X - FirstDataCol]
                :
                  0;
            bool Cliccable = true;
            if ( onAdvTitleClicking_ ) {
                onAdvTitleClicking_( this, Button, Shift, X, Y, Column, Cliccable );
            }
            if ( Cliccable ) {
                HdrButton( MC.X, MC.Y );
            }
            else {
                HdrButton( -1, -1 );
                return;
            }
        }
        else {
            HdrButton( -1, -1 );
        }
    }
    else {
        HdrButton( -1, -1 );
    }
    TCustomDBGrid::MouseDown( Button, Shift, X, Y );
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::MouseUp( Controls::TMouseButton Button,
                                         Classes::TShiftState Shift,
                                         int X, int Y )
{
    TCustomDBGrid::MouseUp( Button, Shift, X, Y );
    if ( Button == mbLeft ) {
        int const FirstDataCol = DataToRawColumn( 0 );
        if ( colDown_ >= 0 || rowDown_ >= 0 ) {
            TGridCoord const MC = MouseCoord( X, Y );
            if ( MC.X == colDown_ && !MC.Y && Y >= 0 ) {
                TNColumn* const Column =
                    MC.X >= FirstDataCol ?
                      TitleBtnColumns->TitleBtnItems[MC.X - FirstDataCol]
                    :
                      0;
                if ( !sizingActive_ && Column ) {
                    if ( onAdvTitleClick_ ) {
                        onAdvTitleClick_( this, Button, Shift, X, Y, Column );
                    }
                    else {
                        if ( titleBtnAutoSet_ ) {
                            bool SaveSettings = true;
                            if ( onBeforeAutoSet_ ) {
                                onBeforeAutoSet_( this, SaveSettings );
                            }
                            TitleButtonsAutoSet( Button, Shift, X, Y, Column );
                            unique_ptr<TNDBGridSaveSettings> Snapshot;
                            if ( SaveSettings ) {
                                Snapshot.reset( new TNDBGridSaveSettings ( *this ) );
                            }
                            if ( onAfterAutoSet_ ) {
                                onAfterAutoSet_( this );
                            }
                        }
                    }
                }
            }
        }
    }
    HdrButton( -1, -1 );
    sizingActive_ = false;
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::DblClick()
{
    TCustomDBGrid::DblClick();

    const TGridCoord Coord = MouseCoord( HitTest.X, HitTest.Y );

    if ( Coord.X >= 0 && Coord.Y >= 0 ) {
        TNDBGridCellDblClickLocation Where;

        if ( Options.Contains( dgTitles ) && !Coord.Y ) {
            Where = ncdclTitle;
        }
        else if ( Options.Contains( dgIndicator ) && !Coord.X ) {
            Where = ncdclIndicator;
        }
        else {
            Where = ncdclDataCell;
        }
        if ( onCellDblClick_ )
            onCellDblClick_( this, Where );
    }
}
//---------------------------------------------------------------------------

void TCustomNDBGrid::HdrButton( int X, int Y )
{
    if ( colDown_ >= 0 || rowDown_ >= 0 )
        InvalidateCell( colDown_, rowDown_ );
    if ( Options.Contains( dgTitles ) ) {
        colDown_ = X;
        rowDown_ = Y;
    }
    else {
        colDown_ = -1;
        rowDown_ = -1;
    }
}
//---------------------------------------------------------------------------

TDBGridColumns* __fastcall TCustomNDBGrid::CreateColumns()
{
    return new TNDBGridColumns( this, __classid( TNColumn ) );
}
//---------------------------------------------------------------------------

TNDBGridColumns* __fastcall TCustomNDBGrid::GeTNColumns() const
{
    return dynamic_cast<TNDBGridColumns*>( Columns );
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::SeTNColumns( TNDBGridColumns* Val )
{
    Columns = Val;
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::KeyPress( TCHAR& Key )
{
    TCustomDBGrid::KeyPress( Key );
    if ( Key && Key == VK_ESCAPE && ( colDown_ >= 0 || rowDown_ >= 0 ) )
        HdrButton( -1, -1 );
    ClearGridHintWindow();
}
//---------------------------------------------------------------------------

bool __fastcall TCustomNDBGrid::CanEditModify()
{
    bool CanModify( TCustomDBGrid::CanEditModify() );

    if ( onCanEditModify_ )
        onCanEditModify_( this, CanModify );
    return CanModify;
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::KeyDown( Word &Key, Classes::TShiftState Shift )
{
    TCustomDBGrid::KeyDown( Key, Shift );
    ClearGridHintWindow();
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::NormalizeColumnIndexes()
{
    TNDBGridColumns* Columns = TitleBtnColumns;
    TColumnTitleAttrsCont ColumnTitleAttributes( Columns );

    int Level = 0;
    for ( int Idx = 0 ; Idx < ColumnTitleAttributes.Count ; ++Idx ) {
        String const FieldName = ColumnTitleAttributes[Idx].FieldName;
        TNColumn *Column( Columns->ColumnByFieldName( FieldName ) );
        TNColumnTitle* Title;
        if ( Column ) {
            Title = Column->BtnColumnTitle;
            Title->SortLevel = Level++;
        }
        else {
            Column = Columns->ColumnByOrigin( FieldName );
            if ( Column ) {
                Title = Column->BtnColumnTitle;
                Title->SortLevel = Level++;
            }
        }
    }
}
//---------------------------------------------------------------------------

String __fastcall TCustomNDBGrid::GetOrderByClause() const
{
    String Result;

    TNDBGridColumns* const Columns = TitleBtnColumns;
    TColumnTitleAttrsCont ColumnTitleAttributes( Columns );

    for ( int Idx( 0 ) ; Idx < ColumnTitleAttributes.Count ; ++Idx ) {
        if ( !Result.IsEmpty() )
			Result += _D( ", " );
        Result += ColumnTitleAttributes[Idx].FieldName;
        if ( ColumnTitleAttributes[Idx].Descending )
			Result += _D( " desc" );
    }

    if ( !Result.IsEmpty() ) {
        String OrderByPre = orderByPrefix_.Trim();
        if ( !OrderByPre.IsEmpty() )
			OrderByPre += _D( " " );
        Result = OrderByPre + Result;
    }
    return Result;
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::RefreshDataset( TDataSet* DataSet )
{
    if ( !DataSet ) {
        if ( DataSource ) {
            DataSet = DataSource->DataSet;
            DataSet->Close();
            DataSet->Open();
        }
    }
    else if ( DataSet->Active ) {
        TNDBGridSaveSettings const Snapshot( *this );
        DataSet->Close();
        DataSet->Open();
    }
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::ReadOrderByPrefix( TReader* const Reader )
{
    orderByPrefix_ = Reader->ReadString();
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::WriteOrderByPrefix( TWriter* const Writer )
{
    Writer->WriteString( orderByPrefix_ );
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::DefineProperties( TFiler *Filer )
{
    TComponent::DefineProperties( Filer );
    Filer->DefineProperty(
		_D( "OrderByPrefix" ),
        ReadOrderByPrefix, WriteOrderByPrefix,
        orderByPrefix_ != String( ORDER_BY_PREFIX_DEF )
    );
}
//---------------------------------------------------------------------------

void TCustomNDBGrid::TitleButtonsAutoSet( TMouseButton Button, TShiftState Shift,
                                          int X, int Y, TNColumn *Column )
{
    if ( Shift.Contains( ssAlt ) )
        TitleBtnColumns->ResetTitleAttributes();
    else {
        TNColumnTitle* Title( Column->BtnColumnTitle );
        if ( Title->SortLevel >= 0 )
            Title->SortDesc = !Title->SortDesc;
        else {
            if ( Shift.Contains( ssCtrl ) ) {
                Title->SortLevel = TitleBtnColumns->NextAvailableSortLevel;
            }
            else {
                TitleBtnColumns->ResetTitleAttributes();
                Title->SortLevel = 0;
            }
        }
    }
    NormalizeColumnIndexes();
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::TopLeftChanged()
{
    if ( LeftCol < FixedCols )
        LeftCol = FixedCols;
    TCustomDBGrid::TopLeftChanged();
    if ( onTopLeftChanged_ ) {
        onTopLeftChanged_( this );
    }
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::LinkActive( bool Value )
{
    TCustomDBGrid::LinkActive( Value );
    if ( Value )
        CheckColumnsConsistency();
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::CheckColumnsConsistency()
{
    if ( DataSource ) {
        TDataSet* const DataSet = DataSource->DataSet;
        if ( DataSet ) {
            int const FieldCount = DataSet->Fields->Count;
            int const ColumnCount = TitleBtnColumns->Count;
            if ( ColumnCount == FieldCount ) {
                vector<String> FieldList;
                for ( int Idx = 0 ; Idx < FieldCount ; ++Idx )
                    FieldList.push_back( DataSet->Fields->Fields[Idx]->FieldName );
                vector<String> ColumnList;
                for ( int Idx = 0 ; Idx < FieldCount ; ++Idx )
                    ColumnList.push_back( TitleBtnColumns->Items[Idx]->FieldName );
                sort( FieldList.begin(), FieldList.end() );
                sort( ColumnList.begin(), ColumnList.end() );
                if ( equal( FieldList.begin(), FieldList.end(), ColumnList.begin() ) )
                    return;
            }
        }
        TitleBtnColumns->Clear();
    }
 }
//---------------------------------------------------------------------------

void TCustomNDBGrid::ClearGridHintWindow()
{
    gridHintWindow_.reset();
    gridCurrentHintCol_ = -1;
    gridCurrentHintRow_ = -1;
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::MouseMove( Classes::TShiftState Shift, int X, int Y )
{
    TCustomDBGrid::MouseMove( Shift, X, Y );
    ShowAutoHintIfNeeded( X, Y );
}
//---------------------------------------------------------------------------

void TCustomNDBGrid::ShowAutoHintIfNeeded( int X, int Y )
{
    if ( cellAutoHintEnabled_ && MouseInClient && PtInRect( ClientRect, TPoint( X, Y ) ) ) {
        int const FirstDataCol = DataToRawColumn( 0 );

        TGridCoord const MC = MouseCoord( X, Y );

        int const ACol = MC.X - FirstDataCol;
        int const ARow = MC.Y - /*FTitleOffset*/1;

        if ( DataLink->Active ) {

            if ( ARow >= 0 && ACol >= 0 ) {
                TColumn& Column = *Columns->Items[ACol];

                class TGridDataLinkActiveRecordKeeper {
                public:
                    TGridDataLinkActiveRecordKeeper( TGridDataLink& DataLink )
                        : dataLink_( DataLink ),
                          oldActive_( dataLink_.ActiveRecord ) {}
                    ~TGridDataLinkActiveRecordKeeper() throw() {
                        dataLink_.ActiveRecord = oldActive_;
                    }
                private:
                    TGridDataLinkActiveRecordKeeper&
                      operator=( TGridDataLinkActiveRecordKeeper const & );
                    TGridDataLinkActiveRecordKeeper(
                        TGridDataLinkActiveRecordKeeper const & );

                    TGridDataLink& dataLink_;
                    int const oldActive_;
                } const ActiveRecordKeeper( *DataLink );

                DataLink->ActiveRecord = ARow;

                if ( Column.Field ) {
                    //Column.Font
                    if ( gridCurrentHintCol_ != MC.X || gridCurrentHintRow_ != MC.Y  ) {
                        ClearGridHintWindow();
                    }
                    String const DisplayText = Column.Field->DisplayText;
                    System::Types::TRect const CRect = CellRect( MC.X, MC.Y );
                    //int const TextWidth = Canvas->TextWidth( DisplayText );
                    int TextWidth = 0;
                    {
                        unique_ptr<TFont> OldFont( new TFont() );
                        OldFont->Assign( Canvas->Font );
                        Canvas->Font->Assign( Column.Font );
                        TextWidth = Canvas->TextWidth( DisplayText );
                        Canvas->Font->Assign( OldFont.get() );
                    }
/*
::OutputDebugString(
    Format(
		_D( "" )
        "%d - MC.X=%d, MC.Y=%d, CRect{ %d,%d,%d,%d, W=%d, h=%d }, "
        "TextWidth=%d, DisplayText:\"%s\"",
        ARRAYOFCONST( (
            int( TextWidth > CRect.Width() ),
            MC.X, MC.Y,
            CRect.Left, CRect.Top, CRect.Right, CRect.Bottom,
            CRect.Width(), CRect.Height(),
            TextWidth, DisplayText
        ) )
    ).c_str()
);
*/
                    if ( TextWidth > CRect.Width() ) {
                        if ( !gridHintWindow_.get() ) {
                            gridHintWindow_.reset( new THintWindow( (TComponent*)0 ) );
                            gridHintWindow_->Color = Color;
                            //gridHintWindow_->Canvas->Font->Assign( Font );
                            //gridHintWindow_->Font->Assign( Column.Font );
                            gridHintWindow_->Canvas->Font->Assign( Column.Font );

                            TPoint const CellScreenPos =
                                ClientToScreen( Types::TPoint( CRect.Left, CRect.Top ) );
                            System::Types::TRect HintRect =
                                gridHintWindow_->CalcHintRect( Screen->Width, DisplayText, 0 );

                            switch ( Column.Alignment ) {
                                case taRightJustify:
                                    Types::OffsetRect(
                                        HintRect,
                                        CellScreenPos.x - max( 0, HintRect.Width() - CRect.Width() ) + 1,
                                        CellScreenPos.y - 1
                                    );
                                    break;
                                case taCenter:
                                    Types::OffsetRect(
                                        HintRect,
                                        CellScreenPos.x - max( 0, HintRect.Width() - CRect.Width() ) / 2,
                                        CellScreenPos.y - 1
                                    );
                                    break;
                                default:
                                    Types::OffsetRect(
                                        HintRect,
                                        CellScreenPos.x /*- 1*/, CellScreenPos.y - 1
                                    );
                                    break;
                            }
                            bool ActivateAutoHint = true;
                            if ( onBeforeAutoHint_ ) {
                                onBeforeAutoHint_( this, ActivateAutoHint );
                            }
                            if ( ActivateAutoHint ) {
                                gridHintWindow_->ActivateHint( HintRect, DisplayText );
                            }
                            gridCurrentHintCol_ = MC.X;
                            gridCurrentHintRow_ = MC.Y;
                        }
                    }
                }
            }
            else {
                ClearGridHintWindow();
            }
        }
    }
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::SetColumnAttributes()
{
    if ( TitleHeight && FixedRows )
        RowHeights[0] = max( TitleHeight, RowHeights[0] );
    TCustomDBGrid::SetColumnAttributes();
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::SetTitleHeight( int Val )
{
    if ( titleHeight_ != Val ) {
        titleHeight_ = Val;
        BeginLayout();
        EndLayout();
    }
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::WndProc( Winapi::Messages::TMessage &Message )
{
    TCustomDBGrid::WndProc( Message );
    switch ( Message.Msg ) {
        case CM_MOUSELEAVE:
            ClearGridHintWindow();
            break;
        case CM_STYLECHANGED:
            if ( Options.Contains( dgTitles ) && StyleServices()->Enabled ) {
                CreateArrows();
                Invalidate();
            }
            break;
    }
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::LayoutChanged( void )
{
//    if ( Options.Contains( dgTitles ) && StyleServices()->Enabled &&
//         StyleServices()->IsSystemStyle ) {
    if ( Options.Contains( dgTitles ) && StyleServices()->Enabled ) {
        CreateArrows();
    }
    TCustomDBGrid::LayoutChanged();
}
//---------------------------------------------------------------------------

bool __fastcall TCustomNDBGrid::SelectCell( int ACol, int ARow )
{
    TPoint const CursorPos = ScreenToClient( Mouse->CursorPos );
    TGridCoord const MC( MouseCoord( CursorPos.x, CursorPos.y ) );
    if ( gridCurrentHintCol_ != MC.X || gridCurrentHintRow_ != MC.Y  )
        ClearGridHintWindow();
    ShowAutoHintIfNeeded( CursorPos.x, CursorPos.y );
    return TCustomDBGrid::SelectCell( ACol, ARow );
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::Scroll( int Distance )
{
    if ( Distance )
        ClearGridHintWindow();
    TPoint const CursorPos = ScreenToClient( Mouse->CursorPos );
    ShowAutoHintIfNeeded( CursorPos.x, CursorPos.y );
    TCustomDBGrid::Scroll( Distance );
}
//---------------------------------------------------------------------------

void TCustomNDBGrid::DoDrawIndicator( int ACol, int ARow,
                                      System::Types::TRect const &ARect,
                                      Grids::TGridDrawState AState )
{
    if ( onDrawIndicator_ ) {
        TNDBGridIndicatorState IndicatorState = nisNone;

        int const FirstDataRow = Options.Contains( dgTitles ) ? 1 : 0;
        if ( DataLink && DataLink->Active ) {
            bool MultiSelected = false;
            if ( ARow - FirstDataRow >= 0 ) {

                class TTryFinallyMultiSelected {
                public:
                    TTryFinallyMultiSelected( TGridDataLink& DataLink )
                      : dataLink_( DataLink ), oldActive_( dataLink_.ActiveRecord ) {}
                    ~TTryFinallyMultiSelected() throw() {
                        dataLink_.ActiveRecord = oldActive_;
                    }
                private:
                    TTryFinallyMultiSelected( TTryFinallyMultiSelected const & );
                    TTryFinallyMultiSelected& operator=( TTryFinallyMultiSelected const & );

                    TGridDataLink& dataLink_;
                    int const oldActive_;
                }
                TryFinallyMultiSelected( *DataLink );

                DataLink->ActiveRecord = ARow - FirstDataRow;
                MultiSelected = RowIsMultiSelected();
            }

            if ( ( ARow - FirstDataRow ) == DataLink->ActiveRecord || MultiSelected ) {
                IndicatorState = nisSelected;
                if ( DataLink->DataSet ) {
                    switch ( DataLink->DataSet->State ) {
                        case dsEdit:
                            IndicatorState = nisEdit;
                            break;
                        case dsInsert:
                            IndicatorState = nisInsert;
                            break;
                        case dsBrowse:
                            if ( MultiSelected ) {
                                if ( ( ARow - FirstDataRow ) != DataLink->ActiveRecord ) {
                                    IndicatorState = nisMultiSelected;
                                }
                                else {
                                    IndicatorState = nisMultiSelectedAndCurrentRow;
                                }
                            }
                            else {
                                if ( ( ARow - FirstDataRow ) != DataLink->ActiveRecord ) {
                                    IndicatorState = nisNone;
                                }
                                else {
                                    IndicatorState = nisSelected;
                                }
                            }
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        onDrawIndicator_(
            this, ACol, ARow, ARect, AState, IndicatorState
        );
    }
    else {
        TCustomDBGrid::DrawCell( ACol, ARow, ARect, AState );
    }
}
//---------------------------------------------------------------------------

void TCustomNDBGrid::DefaultDrawCell( int ACol, int ARow,
                                      const System::Types::TRect &ARect,
                                      Grids::TGridDrawState AState )
{
    TCustomDBGrid::DrawCell( ACol, ARow, ARect, AState );
}
//---------------------------------------------------------------------------

void TCustomNDBGrid::DoDrawTitle( int ACol, int ARow,
                                  System::Types::TRect const &ARect,
                                  Grids::TGridDrawState AState )
{
    if ( onDrawTitle_ ) {
        onDrawTitle_( this, ACol, ARow, ARect, AState );
    }
    else {
        const int ColIndex = Options.Contains( dgIndicator ) ? ACol - 1 : ACol;
        if ( ColIndex >= 0 && ColIndex < Columns->Count ) {
            DrawTitleCell( ACol, ARow, ARect, Columns->Items[ColIndex], AState );
        }
        else {
            TCustomDBGrid::DrawCell( ACol, ARow, ARect, AState );
        }
    }
}
//---------------------------------------------------------------------------

void __fastcall TCustomNDBGrid::DrawCell( int ACol, int ARow,
                                          const System::Types::TRect &ARect,
                                          Vcl::Grids::TGridDrawState AState )
{
    if ( Options.Contains( dgTitles ) && !ARow ) {
        DoDrawTitle( ACol, ARow, ARect, AState );
    }
    else if ( Options.Contains( dgIndicator ) && !ACol ) {
        DoDrawIndicator( ACol, ARow, ARect, AState );
    }
    else {
        TCustomDBGrid::DrawCell( ACol, ARow, ARect, AState );
    }
}
//---------------------------------------------------------------------------

void TCustomNDBGrid::WriteText( TCanvas* ACanvas,
                                const System::Types::TRect &ARect,
                                int DX, int DY, UnicodeString Text,
                                TAlignment Alignment, bool ARightToLeft )
{
    static const StaticArray<int, 3> AlignFlags = {
        DT_LEFT | DT_WORDBREAK | DT_EXPANDTABS | DT_NOPREFIX,
        DT_RIGHT | DT_WORDBREAK | DT_EXPANDTABS | DT_NOPREFIX,
        DT_CENTER | DT_WORDBREAK | DT_EXPANDTABS | DT_NOPREFIX
    };
    static const StaticArray<int, 2> RTL = { 0, DT_RTLREADING };

    System::Types::TRect tARect = ARect;

    Winapi::Windows::TColorRef I = ColorToRGB( ACanvas->Brush->Color );
    if ( GetNearestColor( ACanvas->Handle, I ) == I ) {
        // Use ExtTextOut for solid colors
        // In BiDi, because we changed the window origin, the text that does not
        //  change alignment, actually gets its alignment changed.
        if ( ACanvas->CanvasOrientation == coRightToLeft && !ARightToLeft ) {
            ChangeBiDiModeAlignment( Alignment );
        }
        int Left;
        switch ( Alignment ) {
            case taLeftJustify:
                Left = tARect.Left + DX;
                break;
            case taRightJustify:
                Left = tARect.Right - ACanvas->TextWidth( Text ) - 3;
                break;
            default: // taCenter
                Left = tARect.Left + ( tARect.Right - tARect.Left ) / 2 -
                       ACanvas->TextWidth( Text ) / 2;
                break;
        }
        ACanvas->TextRect(tARect, Left, tARect.Top + DY, Text);
    }
    else {
        //Use FillRect and Drawtext for dithered colors }
        unique_ptr<TBitmap> DrawBitmap( new TBitmap() );

//      with DrawBitmap, tARect do { Use offscreen bitmap to eliminate flicker and }
//      begin                     { brush origin tics in painting / scrolling.    }
        DrawBitmap->Width = tARect.Right - tARect.Left;
        DrawBitmap->Height = tARect.Bottom - tARect.Top;
        System::Types::TRect R( DX, DY, tARect.Right - tARect.Left - 1, tARect.Bottom - tARect.Top - 1);
        System::Types::TRect B( 0, 0, tARect.Right - tARect.Left, tARect.Bottom - tARect.Top);

        TCanvas* DBCanvas = DrawBitmap->Canvas;
        DBCanvas->Font->Assign( ACanvas->Font );
        DBCanvas->Font->Color = ACanvas->Font->Color;
        DBCanvas->Brush->Assign( ACanvas->Brush );
        DBCanvas->Brush->Style = bsSolid;
        DBCanvas->FillRect( B );
        SetBkMode( DBCanvas->Handle, TRANSPARENT );
        if ( ACanvas->CanvasOrientation == coRightToLeft ) {
            ChangeBiDiModeAlignment( Alignment );
        }
        DrawText( DBCanvas->Handle, Text.c_str(), Text.Length(), &R,
                  AlignFlags[Alignment] | RTL[ARightToLeft] );
        if ( ACanvas->CanvasOrientation == coRightToLeft ) {
            int Hold = tARect.Left;
            tARect.Left = tARect.Right;
            tARect.Right = Hold;
        }
        ACanvas->CopyRect( tARect, DrawBitmap->Canvas, B );
    }
}
//---------------------------------------------------------------------------

void TCustomNDBGrid::DrawTitleCell( int ACol, int ARow,
                                    const System::Types::TRect &Rect,
                                    TColumn* Column,
                                    Vcl::Grids::TGridDrawState AState )
{
    static const StaticArray<StaticArray<int, 2>, 2> ScrollArrows = {
      { { DFCS_SCROLLRIGHT, DFCS_SCROLLLEFT },
        { DFCS_SCROLLLEFT, DFCS_SCROLLRIGHT }
      }
    };

    TColumn* MasterCol;
    System::Types::TRect ARect = Rect;

    Byte LFrameOffs = 2;

    System::Types::TRect TitleRect = CalcTitleRect( Column, ARow, MasterCol );

    if ( !MasterCol ) {
        Canvas->FillRect( ARect );
        return;
    }

    Canvas->Font->Assign( MasterCol->Title->Font );
    Canvas->Brush->Color = MasterCol->Title->Color;

    static const TDBGridOptions LinesOpts =
        TDBGridOptions() << dgRowLines << dgColLines;
    if ( Options * LinesOpts == LinesOpts ) {
        InflateRect( TitleRect, -1, -1 );
        if ( AState.Contains( gdFixed ) ) {
            InflateRect( ARect, -1, -1 );
            LFrameOffs = 1;
        }
    }

    System::Types::TRect TextRect = TitleRect;
    int I = GetSystemMetrics( SM_CXHSCROLL );
    if ( TextRect.Right - TextRect.Left > I && MasterCol->Expandable ) {
        TextRect.Right = TextRect.Right - I;
        System::Types::TRect ButtonRect = TitleRect;
        ButtonRect.Left = TextRect.Right;
        I = SaveDC( Canvas->Handle );
        try {
            Canvas->FillRect( ButtonRect );
            InflateRect( ButtonRect, -1, -1 );
            IntersectClipRect(
                Canvas->Handle,
                ButtonRect.Left, ButtonRect.Top,
                ButtonRect.Right, ButtonRect.Bottom
            );
            InflateRect( ButtonRect, 1, 1 );
            /* DrawFrameControl doesn't draw properly when orienatation has changed.
              It draws as ExtTextOut does. */
            bool InBiDiMode =
                Canvas->CanvasOrientation == coRightToLeft;
            if ( InBiDiMode ) { // stretch the arrows box
                ButtonRect.Right =
                    ButtonRect.Right + GetSystemMetrics( SM_CXHSCROLL ) + 4;
            }
            DrawFrameControl(
                Canvas->Handle, &ButtonRect, DFC_SCROLL,
                ScrollArrows[InBiDiMode][MasterCol->Expanded] | DFCS_FLAT
            );
        }
        __finally {
            RestoreDC( Canvas->Handle, I );
        }
    }
    int TitleOffset = 0;
    if ( Options.Contains( dgTitles ) ) {
        ++TitleOffset;
    }

    DrawCellBackground( TitleRect, FixedColor, AState, ACol, ARow - TitleOffset );

    if ( AState.Contains( gdPressed ) ) {
        ++LFrameOffs; // Offset text when fixed cell is pressed
    }

    enum class OrderByIndicator {
        None, WindowUp, WindowDown, ThemedNormalUp, ThemedNormalDown,
        ThemedHotUp, ThemedHotDown, ThemedPressedUp, ThemedPressedDown,
    };

    OrderByIndicator OrderByIndicatorValue = OrderByIndicator::None;

    int DeltaTextRect = 0;
    String SortText;
    int SortTextWidth = 0;
//    if ( TNColumn* const NColumn = TitleBtnColumns->TitleBtnItems[ACol-FixedCols] ) {
    if ( TNColumn* const NColumn = dynamic_cast<TNColumn*>( Column ) ) {
        if ( TNColumnTitle* const NColumnTitle = NColumn->BtnColumnTitle ) {
            if ( NColumnTitle->SortLevel >= 0 ) {
                const bool Down = NColumnTitle->SortDesc;
                if ( StyleServices()->Enabled ) {
                    if ( StyleServices()->IsSystemStyle ) {
                        OrderByIndicatorValue =
                            Down ?
                              OrderByIndicator::ThemedNormalDown
                            :
                              OrderByIndicator::ThemedNormalUp;
                    }
                    else {
                        if ( AState.Contains( gdPressed ) ) {
                            OrderByIndicatorValue =
                                Down ?
                                  OrderByIndicator::ThemedPressedDown
                                :
                                  OrderByIndicator::ThemedPressedUp;
                        }
                        else if ( AState.Contains( gdHotTrack ) ) {
                            OrderByIndicatorValue =
                                Down ?
                                  OrderByIndicator::ThemedHotDown
                                :
                                  OrderByIndicator::ThemedHotUp;
                        }
                        else {
                            OrderByIndicatorValue =
                                Down ?
                                  OrderByIndicator::ThemedNormalDown
                                :
                                  OrderByIndicator::ThemedNormalUp;
                        }
                    }
                }
                else {
                    OrderByIndicatorValue =
                        Down ?
                          OrderByIndicator::WindowDown
                        :
                          OrderByIndicator::WindowUp;
                }
                if ( OrderByIndicatorValue != OrderByIndicator::None ) {
                    DeltaTextRect += imglistArrows_->Width + 4;
                    for ( int MinSortColCount = 0, Idx = 0 ; Idx < TitleBtnColumns->Count ; ++Idx ) {
                        if ( TitleBtnColumns->TitleBtnItems[Idx]->BtnColumnTitle->SortLevel >= 0 ) {
                            if ( !MinSortColCount ) {
                                ++MinSortColCount;
                            }
                            else {
                                SortText = NColumnTitle->SortLevel + 1;
                                SortTextWidth = Canvas->TextWidth( NColumnTitle->SortLevel + 1 );
                                DeltaTextRect += SortTextWidth;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    if ( OrderByIndicatorValue != OrderByIndicator::None ) {
        if ( TitleRect.Width() - Canvas->TextWidth( MasterCol->Title->Caption ) >= DeltaTextRect + 12 ) {
            TextRect.Left += DeltaTextRect;
        }
        else {
            OrderByIndicatorValue = OrderByIndicator::None;
        }
    }

    if ( SortTextWidth && OrderByIndicatorValue != OrderByIndicator::None ) {
        TextRect.Left += 8;
    }

    WriteText(
        Canvas, TextRect, LFrameOffs, LFrameOffs, MasterCol->Title->Caption,
        MasterCol->Title->Alignment, IsRightToLeft
    );

    if ( OrderByIndicatorValue != OrderByIndicator::None ) {
        imglistArrows_->Draw(
            Canvas,
            Rect.Left + 4,
            ( Rect.Top + Rect.Bottom - imglistArrows_->Height ) / 2 + 1,
            static_cast<int>( OrderByIndicatorValue ) - 1
        );
        if ( SortTextWidth ) {
            const int SortTextX = Rect.Left + imglistArrows_->Width + 4;
            if ( AState.Contains( gdPressed ) ) {
                ++SortTextWidth;
            }
            System::Types::TRect SortTextVisibleRect(
                SortTextX,
                TextRect.Top,
                SortTextX + SortTextWidth + 1,
                TextRect.Bottom
            );
            WriteText(
                Canvas, SortTextVisibleRect, LFrameOffs, LFrameOffs,
                SortText, taLeftJustify, IsRightToLeft
            );
        }
    }

    TGridDrawingStyle InternalDrawingStyle = DrawingStyle;
    if ( ( DrawingStyle == gdsThemed ) && !ThemeControl( this ) ) {
        InternalDrawingStyle = gdsClassic;
    }

    if ( ( Options * LinesOpts == LinesOpts ) &&
         ( InternalDrawingStyle == gdsClassic ) &&
         !AState.Contains( gdPressed ) )
    {
        InflateRect( TitleRect, 1, 1 );
        if ( !TStyleManager().IsCustomStyleActive ) {
            DrawEdge( Canvas->Handle, &TitleRect, BDR_RAISEDINNER, BF_BOTTOMRIGHT );
            DrawEdge( Canvas->Handle, &TitleRect, BDR_RAISEDINNER, BF_TOPLEFT );
        }
    }
    //AState = AState >> gdFixed;
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

__fastcall TNDBGrid::TNDBGrid(TComponent* Owner)
    : TCustomNDBGrid( Owner )
{
}
//---------------------------------------------------------------------------

