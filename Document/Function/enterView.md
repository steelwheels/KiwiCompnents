# `enterView` function
Allocate new view and switch the current view to it.

## Prototype
````
enterView(name: string): number
````

## Description
The `enterView` function allocate new view. The new view will be selected by the name of the view.

## Parameter(s)
The parameter can have some different data type to give the location of script file.

|Name      |Type   |Description                        |
|:--       |:--    |:--                                |
|name      |string |The name of view component. The name must be define in `subviews` section in the [manifest file](https://github.com/steelwheels/JSTools/blob/master/Document/jspkg.md).|

## Return value
The integer value. The zero values means there are no error.

## Example
The following script allocate the new.
````
let retval:number = enterView("new_view") ;
if(retval == 0){
        console.log("No error") ;
} else {
        console.log("Some error: " + retval) ;
}
````

## References
programming by Amber.
* [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md): Return to previous view
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): Library for GUI 
* [Kiwi Component Framework](https://github.com/steelwheels/KiwiCompnents): Document of this framework.


