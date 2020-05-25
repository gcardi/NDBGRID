object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 565
  ClientWidth = 761
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 277
    Width = 761
    Height = 5
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 257
  end
  object Panel1: TPanel
    Left = 0
    Top = 25
    Width = 761
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object DBNavigator1: TDBNavigator
      Left = 8
      Top = 8
      Width = 240
      Height = 25
      DataSource = DataSource1
      TabOrder = 0
    end
    object Button2: TButton
      Left = 352
      Top = 6
      Width = 75
      Height = 22
      Caption = 'Fixed Color'
      TabOrder = 1
      OnClick = Button2Click
    end
    object ColorBox2: TColorBox
      Left = 448
      Top = 6
      Width = 145
      Height = 22
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 66
    Width = 761
    Height = 211
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object NDBGrid1: TNDBGrid
      Left = 0
      Top = 17
      Width = 761
      Height = 194
      Align = alClient
      CellAutoHintEnabled = True
      Columns = <
        item
          Expanded = False
          FieldName = 'CustomerID'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CompanyName'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ContactName'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ContactTitle'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Address'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'City'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Region'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'PostalCode'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Country'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Phone'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Fax'
          Width = 64
          Visible = True
        end>
      DataSource = DataSource1
      FixedColor = clBtnFace
      LeftCol = 1
      OnAfterAutoSet = NDBGrid1AfterAutoSet
      OnMouseMove = NDBGrid1MouseMove
      TabOrder = 0
      TitleBtnAutoSet = True
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      TitleHeight = -1
    end
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 761
      Height = 17
      Align = alTop
      Caption = 'TNDBGrid'
      TabOrder = 1
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 282
    Width = 761
    Height = 283
    Align = alBottom
    TabOrder = 2
    object DBGrid1: TDBGrid
      Left = 1
      Top = 18
      Width = 759
      Height = 264
      Align = alClient
      DataSource = DataSource1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect, dgTitleClick, dgTitleHotTrack]
      ParentFont = False
      PopupMenu = PopupMenu1
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnMouseMove = DBGrid1MouseMove
      Columns = <
        item
          Expanded = False
          FieldName = 'CustomerID'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CompanyName'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ContactName'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ContactTitle'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Address'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'City'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Region'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'PostalCode'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Country'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Phone'
          Width = 64
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Fax'
          Width = 64
          Visible = True
        end>
    end
    object Panel6: TPanel
      Left = 1
      Top = 1
      Width = 759
      Height = 17
      Align = alTop
      Caption = 'TDBGrid'
      TabOrder = 1
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 0
    Width = 761
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel5'
    ShowCaption = False
    TabOrder = 3
    object Label1: TLabel
      Left = 81
      Top = 6
      Width = 68
      Height = 13
      Alignment = taRightJustify
      Caption = 'Selected Style'
    end
    object ActionMainMenuBar1: TActionMainMenuBar
      Left = 0
      Top = 0
      Width = 32
      Height = 25
      UseSystemFont = False
      ActionManager = ActionManager1
      Align = alLeft
      Caption = 'ActionMainMenuBar1'
      Color = clMenuBar
      ColorMap.DisabledFontColor = 7171437
      ColorMap.HighlightColor = clWhite
      ColorMap.BtnSelectedFont = clBlack
      ColorMap.UnusedColor = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      Spacing = 0
    end
    object comboboxStyle: TComboBox
      Left = 156
      Top = 3
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 1
      OnChange = comboboxStyleChange
    end
    object Button1: TButton
      Left = 352
      Top = 3
      Width = 75
      Height = 22
      Caption = 'Titles color'
      TabOrder = 2
      OnClick = Button1Click
    end
    object ColorBox1: TColorBox
      Left = 448
      Top = 3
      Width = 145
      Height = 22
      TabOrder = 3
    end
  end
  object DataSource1: TDataSource
    DataSet = dmDatabase.FDQuery1
    Left = 408
  end
  object ActionManager1: TActionManager
    ActionBars = <
      item
      end
      item
        Items = <
          item
            Items = <
              item
                Action = FileExit1
                ImageIndex = 43
              end>
            Caption = '&File'
          end>
        ActionBar = ActionMainMenuBar1
      end>
    Left = 440
    Top = 137
    StyleName = 'Platform Default'
    object FileExit1: TFileExit
      Category = 'File'
      Caption = 'E&xit'
      Hint = 'Exit|Quits the application'
      ImageIndex = 43
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 200
    Top = 370
    object Exit1: TMenuItem
      Action = FileExit1
    end
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 608
    Top = 186
  end
end
