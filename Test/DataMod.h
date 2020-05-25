//---------------------------------------------------------------------------

#ifndef DataModH
#define DataModH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Data.DB.hpp>
#include <FireDAC.Comp.Client.hpp>
#include <FireDAC.Comp.DataSet.hpp>
#include <FireDAC.DApt.hpp>
#include <FireDAC.DApt.Intf.hpp>
#include <FireDAC.DatS.hpp>
#include <FireDAC.Phys.hpp>
#include <FireDAC.Phys.Intf.hpp>
#include <FireDAC.Phys.SQLite.hpp>
#include <FireDAC.Phys.SQLiteDef.hpp>
#include <FireDAC.Stan.Async.hpp>
#include <FireDAC.Stan.Def.hpp>
#include <FireDAC.Stan.Error.hpp>
#include <FireDAC.Stan.ExprFuncs.hpp>
#include <FireDAC.Stan.Intf.hpp>
#include <FireDAC.Stan.Option.hpp>
#include <FireDAC.Stan.Param.hpp>
#include <FireDAC.Stan.Pool.hpp>
#include <FireDAC.UI.Intf.hpp>
#include <FireDAC.VCLUI.Wait.hpp>
#include <FireDAC.ConsoleUI.Wait.hpp>
//---------------------------------------------------------------------------
class TdmDatabase : public TDataModule
{
__published:	// IDE-managed Components
    TFDConnection *FDConnection1;
    TFDQuery *FDQuery1;
    TStringField *FDQuery1CustomerID;
    TStringField *FDQuery1CompanyName;
    TStringField *FDQuery1ContactName;
    TStringField *FDQuery1ContactTitle;
    TStringField *FDQuery1Address;
    TStringField *FDQuery1City;
    TStringField *FDQuery1Region;
    TStringField *FDQuery1PostalCode;
    TStringField *FDQuery1Country;
    TStringField *FDQuery1Phone;
    TStringField *FDQuery1Fax;
    TFDPhysSQLiteDriverLink *FDPhysSQLiteDriverLink1;
private:	// User declarations
public:		// User declarations
    __fastcall TdmDatabase(TComponent* Owner);
};
//---------------------------------------------------------------------------
//extern PACKAGE TdmDatabase *dmDatabase;
//---------------------------------------------------------------------------
#endif
