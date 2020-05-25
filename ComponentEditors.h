#ifndef ComponenteditorsH
#define ComponenteditorsH

#include <System.hpp>
#include <Designintf.hpp>
#include <Designeditors.hpp>

namespace Componenteditors
{

class TPropEditorWithDialog {
public:
    void __fastcall CheckEditProperty( _di_IProperty const Prop );
    void __fastcall EditProperty( TPersistent* Component, String PropName,
                                  _di_IDesigner const Designer );
private:
    String propName_;
};

class TDesignerSelectionsPub : public TDesignerSelections {
public:
    using TDesignerSelections::Add;
};

extern PACKAGE void EditPropertyDlg( TPersistent* Component, String PropName,
                                     _di_IDesigner Designer );

}

using namespace Componenteditors;

#endif  // ComponenteditorsHPP

