# waitUntilActivate
Wait until the view is activated.

## Prototype
````
waitUntilActivate() -> Object
````

## Description
Wait until the view is activated.

In usually, this function will be called after [enterView](ttps://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/enterView.md) function call. 
The return value is given as a parameter of [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md) function.

## Parameters
none

## Return value
The value given by [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md).

## Example
Here is view transition example:
![View Transition](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Images/view-transition.png)

## References
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): Library for GUI programming by Amber.
* [enterView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md): Move to new view
* [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md): Return to previous view
* [Kiwi Component Framework](https://github.com/steelwheels/KiwiCompnents): Document of this framework.
