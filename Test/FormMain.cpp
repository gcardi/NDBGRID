//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include <memory>
#include <cstring>

#include <boost/regex.hpp>
#include <boost/utility.hpp>

#include "FormMain.h"

using std::unique_ptr;

using boost::wregex;
using boost::wcmatch;
using boost::regex_match;

using boost::noncopyable;

//#pragma alias "strrchr"    = "_strrchr"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------

__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
    , dmDatabase_( new TdmDatabase( 0 ) )
{

    ColorBox1->Selected = NDBGrid1->TitleFont->Color;
    ColorBox2->Selected = NDBGrid1->FixedColor;

    unique_ptr<TStringList> SLStyleNames( new TStringList() );
    for ( int Idx = 0 ; Idx < TStyleManager::StyleNames.Length ; ++Idx ) {
        SLStyleNames->Append( TStyleManager::StyleNames[Idx] );
    }
    comboboxStyle->Items->Assign( SLStyleNames.get() );
    comboboxStyle->ItemIndex =
        comboboxStyle->Items->IndexOf( StyleServices()->Name );

    dmDatabase_->FDQuery1->Open();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::comboboxStyleChange(TObject *Sender)
{
    TStyleManager::SetStyle( comboboxStyle->Text );
}
//---------------------------------------------------------------------------

void __fastcall TForm1::NDBGrid1AfterAutoSet(TObject *Sender)
{
    TNDBGrid& Grid = dynamic_cast<TNDBGrid&>( *Sender );

    UnicodeString const OrderByClause = Grid.GetOrderByClause();
    TDataSource& DataSource = *Grid.DataSource;
    if ( TFDQuery* const DataSet = dynamic_cast<TFDQuery*>( DataSource.DataSet ) ) {
        unique_ptr<TStringList> const CmdText( new TStringList );
        CmdText->Assign( DataSet->SQL );

        class CloseOpenDS : public noncopyable {
        public:
            explicit CloseOpenDS( TFDQuery& DS ) : ds_( DS ) { ds_.Close(); }
            ~CloseOpenDS() throw() { ds_.Open(); }
        private:
            TFDQuery& ds_;
        } const volatile CloseOpenDSManager( *DataSet );

        ::OutputDebugString( Grid.OrderByPrefix.c_str() );

        wregex re( ( L"^\\s*" + Grid.OrderByPrefix + L".*$" ).c_str() );
        for ( int Idx = 0 ; Idx < CmdText->Count ; ++Idx ) {
            wcmatch what;

            if ( regex_match( CmdText->Strings[Idx].c_str(), what, re ) ) {
                CmdText->Strings[Idx] = OrderByClause;
                DataSet->SQL->Assign( CmdText.get() );

                return;
            }
        }
        CmdText->Append( OrderByClause );
        DataSet->SQL->Assign( CmdText.get() );
    }
}
//---------------------------------------------------------------------------


/*
void __fastcall TForm1::NDBGrid1DrawIndicator(TObject *Sender, int ACol, int ARow,
          const TRect &ARect, TGridDrawState AState, TNDBGridIndicatorState IndicatorState)

{
    NDBGrid1->DefaultDrawCell( ACol, ARow, ARect, AState );
    TRect XR( ARect.Left, ARect.Top, ARect.Left + 4, ARect.Top + 4 );
    NDBGrid1->Canvas->Brush->Color = clYellow;
    NDBGrid1->Canvas->FillRect( XR );
}
*/
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
    NDBGrid1->TitleFont->Color = ColorBox1->Selected;
    DBGrid1->TitleFont->Color = ColorBox1->Selected;
}
//---------------------------------------------------------------------------

/*
void __fastcall TForm1::NDBGrid1DrawTitle(TObject *Sender, int ACol, int ARow, const TRect &ARect,
          TGridDrawState AState)
{
    if ( NDBGrid1->Options.Contains( dgIndicator ) ) {
        if ( ACol ) {
            NDBGrid1->DrawTitleCell(
                ACol, ARow, ARect, NDBGrid1->Columns->Items[ACol-1], AState
            );
        }
        else {
            NDBGrid1->DefaultDrawCell( ACol, ARow, ARect, AState );
        }
    }
    else
        NDBGrid1->DrawTitleCell(
            ACol, ARow, ARect, NDBGrid1->Columns->Items[ACol], AState
        );
    TRect XR( ARect.Left, ARect.Top, ARect.Left + 4, ARect.Top + 4 );
    NDBGrid1->Canvas->Brush->Color = AState.Contains( gdPressed ) ? clRed : clGreen;
    NDBGrid1->Canvas->FillRect( XR );
}
*/
//---------------------------------------------------------------------------

void __fastcall TForm1::Button2Click(TObject *Sender)
{
    NDBGrid1->FixedColor = ColorBox2->Selected;
    DBGrid1->FixedColor = ColorBox2->Selected;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::NDBGrid1MouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y)
{
    if ( !NDBGrid1->Sizing( X, Y ) && Shift.Contains( ssLeft ) ) {
        NDBGrid1->BeginDrag( false );
    }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::DBGrid1MouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y)
{
//    if ( !DBGrid1->Sizing( X, Y ) && Shift.Contains( ssLeft ) ) {
//        DBGrid1->BeginDrag( false );
//    }
}
//---------------------------------------------------------------------------

