# `enterView` function
Allocate new view and switch the current view to it.

## Prototype
````
enterView(viewName: String) -> ViewState
````

## Description
The `enterView` function allocate new view from the given script file and switch the view from the current to new one.

To return to the previous view, use [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md) function.

## Parameter(s)
The parameter can have some different data type to give the location of script file.

|Name      |Type   |Description                        |
|:--       |:--    |:--                                |
|viewName  |String |The name of view component. The name must be define in `subviews` section in the `manifest.json` file.|

## Return value
The instance of [ViewState](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Class/ViewState.md) class.
It tells the state of new view to caller process.

## Example
The following script allocate the new view and wait until it is closed.
````
/* Allocate new view and get the ViewState object */
let viewstate = enterView("NewView") ;

/* Wait until the return value is stored */
while(!viewstate.readyToRun) {
    sleep(0.5) ;
}

/* Get the result value from the new view */
let result = viewState.returnValue ;

````

## References
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): Library for GUI programming by Amber.
* [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md): Return to previous view
* [waitUntilActivate](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/waitUntilActivate.md): The function to wait until the view is activated.
* [Kiwi Component Framework](https://github.com/steelwheels/KiwiCompnents): Document of this framework.


