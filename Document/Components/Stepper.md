# Stepper component
The controller which to give the limited number.

## Syntax
````
 stepper0: Stepper {
  maxValue:      Float    10.0
  minValue:      Float     0.0
  deltaValue:    Float     0.1
  currentValue:  Float     1.0
  decimalPlaces: Int       2
  changed: Event(newval) %{
    console.log("changed: " + newval) ;
  %}
}
````

![Stepper View](./Images/stepper-view.png)

You can find the full implementation of above script at [stepper.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/stepper.jspkg).

## Properties
The `maxValue` and `minValue` defint the available range for the variable, `currentValue`. 
You can give the initial value to it. And the `changed` event is used to detect the change of the `currentValue`.

## Methods

# Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site


