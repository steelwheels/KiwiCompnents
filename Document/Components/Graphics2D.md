# Graphics 2D component
The 2D graphics drawer.  

## Syntax
````
grp: Graphics2D {
    width:          Int         component_width
    height:         Int         component_height
    size_x          Double      graphic_width
    size_y:         Double      graphic_height
    origin_x:       Double      graphic_origin_x
    origin_y:       Double      graphic_origin_y
    draw: Event(context) %{
        // Code to support the button press event
    %}
}
````

## Methods
### `draw` event function
The event function which is called when to draw the graphics.

|Parameter name |Type   |Description                    |
|:---           |:---   |:---                           |
|context        |[GraphicsContext](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/GraphicsContext.md)  |The interface object to draw 2D graphics  |

The parameter `context` is an instance of [GraphicsContext class](
https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/GraphicsContext.md).

## Reference
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [GraphicsContext class](
https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/GraphicsContext.md): The object to draw 2D graphics.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site


