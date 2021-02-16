# PopupMenu Component

## Syntax
````
menu0: PopupMenu {
    items:          String          ["a", "b", "c"]
    selected: Event(selected_index) %{
    %}   
}
````

### Properties
|Name   |Type           |Description                |
|:--    |:--            |:--                        |
|items  |Array<String>  |Array of menu items        |

### Event functions
#### `selected` event
The function which is called when the user select the menu item.

#### Parameter(s)
|Name           |Type   |Description        |
|:--            |:--    |:--                |
|selected_index |Int    |Index of array of selected item   |

## Related links
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
