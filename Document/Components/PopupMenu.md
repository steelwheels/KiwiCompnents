# PopupMenu Component

## Sample
````
top: VBox {
    index: Int 0
    menu: PopupMenu {
        items: Array ["item-a", "item-b", "item-c"]
        selected: Event(index) %{
                console.print("selected = " + index + "\n") ;
                top.index = index ;
        %}
    }
    ok_button: Button {
        title:  String "OK"
        pressed: Event() %{
                console.print("pressed: OK -> " + top.index + "\n") ;
                leaveView(1) ;
        %}
    }
}
````

![Popup-menu View](./Images/popup-menu-view.png)

You can find the entire implementation at [popup-menu.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/popup-menu.jspkg).

### Properties
|Name   |Type           |Description                        |
|:--    |:--            |:--                                |
|items  |Array<String>  |Array of menu items                |
|index  |Int            |Index of selected item (read only) |

Note: The `index` property is read only. You can declare the property but the value will not set.

### Event functions
#### `selected` event
The function which is called when the user select the menu item.

````
menu0: PopupMenu {
    selected: Event(index) %{
    %}
}
````

#### Parameter(s)
|Name   |Type   |Description        |
|:--    |:--    |:--                |
|index  |Int    |Index of array of selected item   |

## Related links
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
