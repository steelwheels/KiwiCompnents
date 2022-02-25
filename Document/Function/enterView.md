# `enterView` function
Allocate new view and switch the current view to it.

## Prototype
The `enterView` function allocate new view. The new view will be selected by the name of the view.
````
enterView(name: string): any
````

## Parameter(s)
The parameter can have some different data type to give the location of script file.

|Name      |Type   |Description                        |
|:--       |:--    |:--                                |
|name      |string |The name of view component. The name must be define in `subviews` section in the [manifest file](https://github.com/steelwheels/JSTools/blob/master/Document/jspkg.md).|

## Return value
This value will be given as the parameter of [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md) function.
The data type is `any`. You have to know the type of return value of `enterView`.
It is defined by ｀leaveView` function which is corresponding to it.

## Example
This full implementation of this example is [enter-view.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/enter-view.jspkg).


This is main-view. The return value of `enterView` function is
given by `leaveView` function in sub-view. 
The variable `ret` will have following object:
`{message: string, a: number, b: number}`.

````
top: VBox {
    enter_button: Button {
   	title: String "SubView"
	pressed: Event() %{
		let ret = enterView("sub") ;
		console.log("message: " + ret.message
                        + ", a = " + ret.a 
                        + ", b = " + ret.b
                ) ;
        %}
    }
    ...
}
````

This is sub view. The `leaveView' function

````
top: VBox {
    quit_button: Button {
   	title: String "Quit"
	pressed: Event() %{
		leaveView({
                  message: "Good bye sub view",
                  a: 10,
                  b: 20
                }) ;
        %}
    }
}
````

Execution result:
````
jsh> run
Hello, world !!
from-sub : Good bye sub view
from-main: Good bye main view
jsh> 
````

## References
programming by Amber.
* [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md): Return to previous view
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): Library for GUI 
* [Kiwi Component Framework](https://github.com/steelwheels/KiwiCompnents): Document of this framework.


