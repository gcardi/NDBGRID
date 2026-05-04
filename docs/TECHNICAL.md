# NDBGRID Technical Documentation

This document describes the internal structure and integration points of
NDBGRID, a VCL data-aware grid component that extends `TDBGrid` for Delphi and
C++Builder applications.

## Project Layout

```text
.
|-- Delphi/
|   |-- NDBGrid.pas                  Runtime component implementation
|   |-- ColTitleAttrs.pas            Sort metadata extraction and ordering
|   |-- NDBGridDsgn.pas              IDE registration and component editor
|   |-- ComponentEditors.pas         Design-time property editor helper
|   |-- EnhDbGridRunPkg.dpk/.dproj   Runtime package
|   |-- EnhDbGridDsgnPkg.dpk/.dproj  Design-time package
|   |-- install.bat                  Build/register script
|   |-- uninstall.bat                Unregister/cleanup script
|   `-- Risorse/                     Bitmap resources for the component
|-- Test/
|   |-- Delphi/                      Delphi VCL demo
|   `-- Cpp/                         C++Builder VCL demo
|-- docs/assets/                     README images and styling assets
|-- README.md
`-- LICENSE
```

The active component source is in `Delphi/`. The root-level
`OldCppComponent.7z` archive contains the legacy C++ implementation for
reference.

## Packages

NDBGRID is split into runtime and design-time packages.

### Runtime Package

`Delphi/EnhDbGridRunPkg.dpk` is marked with `{$RUNONLY}` and contains:

- `NDBGrid.pas`
- `ColTitleAttrs.pas`

It requires `rtl`, `vcl`, `vcldb`, and `vclimg`. The project file enables
`DCC_CBuilderOutput=All`, so C++Builder consumption artifacts are generated
alongside the Delphi package artifacts.

### Design-Time Package

`Delphi/EnhDbGridDsgnPkg.dpk` is marked with `{$DESIGNONLY}` and contains:

- `NDBGridDsgn.pas`
- `ComponentEditors.pas`

It requires the runtime package and `designide`. The design-time package
registers `TNDBGrid` on the IDE Tool Palette under `Data Controls` and adds a
component editor verb for opening the Columns editor.

## Main Runtime Types

### `TNDBGrid`

`TNDBGrid` is the published component class. It inherits from
`TCustomNDBGrid`, exposes most standard `TDBGrid` properties/events, and adds
the NDBGRID-specific behavior.

Notable published properties include:

- `CellAutoHintEnabled`: enables automatic hint windows for clipped cell text.
- `TitleBtnAutoSet`: enables built-in sort-state changes on title clicks.
- `OrderByPrefix`: prefix used by `GetOrderByClause`; defaults to `order by`.
- `TitleHeight`: optional fixed title-row height override.
- `TitleBtnColumns`: strongly typed access to the grid columns.

It also reintroduces these protected `TCustomDBGrid` helpers as public methods:

- `RawToDataColumn`
- `DataToRawColumn`
- `Sizing`

These helpers are useful when application code needs to map grid coordinates or
avoid starting drags while the user is resizing columns.

### `TCustomNDBGrid`

`TCustomNDBGrid` contains the actual behavior. It overrides input, drawing,
dataset-link, scrolling, layout, and window-message hooks from `TCustomDBGrid`.

Important responsibilities:

- create `TNDBGridColumns` instead of plain `TDBGridColumns`;
- track pressed header cells during mouse interaction;
- maintain title sort metadata;
- draw sort arrows and multi-sort sequence numbers in title cells;
- generate SQL `ORDER BY` clauses from title metadata;
- show hint windows when data-cell text is clipped;
- expose custom draw hooks for title and indicator cells;
- preserve column settings while datasets are refreshed.

### `TNDBGridColumns`

`TNDBGridColumns` extends `TDBGridColumns` and stores `TNColumn` instances.

Key methods:

- `Add`: creates and returns a `TNColumn`.
- `ResetTitleAttributes`: clears sort level and descending state for all
  columns.
- `ColumnByFieldName`: finds a column by `FieldName`.
- `ColumnByOrigin`: finds a column by the bound field's `Origin`.
- `GetColumnSettingsAsBytes` and `SetColumnSettingsAsBytes`: serialize and
  restore column settings using the inherited column streaming support.
- `NextAvailableSortLevel`: returns the next sort index for multi-column sort.

### `TNColumn` and `TNColumnTitle`

`TNColumn` extends `TColumn` only to create an enhanced `TNColumnTitle`.

`TNColumnTitle` adds:

- `SortLevel`: zero-based sort priority, or `-1` when the column is not sorted.
- `SortDesc`: whether the column is sorted descending.
- `ResetAttributes`: clears both sort values and invalidates title drawing.

These properties are published, so they can be streamed with column definitions
and configured by code or the Object Inspector where applicable.

### `TColumnTitleAttrsCont`

`ColTitleAttrs.pas` defines a small container used while generating sort state.
It extracts sorted columns from `TNDBGridColumns`, chooses `Field.Origin` when
available, falls back to `FieldName`, and then performs a stable insertion sort
by `SortLevel`.

This keeps SQL generation independent of visual column order.

## Sorting Workflow

Sorting is metadata-driven. NDBGRID does not execute SQL by itself; it manages
column sort state and exposes the generated clause to application code.

When `TitleBtnAutoSet` is enabled and the user clicks a title cell:

1. `MouseDown` records the pressed title cell unless the user is resizing.
2. `MouseUp` checks that the same title cell was released.
3. `OnAdvTitleClick` runs first when assigned.
4. If no custom title-click handler is assigned, `TitleButtonsAutoSet` updates
   the column title metadata.
5. `NormalizeColumnIndexes` compacts sort levels into `0..N`.
6. `OnAfterAutoSet` is fired so the application can refresh the dataset.

Default click behavior:

- Plain click on an unsorted column clears other sorted columns and sorts this
  column at level `0`.
- Plain click on an already sorted column toggles `SortDesc`.
- `Ctrl` + click on an unsorted column appends it to the multi-column sort.
- `Alt` + click clears all sort attributes.

`GetOrderByClause` builds the SQL fragment from the current title metadata. For
example, if `CompanyName` is level `0` ascending and `Country` is level `1`
descending, the result is:

```sql
order by CompanyName, Country desc
```

The prefix comes from `OrderByPrefix`. Setting the prefix to an empty string
returns only the comma-separated sort expressions.

## Dataset Refresh Pattern

`RefreshDataset` can close and reopen a dataset while preserving column
configuration and scroll state through `TNDBGridSaveSettings`.

Typical application code should still decide how sorting is applied. The Delphi
demo handles `OnAfterAutoSet`, reads `GetOrderByClause`, updates the `TFDQuery`
SQL text, and reopens the query. This keeps NDBGRID generic and avoids coupling
the component to FireDAC, SQL dialects, or a specific dataset class.

### Using `TNDBGridSaveSettings` directly

`TNDBGridSaveSettings` is a small RAII-style helper. Its constructor captures
the current column settings (via `GetColumnSettingsAsBytes`), `LeftCol`, and
`FixedCols`; its destructor restores all three. Application code can use it
to wrap any operation that would otherwise reset visible column state, such
as rewriting the underlying SQL, swapping datasets, or applying filters that
force a column rebuild.

```pascal
uses
  NDBGrid;

