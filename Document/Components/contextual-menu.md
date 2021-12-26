# Contextual Menu

## Introduction
The contextual menu component is used to display pop up menu on the current window. User can select one menu item (labeled by text) from it.

## Interface
### Script
The class is `PopupMenu`. It has array of menu item labeld in it.
````
{
        class: "PopMenu",
        content: [
                {id: 0, label: "menu-item-1"},
                {id: 1, label: "menu-item-2"}
        ]
}
````

### Input
none

### Output
The id of selected menu item is outputted after user select it.
````
{
        selected_id: 1      // value == if of selected item
}
````


## Related links
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
