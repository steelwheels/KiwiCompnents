# TableData component
The table has N x M cells on it. 
Each cells have immediate (such as number, string) values.

## Syntax
````
table: Table
{
        storage:        "storage-name"
        path:           "path-expression"

        recordCount:    number
        fieldNames:     [string]
        update:         number

        fieldName(index: number): string | null
        
        newRecord(): RecordIF 
        record(index: number): RecordIF | null
        append(record: RecordIF)
        search(field: string, value: any): [RecordIf]
}
````

### Properties
|Name   |Type   |Attribute      |Description            |
|---    |---    |---            |----                   |
|storage |string |get             |Storage name           |
|path   |string |get             |Path in the storage    |
|recordCount  |number    |get            |Count of key-value pair in the 
|fieldNames |[string] |get |all field names |
|update |number |get |Update count |

### Methods
#### `fieldname`
````
fieldName(index: number): string | null  
````

#### `newRecord`
````
newRecord(): RecordIF 
````

#### `record`
````
record(index: number): RecordIF | null
````

#### `append`
````
append(record: RecordIF)
````

#### `search`
````
search(field: string, value: any): [RecordIf]
````

## Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site

