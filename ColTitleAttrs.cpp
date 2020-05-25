//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include <algorithm>

#include "ColTitleAttrs.h"

using std::stable_sort;

//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

__fastcall TColumnTitleAttrsCont::TColumnTitleAttrsCont( TNDBGridColumns* Columns )
{
    for ( int Idx = 0 ; Idx < Columns->Count ; ++Idx ) {
        TNColumn* const Column = Columns->TitleBtnItems[Idx];
        TNColumnTitle* const Title = Column->BtnColumnTitle;
        TField* const Field = Column->Field;

        /*
        if ( Field && Title->SortLevel >= 0 ) {
            String const FieldName =
                  Field->Origin.IsEmpty() ?
                    Field->FieldName
                  :
                    Field->Origin;
            triplet_.push_back(
                TColumnTitleAttrs( Title->SortLevel, FieldName, Title->SortDesc )
            );
        }
        */
        if ( Title->SortLevel >= 0 ) {
            String FieldName;
            if ( Field ) {
                FieldName =
                    Field->Origin.IsEmpty() ?
                        Field->FieldName
                    :
                        Field->Origin;
            }
            else {
                FieldName = Column->FieldName;
            }
            triplet_.push_back(
                TColumnTitleAttrs( Title->SortLevel, FieldName, Title->SortDesc )
            );
        }
    }
    stable_sort( triplet_.begin(), triplet_.end() );
}
//---------------------------------------------------------------------------
