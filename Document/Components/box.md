# VBox/HBox
Container of multiple child components.

## Syntax
````
box0: VBox {
    axis:           Axis            horizontal
    alignment:      Alignment       center
    distribution:   Distribution    fillEquality
    ... child components ...
}
````
There are 2 kind of box component: VBox and HBox.


### Properties
|Name   |Type       |Description        |
|:--    |:--        |:--                |
|axis   |[Axis](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Enum/Axis.md)   |The axis to place child components. The VBox has `vertical` and the HBox has `horizontal`.|
|alignment |[Alignment](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Enum/Alignment.md) |The alignment of child cmponents. The HBox and VBox has different identifiers. |
|distribution |[Distribution](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Enum/Distribution.md) | The type of space between the box and child components. |


## Related links
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
