# `leaveView` function
Switch current view to the previous view

## Prototype
````
leaveView(returnValue: Object)
````

## Description
The `leaveView` function switch the current view to the previous view.
The context of original view will be released by this function.

## Parameters(s)
|Name |Type |Description |
|:--  |:--  |:--         |
|returnValue |Object |The object which passed to the caller view. |

The parameter is used as the return value of the [enterView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/enterView.md) function call in the previous view.

## Return value
None. The operation after calling this function will NOT be executed because the view will be switched.

## References
* [Kiwi Component Framework](https://github.com/steelwheels/KiwiCompnents): Document of this framework.


