# DictionaryData component
This component operate [dictionary data](https://developer.apple.com/documentation/swift/dictionary).
The content data is mappend on the [storage](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Storage/Storage.md).
The [procedural class](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Dictionary.md) is also defined.

## Declaration
````
table: Dictionary
{
        storage:        "storage-name"
        path:           "path-expression"
        
        count:          number
        keys:           [string]
        values:         [any]
        update:         number
        dictionary:     [string:any]

        value(index: number): any | null
        set(value: any, forKey: string)
}
````

### Properties
|Name   |Type   |Attribute      |Description            |
|---    |---    |---            |----                   |
|storage |string |get             |Storage name           |
|path   |string |get             |Path in the storage    |
|count  |number    |get            |Count of key-value pair in the dictionary |
|keys           |[string] |get |Array of keys in the dictionary   |
|values         |[any]    |get  |Array of values in the dictionary |
|dictionary |[string:any] |get |Return the dictionary. You can access for each members by '`.`' expression |
|update |number |get |Update count |

#### `dictionary` property

### Methods
#### `value`
````
value(forKey: string): any | null
````
Get the value for the given key. If the value is not found, the return value will be null. 

#### `set`
````
set(value: any, forKey: string)
````
Set the value for key.

## Example
See the sample script, [dict-data-0.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/dict-data-0.jspkg).

This is the contents of storage file. This is registered in [manifest file](https://github.com/steelwheels/JSTools/blob/master/Document/jspkg.md).
````
{
	dict0: {
		a:	true,
		b:	12,
		c:	"c"
	}
}
````

This is the component declaration of dictionary storage. The storage name and the path is used to decide the location of dictionary data.
````
{
        dict: Dictionary {
                storage: "storage"
                path:    "dict0"
        }
}
````

To access the property in the dictionary, you can use `set`. `get` and `.`:
````
dict.set(10, "a") ;     // set 10 to the property "a"
dict.get("b") ;         // get the value of property "b"
dict.dictionary.a ;     // get the value of property "a"
````

You can use the dictionary for the parameter of [listner function](https://github.com/steelwheels/Amber/blob/master/Document/amber-language.md). You *can not* describe the property name.

````
// OK
isEnable: Listner(dict: dict.dictionary) %{
        return dict.a ;
%}

// Error (Not supported)
isEnable: Listner(a: dict.dictionary.a) %{
        return a ;
%}
````

## Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site

