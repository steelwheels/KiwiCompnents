# Graphics 2D component
The 2D graphics drawer.  

## Syntax
````
grp: Graphics2D {
    // readable and writable
    width:          Int         component_width
    height:         Int         component_height
    size_x          Double      graphic_width
    size_y:         Double      graphic_height
    origin_x:       Double      graphic_origin_x
    origin_y:       Double      graphic_origin_y

    // read only
    status: AnimationState      state_of_animation

    // Function to draw bitmap
    draw: Event(context) %{
        // Code to support the button press event
    %}
}
````

|Property name  |Type       |Description        |
|:--            |:--        |:--                |
|status         |[AnimationState](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Enum/AnimationState.md)     |The state of animation    |

## Methods
### `draw` event function
The event function which is called when to draw the graphics.

|Parameter name |Type   |Description                    |
|:---           |:---   |:---                           |
|context        |[GraphicsContext](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/GraphicsContext.md)  |The interface object to draw 2D graphics  |

The parameter `context` is an instance of [GraphicsContext class](
https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/GraphicsContext.md).

## Built-in method
Following methods are defined as built-in method. 
You can call them in your JavaScript code:

### `start`
````
grp.start(interval: Double, endtime: Doble) ;
````
Start the animation. The `interval` is the period of the animation. And the `endtime` is time to run the animation.

### `stop`
````
grp.stop() ;
````

### `suspend`
````
grp.suspend() ;
````
Suspend the animation. It can be resumed by `resume` method.

### `resume`
````
grp.resume() ;
````
Resume the suspende anumation.

## Reference
* [GraphicsContext class](
https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/GraphicsContext.md): The object to draw 2D graphics.
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site


