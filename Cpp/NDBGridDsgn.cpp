//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "NDBGrid.h"
#include "NDBGridDsgn.h"
#include "ComponentEditors.h"

//---------------------------------------------------------------------------

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

namespace Ndbgriddsgn
{
    void __fastcall PACKAGE Register()
    {
         TComponentClass classes[1] = { __classid( TNDBGrid ) };
         RegisterComponents( "Data Controls", classes, 0 );
         RegisterComponentEditor(
             __classid( TNDBGrid ), __classid( TNDBGridComponentEditor )
         );
    }
}
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

__fastcall TNDBGridComponentEditor::TNDBGridComponentEditor(
                                          Classes::TComponent* AComponent,
                                          Designintf::_di_IDesigner ADesigner )
  : TComponentEditor( AComponent, ADesigner )
{
}
//---------------------------------------------------------------------------

int __fastcall TNDBGridComponentEditor::GetVerbCount()
{
    return 1;
}
//---------------------------------------------------------------------------

UnicodeString __fastcall TNDBGridComponentEditor::GetVerb( int Index )
{
    return _T( "Co&lumns Editor..." );
}
//---------------------------------------------------------------------------

void __fastcall TNDBGridComponentEditor::ExecuteVerb( int Index )
{
    EditPropertyDlg( Component, TEXT( "Columns" ), Designer );
}
//---------------------------------------------------------------------------

