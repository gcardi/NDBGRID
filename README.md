


# NDBGRID

**Enhanced TDBGrid for Delphi & C++Builder VCL Applications**

NDBGRID is a modern, feature-rich replacement for the standard TDBGrid, designed for professional VCL applications in Delphi and C++Builder. The component was originally written in C++ and has been translated to Delphi for broader compatibility. The original C++ version is included as a compressed archive (`OldCppComponent.7z`) in the root of this repository.

---

## Features

- **Interactive Sorting:** Clickable column headers automatically generate the `ORDER BY` clause for your dataset.
- **Smart Tooltips:** Automatic tooltip expansion for cell values that do not fit in the column width.
- **Custom Events:** Extended event set for advanced grid interaction and customization.
- **VCL Styles Support:** Seamless integration with VCL styles for a modern UI.
- **Easy Integration:** Drop-in replacement for TDBGrid with additional properties and events.

---

## Screenshots

<p align="center">
	<img src="docs/assets/images/Screenshot1.png" alt="Advanced grid features" width="600">
	<br><em>Interactive sorting and advanced column features</em>
</p>

<p align="center">
	<img src="docs/assets/images/Screenshot2.png" alt="VCL Styles support" width="600">
	<br><em>Full VCL styles support for a modern look</em>
</p>

---

## Installation

1. Open the `Delphi` folder.
2. Run `install.bat` to build and register the component packages in your IDE.
3. Restart RAD Studio. The `TNDBGrid` component will appear in the Tool Palette for both Delphi and C++Builder.
4. To uninstall, run `uninstall.bat` in the same folder.

---


## Usage

1. Drop `TNDBGrid` onto your form (just like TDBGrid).
2. Connect it to your `TDataSource`.
3. Configure columns, events, and properties as needed to leverage advanced features.

### Demos

Two demo projects are provided in the `Test` folder:

- `Test/Delphi/` &mdash; Delphi demo project (see the [walkthrough](docs/DELPHI_EXAMPLE.md))
- `Test/Cpp/` &mdash; C++Builder demo project

Explore these demos to see practical usage examples in both supported languages.

For detailed architecture, API, build, and customization notes, see the [technical documentation](docs/TECHNICAL.md). The component source is available in the [`Delphi`](./Delphi) folder.

---

## Paths & Configuration

**Include Path:**
```
<repo>\Delphi
```

**Library Path:**
```
$(BDSCOMMONDIR)\Bpl
$(BDSCOMMONDIR)\Bpl\$(Platform)
```

---


---

## Original C++ Component

The original version of this component, written in C++, is available as `OldCppComponent.7z` in the root of this repository. This archive contains the legacy C++ source code for reference or migration purposes.

---

## License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute it, subject to the conditions in the license.

