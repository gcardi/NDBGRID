//---------------------------------------------------------------------------

#ifndef FormMainH
#define FormMainH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ADODB.hpp>
#include <DB.hpp>
#include <DBGrids.hpp>
#include <Grids.hpp>
#include <ActnColorMaps.hpp>
#include <ActnMan.hpp>
#include <Buttons.hpp>
#include <ComCtrls.hpp>
#include <DBCtrls.hpp>
#include <ExtCtrls.hpp>
#include <Vcl.Menus.hpp>
#include <Vcl.ActnPopup.hpp>
#include <System.Actions.hpp>
#include <Vcl.ActnCtrls.hpp>
#include <Vcl.ActnList.hpp>
#include <Vcl.ActnMenus.hpp>
#include <Vcl.PlatformDefaultStyleActnCtrls.hpp>
#include <Vcl.StdActns.hpp>
#include <Vcl.ToolWin.hpp>
#include <Vcl.ImgList.hpp>
#include <NDBGrid.h>
#include <FireDAC.Comp.UI.hpp>
#include <FireDAC.Stan.Intf.hpp>
#include <FireDAC.UI.Intf.hpp>
#include <FireDAC.VCLUI.Wait.hpp>

#include <memory>

#include "DataMod.h"

namespace Styled
{
#if 1
class TPopupMenu : public Vcl::Actnpopup::TPopupActionBar
{
public:
    __fastcall virtual TPopupMenu( System::Classes::TComponent* AOwner )
        : Vcl::Actnpopup::TPopupActionBar( AOwner ) {}
    __fastcall virtual ~TPopupMenu(void) { }
};
#else
typedef  TPopupMenu  TPopupMenu;
#endif
};

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TDataSource *DataSource1;
    TDBGrid *DBGrid1;
    TPanel *Panel1;
    TDBNavigator *DBNavigator1;
    TPanel *Panel2;
    TNDBGrid *NDBGrid1;
    TSplitter *Splitter1;
    TPanel *Panel3;
    TActionManager *ActionManager1;
    TFileExit *FileExit1;
    TActionMainMenuBar *ActionMainMenuBar1;
    Styled::TPopupMenu *PopupMenu1;
    TMenuItem *Exit1;
    TComboBox *comboboxStyle;
    TPanel *Panel5;
    TLabel *Label1;
    TButton *Button1;
    TColorBox *ColorBox1;
    TPanel *Panel4;
    TPanel *Panel6;
    TButton *Button2;
    TColorBox *ColorBox2;
    TFDGUIxWaitCursor *FDGUIxWaitCursor1;
    void __fastcall NDBGrid1AfterAutoSet(TObject *Sender);
    void __fastcall comboboxStyleChange(TObject *Sender);
    void __fastcall Button1Click(TObject *Sender);
    void __fastcall Button2Click(TObject *Sender);
    void __fastcall NDBGrid1MouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
    void __fastcall DBGrid1MouseMove(TObject *Sender, TShiftState Shift, int X, int Y);

private:	// User declarations
    std::unique_ptr<TdmDatabase> dmDatabase_;
public:		// User declarations
    __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
