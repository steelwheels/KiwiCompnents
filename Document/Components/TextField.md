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
|Property name  |Type    |Description            |
|:--            |:--     |:--                    | 
|text           |string  |Content text           |
|minWidth       |number  |Minimum field width (unsigned integer) |
|isEditable     |boolean |Set editable or not    |
|isBezeled      |boolean |Set bezele ON/OFF      |
|fontSize       |[FontSize](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Enum/FontSize.md) | Size of font |

## Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site

