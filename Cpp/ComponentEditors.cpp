//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include <memory>

#include "ComponentEditors.h"

//#include <boost/shared_ptr.hpp>

using std::unique_ptr;

//---------------------------------------------------------------------------

#pragma package(smart_init)

//---------------------------------------------------------------------------
namespace Componenteditors {
//---------------------------------------------------------------------------

void __fastcall TPropEditorWithDialog::CheckEditProperty( _di_IProperty const Prop )
{
    if ( Prop->GetName() == propName_ )
        Prop->Edit();
}
//---------------------------------------------------------------------------

void __fastcall TPropEditorWithDialog::EditProperty( TPersistent* Component,
                                                     String const PropName,
                                                     _di_IDesigner const Designer )
{
    TDesignerSelectionsPub* Components = new TDesignerSelectionsPub();
    propName_ = PropName;
    Components->Add( Component );
    GetComponentProperties(
        Components->operator _di_IDesignerSelections(),
        Typinfo::TTypeKinds() << tkClass,
        Designer,
        &CheckEditProperty
    );
}

void EditPropertyDlg( TPersistent* Component, String PropName,
                      _di_IDesigner Designer )
{
/*
    boost::shared_ptr<TPropEditorWithDialog>
    Edt( new TPropEditorWithDialog );

    Edt->EditProperty( Component, PropName, Designer );
*/
    unique_ptr<TPropEditorWithDialog> Edt( new TPropEditorWithDialog );
    Edt->EditProperty( Component, PropName, Designer );
}

//---------------------------------------------------------------------------
} // end of namespace Componenteditors
//---------------------------------------------------------------------------


