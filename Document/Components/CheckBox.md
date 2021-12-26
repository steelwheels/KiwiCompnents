# CheckBox component
The check box to toggle ON/OFF value.

## Syntax
````
box: CheckBox {
    isEnabled:  Bool true,
    title:      String "Button title",
    pressed: Event(status: Bool) %{
        console.log("status = " status) ;
    %}
}
````

## Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site


