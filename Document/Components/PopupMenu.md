# PopupMenu Component

## Sample screen shot

![Popup-menu View](./Images/popup-menu-view.png)

You can find the entire implementation at [popup-menu.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/popup-menu.jspkg).

## Interface
````
Interface PopupMenu {
        items:  Array<MenuItem> ; // *1
        value:  any ;

        selected(value: any) ;
        addItem(title: string, value: any) ;
}

MenuItem := {title: "title", value: val } ;
````

### Properties
|Name   |Type           |Description                    |
|:--    |:--            |:--                            |
|items  |[MenuItem]     |Array of menu items            |
|value  |any            |The "value" property of selected menu item|

The `MenuItem` is dictionary which has `title` and `value` property. the string value of `title` property will be a title of popup menu ite. The value of `value` is used as the *selected* value of the menu item.


### Event functions
#### `selected` event
The function which is called when the user select the menu item.
````
selected: Event(value) %{
%}
````
#### Parameter(s)
|Name   |Type   |Description        |
|:--    |:--    |:--                |
|value  |any    |The value of the current selected menu item |

#### `addItem` method
The method to append popup menu item.
````
addItem: Func(title: string, value: any) %{
%}
````

#### Parameter(s)
|Name   |Type   |Description        |
|:--    |:--    |:--                |
|title  |string |The title of the menu item to append           |
|value  |any    |The value which is associated to the title     |

## Related links
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
