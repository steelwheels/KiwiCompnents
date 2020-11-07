# waitUntilActivate
Wait until the view is activated.

## Prototype
````
waitUntilActivate() -> Object
````
Wait until the view is activated and return the parameter which is given as a parameter of [leaveView](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/leaveView.md) function.

In usually, this function will be called after [enterView](ttps://github.com/steelwheels/KiwiCompnents/blob/master/Document/Function/enterView.md) function call. 
Here is the example:

````
if(enterView("buttons")){
	let retval = waitUntilActivate() ;
	....
}
````