procedure TForm1.ApplyFilter(const AWhere: string);
var
  Snapshot: TNDBGridSaveSettings;
begin
  Snapshot := TNDBGridSaveSettings.Create(NDBGrid1);
  try
    FDQuery1.Close;
    FDQuery1.SQL.Text :=
      'select * from customers ' + AWhere;
    FDQuery1.Open;
  finally
    Snapshot.Free; { restores column widths/order, LeftCol, FixedCols }
  end;
end;
```

The pattern is the same one used internally by `RefreshDataset` and by the
auto-sort path in `MouseUp`: create a snapshot, perform the disruptive work
inside a `try`/`finally`, and free the snapshot to restore the grid layout.
Pass the snapshot a `TNDBGrid` (or any `TCustomNDBGrid` descendant); it does
not take ownership of the grid and only keeps a reference for the lifetime
of the snapshot.

## Drawing Behavior

`DrawCell` dispatches title and indicator cells before falling back to inherited
data-cell drawing.

Title drawing:

- `OnDrawTitle` receives the first chance to custom draw title cells.
- Without a custom handler, `DrawTitleCell` draws the title using standard VCL
  grid behavior plus sort indicators.
- Sort arrows are loaded from resources into `FImgListArrows`.
- When VCL styles are active, arrow bitmaps are recolored from style text
  colors for normal, hot, and pressed states.
- Multi-column sort displays a numeric sort priority next to the arrow when
  more than one column is sorted.

Indicator drawing:

- `OnDrawIndicator` can custom draw the row indicator.
- The component computes `TNDBGridIndicatorState` before invoking the event.
- States distinguish selected, edit, insert, multi-selected, and current
  multi-selected rows.

`DefaultDrawCell` is available for custom draw handlers that want to preserve
the default grid rendering and then overlay additional visuals.

## Automatic Cell Hints

When `CellAutoHintEnabled` is true, `MouseMove`, `SelectCell`, and `Scroll`
coordinate hint visibility.

The component checks the current data cell, temporarily moves
`DataLink.ActiveRecord` to read the visible row value, measures
`Field.DisplayText` with the column font, and shows a `THintWindow` only when
the text is wider than the cell rectangle.

`OnBeforeAutoHint` can cancel a pending automatic hint by setting the event's
`Allow` parameter to `False`.

Hints are cleared when:

- the mouse leaves the grid;
- the active cell changes;
- the grid scrolls;
- keyboard input occurs;
- the pointer moves to another cell.

## Column Consistency

`CheckColumnsConsistency` runs when the data link becomes active. If explicit
columns no longer match the active dataset fields, the column collection is
cleared so the inherited grid machinery can regenerate columns.

The check compares field names case-insensitively after sorting both the dataset
field list and the grid column field list. If counts and names match, explicit
columns are retained.

## Design-Time Integration

`NDBGridDsgn.pas` registers:

```pascal
RegisterComponents('Data Controls', [TNDBGrid]);
RegisterComponentEditor(TNDBGrid, TNDBGridComponentEditor);
```

The component editor exposes one verb:

```text
Columns Editor...
```

Selecting it calls `EditPropertyDlg(Component, 'Columns', Designer)`, which is
implemented in `ComponentEditors.pas` by finding the `Columns` property editor
through the IDE design interfaces and invoking its editor.

## Installation Scripts

`Delphi/install.bat` derives the RAD Studio BDS version from the repository
path:

```text
...\Studio\<version>\NDBGRID\Delphi\install.bat
```

The script then:

1. validates `rsvars.bat`;
2. builds the runtime package for `Win32`, `Win64`, and `Win64x`;
3. builds the design-time package for `Win32`, and also `Win64`/`Win64x` when a
   64-bit IDE host is installed;
4. copies generated resource files beside C++Builder library artifacts;
5. registers design-time BPLs under the current user's RAD Studio registry
   keys;
6. adds the `Delphi` source directory to the IDE Library Search Path for each
   platform.

`Delphi/uninstall.bat` performs the inverse operation: it removes registry
entries, deletes generated package artifacts from default IDE output
locations, and removes the source directory from the IDE Library Search Path.

Both scripts are intended to run without elevation because registration is
written under `HKCU`.

## Demo Projects

The `Test` directory contains runnable VCL demos that exercise the component
from both Delphi and C++Builder. Both demos use the same application shape: a
standard `TDBGrid` and a `TNDBGrid` are placed on the form against the same
`TDataSource`, making it easy to compare default grid behavior with the
enhanced component.

### `Test/Delphi`

`Test/Delphi/Test.dpr` is the Delphi demo entry point. It creates `TForm1`,
loads the VCL styles units, and handles startup exceptions through
`Application.ShowException`.

The form is implemented by:

- `FormMain.pas`
- `FormMain.dfm`
- `DataMod.pas`
- `DataMod.dfm`

`DataMod.dfm` defines a `TFDConnection` using the SQLite driver and a
`TFDQuery` with this base SQL:

```sql
select *
from customers
```

The configured database is the FireDAC SQLite sample database that ships with
RAD Studio:

```text
$(BDSCOMMONDIR)\Samples\Data\fddemo.sdb
```

If the demo cannot find the database, update the `Database` value manually in
the `FDConnection1` instance on the data module. The exact path depends on the
RAD Studio installation and version, so point `FDConnection1.Params.Database`
at the local `fddemo.sdb` file for your environment.

The query exposes persistent string fields for the customer columns, including
`CustomerID`, `CompanyName`, `ContactName`, `ContactTitle`, `Address`, `City`,
`Region`, `PostalCode`, `Country`, `Phone`, and `Fax`.

The main form creates the data module at runtime, assigns `FDQuery1` to
`DataSource1`, populates a style selector from `TStyleManager.StyleNames`, and
opens the query. The form contains:

- `NDBGrid1`: the enhanced grid under test.
- `DBGrid1`: a standard `TDBGrid` used as a visual and behavioral baseline.
- `DBNavigator1`: bound to the same data source.
- `comboboxStyle`: switches active VCL style.
- `ColorBox1` and `Button1`: update the title font color on both grids.
- `ColorBox2` and `Button2`: update the fixed/title background color on both
  grids.

The Delphi demo configures `NDBGrid1` with:

- `CellAutoHintEnabled = True`
- `TitleBtnAutoSet = True`
- `TitleHeight = -1`
- `OnAfterAutoSet = NDBGrid1AfterAutoSet`
- `OnMouseMove = NDBGrid1MouseMove`

`NDBGrid1AfterAutoSet` demonstrates the expected SQL-backed sort integration:
it calls `Grid.GetOrderByClause`, searches the current `TFDQuery.SQL` text for
an existing line beginning with `Grid.OrderByPrefix`, replaces that line when
found, appends a new `ORDER BY` clause otherwise, and then reopens the query.

`NDBGrid1MouseMove` demonstrates how consumers can call `NDBGrid1.Sizing(X, Y)`
to avoid starting a drag operation while the pointer is over a column-resize
area.

The Delphi project file references `EnhDbGridRunPkg` and adds both
`$(BDSCOMMONDIR)\Dcp` and `..\..\Delphi` to the unit search path, allowing the
demo to resolve both the package artifacts and local component source.

### `Test/Cpp`

`Test/Cpp` is the C++Builder version of the same VCL demo. It contains:

- `Test.cpp` and `Test.cbproj`
- `ProjectGroupTest.groupproj`
- `FormMain.cpp`, `FormMain.h`, and `FormMain.dfm`
- `DataMod.cpp`, `DataMod.h`, and `DataMod.dfm`

The C++ entry point initializes the VCL application, sets `MainFormOnTaskBar`,
tries to activate the `Amakrits` style through `TStyleManager::TrySetStyle`,
and creates `TForm1`.

The C++ form mirrors the Delphi demo:

- it owns the data module through `std::unique_ptr<TdmDatabase>`;
- it opens `FDQuery1` in the form constructor;
- it populates the style combo box from `TStyleManager::StyleNames`;
- it exposes handlers for style changes, color changes, title sorting, and
  drag-vs-resize behavior.

The C++ `NDBGrid1AfterAutoSet` handler performs the same job as the Delphi
handler, but uses C++ idioms:

- `dynamic_cast<TNDBGrid&>` to access the sender as a grid;
- `Grid.GetOrderByClause()` to retrieve the generated SQL clause;
- `boost::wregex` to find an existing `ORDER BY` line;
- a small local RAII helper that closes the `TFDQuery` before editing SQL and
  reopens it when the handler exits.

The C++ project files link against `EnhDbGridRunPkg` and FireDAC SQLite
packages, verifying that the runtime package emits the C++Builder artifacts
needed by consuming C++ projects.

### What the demos validate

Together, the demos validate:

- style switching through `TStyleManager`;
- title font color changes;
- fixed/title color changes;
- automatic query sorting in `NDBGrid1AfterAutoSet`;
- automatic cell hints for clipped data text;
- title sort arrows and multi-column sort ordering;
- runtime package consumption from Delphi;
- runtime package consumption from C++Builder;
- avoiding drag start while a column is being resized;
- side-by-side comparison against standard `TDBGrid` behavior.

## Common Integration Example

Minimal Delphi usage:

```pascal
procedure TForm1.FormCreate(Sender: TObject);
begin
  NDBGrid1.DataSource := DataSource1;
  NDBGrid1.TitleBtnAutoSet := True;
  NDBGrid1.CellAutoHintEnabled := True;
end;

procedure TForm1.NDBGrid1AfterAutoSet(Sender: TObject);
var
  Grid: TNDBGrid;
  Clause: string;
begin
  Grid := Sender as TNDBGrid;
  Clause := Grid.GetOrderByClause;

  { Apply Clause to the backing dataset/query here, then reopen it. }
end;
```

For datasets that are not SQL-backed, use the title metadata directly through
`TitleBtnColumns` and apply sorting using the dataset-specific API.

## Maintenance Notes

- Keep runtime-only units out of the design-time package unless they are also
  required by `NDBGridDsgn.pas`.
- Keep design-time dependencies such as `DesignIntf`, `DesignEditors`, and
  `designide` out of the runtime package.
- If new bitmap resources are added for drawing, update the relevant `.rc`,
  `.dpk`, and package resource expectations together.
- When changing title click behavior, check both the Delphi and C++ demos
  because they rely on `OnAfterAutoSet` as the refresh hook.
- When changing package outputs, verify C++Builder artifacts still include
  `.hpp`, `.bpi`, `.lib`, `.a`, and copied resource files for supported
  platforms.
