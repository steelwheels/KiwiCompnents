# RadioButtons component
The button to select one from multiple items.

## Sample
````
top: VBox {
    radio0: RadioButtons {
        labels:      Array      ["a", "b", "c", "d"]
        isEnabled:   Array      [true, true, true, false]
        columnCount: Int        3
        selected: Event(newidx) %{
                console.print("new-index: " + newidx + "\n") ;
        %}
    }
    ...
}
````

You can see the full implementation at [radio-button.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/radio-button.jspkg).

![RadioButtons View](Images/radio-buttons.png)

## Properties

|Property name  |Type       |Description        |
|:--            |:--        |:--                |
|labels         |string[]   |Labels of radio buttons. This value *must be* defined in the script. And these value can not be changed. |
|isEnabled      |boolean[]    |Activate/inactivate the  corresponded button. If this is not given, all buttons will be enabled. |

## Methods
### `selected` event
This method will be called when the radio button is pressed by the user.
````
selected: Event(newidx) %{
        ... event processing ...
%}
````

The parameter `newidx` presents index number of pressed radio button.

## Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site


