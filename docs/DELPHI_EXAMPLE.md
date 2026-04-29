# Delphi Demo (`Test/Delphi`)

This document describes the structure and behaviour of the Delphi VCL demo
shipped with NDBGRID. The project lives in `Test/Delphi/` and shows
`TNDBGrid` next to a stock `TDBGrid` so the two can be compared at runtime
against the same dataset.

## Project Layout

```text
Test/Delphi/
|-- Test.dpr           Program entry point
|-- Test.dproj         RAD Studio project file
|-- DataMod.pas/.dfm   Data module: FireDAC connection, query, fields
|-- FormMain.pas/.dfm  Main form: TNDBGrid + TDBGrid + style/colour controls
`-- Test.res           Compiled resource file
```

`Test.dpr` is a minimal VCL bootstrap: it initialises the application,
creates `TForm1` as the main form, and runs the message loop.

## Data Module — `TdmDatabase`

`DataMod.pas` defines a `TDataModule` that owns the data access layer. It is
created manually by the main form (`FormMain.pas:68`) rather than auto-created
by the project, so the form controls its lifetime.

Components on the data module:

- `FDConnection1` — a `TFDConnection` configured for SQLite. It points at
  `fddemo.sdb`, the standard FireDAC sample database installed with RAD Studio
  under `…\Studio\37.0\Samples\Data\`.
- `FDPhysSQLiteDriverLink1` — links the static SQLite driver into the
  executable.
- `FDQuery1` — a `TFDQuery` whose initial SQL is:

  ```sql
  select *
  from customers
  ```

  Its persistent fields (`CustomerID`, `CompanyName`, `ContactName`,
  `ContactTitle`, `Address`, `City`, `Region`, `PostalCode`, `Country`,
  `Phone`, `Fax`) are declared as `TStringField` so the grids can resolve
  column metadata at design time.

The query is left closed in the `.dfm`; the form opens it after wiring up
`DataSource1` (`FormMain.pas:85`).

## Main Form — `TForm1`

The form is split top-to-bottom into bands:

| Band                      | Purpose                                         |
| ------------------------- | ----------------------------------------------- |
| `Panel5` (top)            | VCL style picker, "Titles color", action menu   |
| `Panel1`                  | `TDBNavigator` plus "Fixed Color" picker        |
| `Panel2` (`alClient`)     | `TNDBGrid` under a label panel (`TNDBGrid`)     |
| `Splitter1` (`alBottom`)  | Vertical splitter between the two grids         |
| `Panel3` (`alBottom`)     | `TDBGrid` under a label panel (`TDBGrid`)       |

Both grids bind to the same `DataSource1`, which is repointed at
`FDmDatabase.FDQuery1` in `FormCreate`. Their column lists are configured
identically in the `.dfm` so the visual difference between the two
implementations can be observed directly.

### Form Lifecycle

`FormCreate` (`FormMain.pas:63-86`) does four things:

1. Instantiates the data module and binds `DataSource1` to its query.
2. Initialises the two `TColorBox` selectors with the grid's current
   `TitleFont.Color` and `FixedColor`, so the controls reflect the live state.
3. Populates `comboboxStyle` with every registered VCL style name and selects
   the active style.
4. Opens the FireDAC query, which makes the rows visible in both grids.

`FormDestroy` (`FormMain.pas:88-91`) frees the data module that `FormCreate`
created.

## Demonstrated Features

### Side-by-side comparison

Both grids share `DataSource1`. Any navigation or edit performed in one is
immediately visible in the other through the `TDataSource` change broadcast,
which makes behavioural differences (title rendering, hints, sort handling)
easy to spot.

### VCL style switcher

`comboboxStyle` lists all styles known to `TStyleManager`. The
`comboboxStyleChange` handler (`FormMain.pas:93-96`) calls
`TStyleManager.SetStyle` with the picked name, applying the style to the
whole application at runtime. This is the primary way the demo shows that
`TNDBGrid` honours VCL styles.

### Titles colour

The "Titles color" button (`Button1Click`, `FormMain.pas:139-143`) writes the
selected `TColor` from `ColorBox1` into both `NDBGrid1.TitleFont.Color` and
`DBGrid1.TitleFont.Color`, so the two grids can be compared with a custom
title font colour.

### Fixed colour

The "Fixed Color" button (`Button2Click`, `FormMain.pas:145-149`) writes the
selected `TColor` from `ColorBox2` into both `NDBGrid1.FixedColor` and
`DBGrid1.FixedColor`. This is the colour of the fixed (non-scrolling) cells,
including the title row and the indicator column.

### Automatic cell hints

`NDBGrid1.CellAutoHintEnabled` is set to `True` in the `.dfm`
(`FormMain.dfm:72`). When the pointer hovers a cell whose text is clipped by
the column width, `TNDBGrid` shows a hint window with the full value. The
stock `TDBGrid` does not have this feature — hovering its cells produces no
tooltip — which makes the difference visible in the demo.

### Click-to-sort with `OnAfterAutoSet`

`NDBGrid1.TitleBtnAutoSet` is set to `True` in the `.dfm`
(`FormMain.dfm:143`). With this option enabled, clicking a column title
cycles the sort marker on that column (none → ascending → descending) and
fires the `OnAfterAutoSet` event after the marker has been updated.

`NDBGrid1AfterAutoSet` (`FormMain.pas:98-137`) translates the new sort state
into an SQL `ORDER BY` clause and re-runs the query:

1. `Grid.GetOrderByClause` builds the clause text from the columns currently
   marked as sorted, using `Grid.OrderByPrefix` (default: `order by`) as the
   leading keyword.
2. The handler verifies the underlying `TDataSet` is actually a `TFDQuery`
   (it bails out otherwise).
3. The query's `SQL` is copied into a `TStringList`. The query is closed
   while the SQL is rewritten.
4. A regular expression anchored on `Grid.OrderByPrefix` looks for an
   existing `order by` line:
   - If one is found, it is replaced with the freshly built clause.
   - If none exists, the new clause is appended as a new line.
5. The modified SQL is assigned back to `DataSet.SQL` and the query is
   reopened in the `finally` block, so the grid re-displays the data in the
   requested order.

This is the canonical pattern for using `TNDBGrid`'s sort UI to drive a
server-side `ORDER BY`, and the demo's regex approach also handles the case
where the SQL already contains an `order by` clause that must be rewritten
in place.

### Drag with `Sizing` guard

`NDBGrid1MouseMove` (`FormMain.pas:151-156`) calls `BeginDrag(False)` only
when the left mouse button is down **and** `NDBGrid1.Sizing(X, Y)` returns
`False`. `Sizing` is a `TCustomDBGrid` helper that `TNDBGrid` re-publishes as
`public`; it tells the form whether the cursor is currently over a column
divider where the grid itself is performing a column resize. Guarding the
`BeginDrag` call avoids hijacking the resize gesture and starting a drag
operation by accident.

The companion `DBGrid1MouseMove` handler is intentionally empty — the stock
`TDBGrid` does not expose a `Sizing` helper, so the demo simply leaves the
slot in place to make the asymmetry explicit.

## Running the Demo

1. Make sure the NDBGRID design-time package is installed in the IDE (run
   `Delphi/install.bat` from the repository root if not).
2. Verify that `…\Studio\37.0\Samples\Data\fddemo.sdb` exists. This file is
   shipped with RAD Studio's FireDAC samples; the connection string in
   `DataMod.dfm` points at it directly.
3. Open `Test/Delphi/Test.dproj` in RAD Studio.
4. Build and run for Win32 or Win64. Output binaries land in the
   corresponding `Win32/` or `Win64/` subdirectory.

On launch the form opens the `customers` query and shows the same rows in
both grids. Click a `TNDBGrid` column title to sort, hover a clipped cell to
see the auto-hint, and pick a VCL style or colour from the top panels to
exercise the styling APIs.
