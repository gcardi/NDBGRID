unit ColTitleAttrs;

interface

uses
  System.Classes, Data.DB, NDBGrid;

type
  TColumnTitleAttrs = record
    Index: Integer;
    FieldName: string;
    Descending: Boolean;
  end;

  TColumnTitleAttrsCont = class
  private
    FItems: array of TColumnTitleAttrs;
    function GetCount: Integer;
    function GetItem(Idx: Integer): TColumnTitleAttrs;
  public
    constructor Create(Columns: TNDBGridColumns);
    property Count: Integer read GetCount;
    property Items[Idx: Integer]: TColumnTitleAttrs read GetItem; default;
  end;

implementation

{ TColumnTitleAttrsCont }

constructor TColumnTitleAttrsCont.Create(Columns: TNDBGridColumns);
var
  Idx, J, Len: Integer;
  Column: TNColumn;
  Title: TNColumnTitle;
  Field: TField;
  FieldName: string;
  Tmp: TColumnTitleAttrs;
begin
  inherited Create;
  Len := 0;
  SetLength(FItems, Columns.Count);
  for Idx := 0 to Columns.Count - 1 do
  begin
    Column := Columns.TitleBtnItems[Idx];
    Title := Column.BtnColumnTitle;
    Field := Column.Field;
    if Title.SortLevel >= 0 then
    begin
      if Field <> nil then
      begin
        if Field.Origin = '' then
          FieldName := Field.FieldName
        else
          FieldName := Field.Origin;
      end
      else
        FieldName := Column.FieldName;
      FItems[Len].Index := Title.SortLevel;
      FItems[Len].FieldName := FieldName;
      FItems[Len].Descending := Title.SortDesc;
      Inc(Len);
    end;
  end;
  SetLength(FItems, Len);

  { stable sort by Index using insertion sort }
  for Idx := 1 to Len - 1 do
  begin
    Tmp := FItems[Idx];
    J := Idx - 1;
    while (J >= 0) and (FItems[J].Index > Tmp.Index) do
    begin
      FItems[J + 1] := FItems[J];
      Dec(J);
    end;
    FItems[J + 1] := Tmp;
  end;
end;

function TColumnTitleAttrsCont.GetCount: Integer;
begin
  Result := Length(FItems);
end;

function TColumnTitleAttrsCont.GetItem(Idx: Integer): TColumnTitleAttrs;
begin
  Result := FItems[Idx];
end;

end.
