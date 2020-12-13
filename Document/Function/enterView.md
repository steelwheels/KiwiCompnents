# `enterView` function
Allocate new view and switch the current view to it.

## Prototype
````
enterView(viewName: String, callback: function(){ }) 
````

## Description
The `enterView` function allocate new view from the given script file and switch the view from the current to new one.
The callback function is called when the new view is closed.

## Parameter(s)
The parameter can have some different data type to give the location of script file.

|Name      |Type   |Description                        |
|:--       |:--    |:--                                |
|viewName  |String |The name of view component. The name must be define in `subviews` section in the `manifest.json` file.|
|callback  |func(val){ } |The callback function. The parameter is defined as a parameter of [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md). |

## Return value
none

## Example
The following script allocate the new.
````
enterView("NewView", function(retval){
	console.log("The new view is closed with return value: " + retval) ;
}) ;
````

## References
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): Library for GUI programming by Amber.
* [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md): Return to previous view
* [Kiwi Component Framework](https://github.com/steelwheels/KiwiCompnents): Document of this framework.


