# `enterView` function
Allocate new view and switch the current view to it.

## Prototype
````
enterView(viewName: String) -> Bool
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
If the entering view is suceeded, the return value will be `true`.

## References
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): Library for GUI programming by Amber.
* [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md): Return to previous view
* [Kiwi Component Framework](https://github.com/steelwheels/KiwiCompnents): Document of this framework.


