# NDBGRID
## Enhanced TDBGrid for VCL applications 

## Paths to add to plaftorms

Includes:
$(BDSCOMMONDIR)\NDBGRID

Libraries:
$(BDSCOMMONDIR)\NDBGRID\$(Platform)\Release
$(BDSCOMMONDIR)\NDBGRID\$(Platform)\Debug
$(BDSCOMMONDIR)\NDBGRID\$(Platform)
$(BDSCOMMONDIR)\NDBGRID

## Some interesting features:

- Automatic generation of the ORDER BY clause by (clickable) column headers configuration
- Automatic tooltip expansion (on mouse over) when the field value doesn't fit in the column width
- Some useful events was added 
- VCL styles are supported
- ...

<img src="docs/assets/images/Screenshot1.png" alt="Comparated grid feature example" border="0"></a>

<img src="docs/assets/images/Screenshot2.png" alt="Styles support" border="0"></a>

###
Note: With bcc64x you need to copy the file RuntimeRes.res manually in the executable's folder as the new toolchain doesn't search for such files in the project directory, So you first have to build the file as mentioned earlier from the source RuntimeRes.rc, then copy it to the executable's folder. If you don't do so, the modern win64 toolchain raises a linker error.

