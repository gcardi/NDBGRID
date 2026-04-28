//---------------------------------------------------------------------------


#pragma hdrstop

#include "DataMod.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma classgroup "System.Classes.TPersistent"
#pragma resource "*.dfm"
//TdmDatabase *dmDatabase;
//---------------------------------------------------------------------------
__fastcall TdmDatabase::TdmDatabase(TComponent* Owner)
    : TDataModule(Owner)
{
}
//---------------------------------------------------------------------------
