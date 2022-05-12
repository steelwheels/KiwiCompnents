# Button component
The button to be pressed.

## Sample screen shot
![Button View](Images/button-view.png)

You can see the full implementation at [buttons.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/buttons.jspkg).

## Interface
````
interface Button
{
        title:                  string
        isEnabled:              boolean

        event pressed():        void
}
````

## Properties

|Property name  |Type       |Access |Description        |
|:--            |:--        |:-- |:--                |
|title          |string     |read/write |Label of button    |
|isEnabled      |boolean    |read/write |Activate/inactivate the button |

Some title string will be replaced by the symbol. It is called *special title*.

|Special title  |Image          |
|:--            |:--            |
|"<-"           |Left arrow     |
|"->"           |Right arrow    |

## Methods
### `pressed` event
This method will be called when the button is pressed by the user.
````
pressed: Event() %{
        ... event processing ...
%}
````

## Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site


