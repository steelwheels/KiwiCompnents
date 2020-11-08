# `leaveView` function
Switch to the previous view

## Prototype
````
leaveView(returnValue: Object)
````

## Description
The `leaveView` function switch to the previous view. The function [enterView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/enterView.md) is used to switch to the new view. This function is used to return to the previous view.

## Parameters(s)
|Name |Type |Description |
|:--  |:--  |:--         |
|returnValue |Object |The object which passed to the caller view. |

The parameter is used as the return value. See [waitUntilActivate](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/waitUntilActivate.md) function.

## Return value
None. The operation after calling this function will NOT be executed because the view will be switched.

## Example
Here is view transition example:
![View Transition](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Images/view-transition.png)

## References
* [enterView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md): Move to new view
* [waitUntilActivate](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/waitUntilActivate.md): The function to wait until the view is activated.
* [Kiwi Component Framework](https://github.com/steelwheels/KiwiCompnents): Document of this framework.


