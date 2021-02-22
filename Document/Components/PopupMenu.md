# PopupMenu Component

## Syntax
````
menu0: PopupMenu {
    items:          String          ["a", "b", "c"]
    index:          Int             0
    selected: Event(selected_index) %{
    %}   
}
````

### Properties
|Name   |Type           |Description                        |
|:--    |:--            |:--                                |
|items  |Array<String>  |Array of menu items                |
|index  |Int            |Index of selected item (read only) |

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
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
