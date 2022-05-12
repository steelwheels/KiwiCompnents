# VBox, HBox, LabeledBox
Container of multiple child components.
The `HBox` component arranges multiple child components horizontally. The `VBox` component arranges vertically.
The `LabeledBox` component contains the `VBox` and the label text.

Every box components has the `axis` property. You can change the direction of child component of them.

## Sample screen shot

![Box View](Images/box-view.png)

You can find the full implementation at [Box.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/box.jspkg).

## Interface
````
interface *Box
{
        title:          string          // *1
        axis:           Axis
        alignment:      Alignment
        distribution:   Distribution        
}
````
*1) The `LabeledBox` has `title` property. Other boxes does not have it.

## Properties
|Name   |Type       |Access |Description        |
|:--    |:--        |:--    |:--                |
|title  |string     |read/write |Label of the button |
|axis   |[Axis](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Enum/Axis.md)   |read/write|The axis to place child components. The VBox has `vertical` and the HBox has `horizontal`.|
|alignment |[Alignment](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Enum/Alignment.md) |read/write |The alignment of child cmponents. The HBox and VBox has different identifiers. |
|distribution |[Distribution](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Enum/Distribution.md) |read/write |The type of space between the box and child components. |

## Related links
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
