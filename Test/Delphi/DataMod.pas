unit DataMod;

interface

uses
  System.SysUtils, System.Classes,
  Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.DApt, FireDAC.DApt.Intf, FireDAC.DatS,
  FireDAC.Phys, FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Stan.Async, FireDAC.Stan.Def, FireDAC.Stan.Error,
  FireDAC.Stan.ExprFuncs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Pool,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.ConsoleUI.Wait;

type
  TdmDatabase = class(TDataModule)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDQuery1CustomerID: TStringField;
    FDQuery1CompanyName: TStringField;
    FDQuery1ContactName: TStringField;
    FDQuery1ContactTitle: TStringField;
    FDQuery1Address: TStringField;
    FDQuery1City: TStringField;
    FDQuery1Region: TStringField;
    FDQuery1PostalCode: TStringField;
    FDQuery1Country: TStringField;
    FDQuery1Phone: TStringField;
    FDQuery1Fax: TStringField;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
  end;

implementation

{$R *.dfm}

end.
