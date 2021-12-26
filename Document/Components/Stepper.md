# Stepper component
The controller which to give the limited number.

![Stepper View](./Images/stepper-view.png)

## Syntax
````
stepper: Stepper {
        maxValue:     Float     10.0
        minValue:     Float      0.0
        currentValue: Float      1.0
        changed: Event(newval) %{
          console.log("changed: " + newval) ;
        %}
}
````

The `maxValue` and `minValue` defint the available range for the variable, `currentValue`. 
You can give the initial value to it. And the `changed` event is used to detect the change of the `currentValue`.

## Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site


