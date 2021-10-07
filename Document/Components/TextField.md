# TextField component
text field. You can choose editable or non-editable.

## Syntax
````
field: TextField {
    text:       String      "The label string"
    minWidth:   Int         40
    fontSize:   FontSize    [small | regular | large]
    isEditable: Bool        false
    isBezeled:  Bool        false
}
````

## Property values
|Property name  |Type   |Description            |
|:--            |:--    |:--                    | 
|text           |String |Content text           |
|minWidth       |Int    |Minimum field width    |
|isEditable     |Bool   |Set editable or not    |
|isBezeled      |Bool   |Set bezele ON/OFF      |
|fontSize       |[FontSize](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Enum/FontSize.md) | Size of font |

## Reference
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
