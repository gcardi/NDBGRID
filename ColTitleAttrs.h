//---------------------------------------------------------------------------
#ifndef ColTitleAttrsH
#define ColTitleAttrsH

#include <vector>

#include "NDBGrid.h"

//---------------------------------------------------------------------------

class TColumnTitleAttrs {
public:
    TColumnTitleAttrs( int Idx, String FieldName, bool Desc )
        : index_( Idx ), fieldName_( FieldName ), descending_( Desc ) {}
/*
    TColumnTitleAttrs( TColumnTitleAttrs const & rhs )
        : index_( rhs.index_ ), fieldName_( rhs.fieldName_ ),
          descending_( rhs.descending_ ) {}
    TColumnTitleAttrs& operator=( TColumnTitleAttrs const & rhs ) {
        index_ = rhs.index_;
        fieldName_ = rhs.fieldName_;
        descending_ = rhs.descending_;
        return *this;
    }
*/
    __property int Index = { read = index_ };
    __property String FieldName = { read = fieldName_ };
    __property bool Descending = { read = descending_ };
private:
    int index_;
    String fieldName_;
    bool descending_;

    friend bool operator<( TColumnTitleAttrs const & T1, TColumnTitleAttrs const & T2 );
};
//---------------------------------------------------------------------------

inline bool operator<( TColumnTitleAttrs const & T1, TColumnTitleAttrs const & T2 )
{
    return T1.index_ < T2.index_;
}
//---------------------------------------------------------------------------

class TColumnTitleAttrsCont {
public:
    TColumnTitleAttrsCont( TNDBGridColumns* Columns );
    __property int Count = { read = GetCount };
    TColumnTitleAttrs& operator[]( int Idx ) { return triplet_[Idx]; }
private:
    std::vector<TColumnTitleAttrs> triplet_;

    int GetCount() const { return static_cast<int>( triplet_.size() ); }
};
//---------------------------------------------------------------------------
#endif
