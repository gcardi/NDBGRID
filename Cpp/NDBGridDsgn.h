//---------------------------------------------------------------------------

#ifndef NDBGridDsgnH
#define NDBGridDsgnH

#include <DesignEditors.hpp>

class TNDBGridComponentEditor : public TComponentEditor
{
public:
    __fastcall TNDBGridComponentEditor( Classes::TComponent* AComponent,
                                        Designintf::_di_IDesigner ADesigner );
protected:
    void __fastcall ExecuteVerb( int Index );
    UnicodeString __fastcall GetVerb( int Index );
    int __fastcall GetVerbCount();
private:
};
//---------------------------------------------------------------------------
#endif
