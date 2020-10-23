# `enterView` function
Allocate new view and switch the current view to it.

## Prototype
````
enterView(viewName: String) -> Object
enterView(scriptPath: String) -> Object
enterView(scruotURL: URL) -> Object
````

## Description
The `enterView` function allocate new view from the given script file and switch the view from the current to new one.

## Parameter(s)
The parameter can have some different data type to give the location of script file.

|Type   |Description                        |
|:--    |:--                                |
|String |The name of view component. The path of the script will be searched in the `view` category in the [manifest file](https://github.com/steelwheels/JSTools/blob/master/Document/jspkg.md). The name must not be ended by `.amb`.|
|String |The path of the script file. The extension `.amb` must be given. If the path is relative path, it will be normalized by the current directory of the application. |
|[URL](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/URL.md) | URL of the source script. |

## Return value
This function is finished by the [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md) function function call in the new view. The return value will be given as the parameer of the `leaveView` function.

## References
* [Kiwi Component Framework](https://github.com/steelwheels/KiwiCompnents): Document of this framework.


