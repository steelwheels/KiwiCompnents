# Bitmap component
The 2D bitmap drawer.  The [bitmap context](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/BitmapContext.md) is used to set/get pixel in the bitmap. The `draw` method is called to draw/update the bitmap. It is called periodically. The calling is controlled by `start`, `stop`, `suspend`, `resume` methods.

## Samble screen shot

![Bitmap View](Images/bitmap-view.png)

You can see the full implementation at [bitmap.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/bitmap.jspkg).

## Interface

````
interface Bitmap
{
        readonly width:         float
        readonly height:        float
        rowCount:               int
        columnCount:            int

        readonly state:         AnimationState

        func start(duration, repeat):   void
        func stop():                    void
        func suspend():                 void
        func resume():                  void

        event draw(context, count): void
}
````

## Properties

|Property name  |Type       |Access     |Description        |
|:--            |:--        |:--        |:--                |
|width          |number     |readonly   |The width of view |
|height         |number     |readonly   |The height of view  |
|rowCount       |number     |read/write |The number of pixels on the row of bitmap |
|columnCount    |number     |read/write |The number of pixels on the column of bitmap |
|status         |[AnimationState](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Enum/AnimationState.md)     |readonly   |The state of animation|


## Methods
### `start` method
Call this method to start context drawing.
````
start(duration:number, repeat:number) %{
        ...
%}
````
|Parameter name |Type       |Description        |
|:--            |:--        |:--                |
|duration       |number     |The interval for each animation frames. You can give floating point value. The unit is second. |
|repeat         |number     |Integer number to present repeat counts. |

### `stop` method
Stop the animation. The animation state will be initialized.

### `suspend` method
Stop the animation tempollary. It will be restarted `resume` method call.

### `resume` method
Restart the animation which is stopped by `suspend` method.

### `draw` event function
The event function which is called when to draw the graphics.

````
{
    draw: Event(context, count) %{
    %}
}
````

|Parameter name |Type   |Description                    |
|:---           |:---   |:---                           |
|context        |[GraphicsContext](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/GraphicsContext.md)  |The interface object to draw 2D graphics  |

The parameter `context` is an instance of [GraphicsContext class](
https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/GraphicsContext.md).

## Reference
* [Bitmap context](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/BitmapContext.md): The bitmap to draw the 2D bitmap graphics. 
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site


