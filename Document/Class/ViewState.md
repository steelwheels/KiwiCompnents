# ViewState class
The *ViewState* class is type of return value of [enterView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/enterView.md). The instance is used to know the status of the view which is allocated by `enterView` function.

The `enterView` allocate new view on the terminal.
So the caller process become invisible process under the view.
In usually, the caller process wait until the new view is closed and the return value from it.

## `readyToReturn` property
````
var readyToReturn: Bool { get }
````
When the process in the new view store the return value by [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md) function. The return value will become true.

## `returnValue` property
````
var returnValue: Object { get }
````
The return value from the new view. This value is set by the process in new view. This value is valid when the `readyToReturn` becomes true.

## Examples
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

# References
* [KiwiComponent](https://github.com/steelwheels/KiwiCompnents/blob/master/README.md): The framework which has this document.


