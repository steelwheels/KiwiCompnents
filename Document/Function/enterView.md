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
The data type is `any` or `null`. You have to cast it.

## Example
This full implementation of this example is [enter-view.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/enter-view.jspkg).

This is main function:
````
function main(args)
{
	console.log("Hello, world !!") ;
         /* The return value will be given from
          * leaveView() function call in main view
          */
	let retval = enterView("main") ;
	console.log("from-main: " + retval) ;
}
````

This is main view:
````
top: VBox {
    enter_button: Button {
   	title: String "SubView"
	pressed: Event() %{
                /* The return value will be given from
                 * leaveView() function call in sub view
                 */
		let ret = enterView("sub") ;
		console.log("from-sub : " + ret) ;
        %}
    }
    quit_button: Button {
   	title: String "Quit"
	pressed: Event() %{
                /* This parameter will be passed to
                 * to main function.
                 */
		leaveView("Good bye main view") ;
        %}
    }
}
````

This is sub view:
````
top: VBox {
    quit_button: Button {
   	title: String "Quit"
	pressed: Event() %{
                /* This parameter will be passed to
                 * to main view.
                 */
		leaveView("Good bye sub view") ;
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


