# Data table component
The table has N x M cells on it. 
Each cells have immediate (such as number, string) values.

## Syntax
````
table: DataTable {
        init: Init %{
                let table = self.table ; // Table object.
                table.setValue(0, 0, "(0,0)") ;
                ...
                self.reload() ; // Update the component
        %}
}
````

You can define the initial value of the table by the script in the `init` method. The `table` property of this component is used to access the table data.

The `table` property is an instance of [Table class](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Table.md). This class has the methods to access value in the table. The `load`/`store` operation from/to file is also supported by this class.

After modification of the table, you have to call `reload` method to tell the end of data modification to the component.

### Properties
|Name   |Type       |Description        |
|:--    |:--        |:--                |
|table  |[Table](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Table.md) |The data to present the cell values in the table |

### Methods
#### `reload(void): void`
Tell the modification of `table` property is finished.

## Reference
* [Table class](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Table.md): The class to present the data in the data table component. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
