# KSON: Extended JavaScript Object Notation
## Introduction
This document describes about the specification of
the _Kiwi Script Object Notation_.
The it is resemble to [JSON](https://www.json.org/json-en.html),
but it is extended to improve readability and writability.
There are modified points:
* The `//` comment is supported. The string between `//` and end-of-line will be ignored
* The double quotation for the property key is NOT required.
* Multi line string is supported. The string between `%{` and `%}` will be treated as string.

Here is the example of KSON data:
````
{   
        // This is object of Point class   
        class:  "Point",
        x:      10,
        y:      20,
        description: %{
                The point class is used to present
                point.
        %}
}
````

## Overview
Here is difference from JSON format.
### Comments
The context between `//` and newline (or end of file) is treated as comment. It will be removed by the parser.

### Properties
The property key is described by identifier instead of string.
````
{
        name: 10        // Do not use "name" for property name
}
````

### Multi line string
The text between `%{` and `%}` is treated as string value.
````
{
        function: %{
                (a: Int, b: Int) -> Int in
                        return a + b
        %}
}
````


## Syntax
The comment must be removed before parsing.
````
object          := '{' [properties] '}'
properties      := property
                |  properties ',' property
property        := identifier ':' value
value           := string
                |  text
                |  number
                |  object
                |  array
                |  bool
                |  'null'
array           := '[' [values] ']'
text            := '%{' ...any characters... '%}'
values          := value
                |  values ',' value

````

## Related links
* [Steel Wheels Project](https://steelwheels.github.io): The developer's web page
* [KiwiObject Framework](https://github.com/steelwheels/KiwiScript/tree/master/KiwiObject): The framework which contains this document
