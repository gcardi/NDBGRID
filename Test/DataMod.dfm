object dmDatabase: TdmDatabase
  OldCreateOrder = False
  Height = 299
  Width = 334
  object FDConnection1: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\Public\Documents\Embarcadero\Studio\19.0\Sampl' +
        'es\data\FDDemo.sdb'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 88
    Top = 120
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * '
      'from customers')
    Left = 96
    Top = 192
    object FDQuery1CustomerID: TStringField
      FieldName = 'CustomerID'
      Origin = 'CustomerID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Size = 5
    end
    object FDQuery1CompanyName: TStringField
      FieldName = 'CompanyName'
      Origin = 'CompanyName'
      Required = True
      Size = 40
    end
    object FDQuery1ContactName: TStringField
      FieldName = 'ContactName'
      Origin = 'ContactName'
      Size = 30
    end
    object FDQuery1ContactTitle: TStringField
      FieldName = 'ContactTitle'
      Origin = 'ContactTitle'
      Size = 30
    end
    object FDQuery1Address: TStringField
      FieldName = 'Address'
      Origin = 'Address'
      Size = 60
    end
    object FDQuery1City: TStringField
      FieldName = 'City'
      Origin = 'City'
      Size = 15
    end
    object FDQuery1Region: TStringField
      FieldName = 'Region'
      Origin = 'Region'
      Size = 15
    end
    object FDQuery1PostalCode: TStringField
      FieldName = 'PostalCode'
      Origin = 'PostalCode'
      Size = 10
    end
    object FDQuery1Country: TStringField
      FieldName = 'Country'
      Origin = 'Country'
      Size = 15
    end
    object FDQuery1Phone: TStringField
      FieldName = 'Phone'
      Origin = 'Phone'
      Size = 24
    end
    object FDQuery1Fax: TStringField
      FieldName = 'Fax'
      Origin = 'Fax'
      Size = 24
    end
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 216
    Top = 136
  end
end
