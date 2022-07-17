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
|update |number |get |Update count |


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

## Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site

