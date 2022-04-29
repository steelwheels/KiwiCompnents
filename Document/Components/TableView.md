# TableView component
The table view is used to present the content of database. 
The content of the table will be given by [ValueTable](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/ValueTable.md) or
[ContactTable](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/ContactTable.md).

This is sample script and it's view:
````
top: VBox {
    top: VBox {
    table: TableView {
	hasHeader: Bool true
        isSelectable: Bool true
        visibleRowCount: Int 8
        fieldNames: Array [
                {field:"c0", title:"column 0"},
                {field:"c1", title:"column 1"},
                {field:"c2", title:"column 2"}
        ]
        init: Init %{
                let storage = Storage("storage") ;
                if(storage == null){
                        console.log("Failed to allocate storage") ;
                }
                let table = Table("root", storage) ;
                if(table == null){
                        console.log("Failed to allocate table") ;
                }
                // Load table into this view
                self.reload(table) ;
        %}
        filter: Event(record) %{
                return true ; // select all rows
        %}
        pressed: Event(row, col) %{
                console.log("row    = " + row + "/" + self.rowCount) ;
                console.log("column = " + col + "/" + self.columnCount) ;
        %}
    }
    selected_button: Button {
	title: String "Selected"
	isEnabled: Bool Listner(selected: top.table.didSelected) %{
		return selected ;
	%}
        pressed: Event() %{
                top.table.removeSelectedRows() ;
        %}
    }
}
````

![Table View](./Images/table-view.png)

You can see the entire script at [value-table-4.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/value-table-4.jspkg).

## Syntax

## Property values
|Property name  |Type   |Description        |
|:--            |:--    |:--                | 
|didSelected    |Bool   |Has true when the row of table is selected. |
|fieldNames     |Array  |Active field names |
|hasHeader      |Bool   |The visibility of column title view|
|rowCount       |Int    |Number of rows in table (Read only)|
|isSelectable   |Bool   |You can select row or not |
|selectedRows   |number[] | Array of row numbers (Read only)|
|visibleRowCount |Int    |Minimum umber of visible rows|

The `fieldNames` property used to decide following thigs:
* Choose the fields in the record. These fields are displayed in the table.
* Set the column names for each field names. The column name is displayed in the header of the table.

The `fieldNames` is an array of following objects:
````
{
  field:  "c0"    // Field name in the record
  title:  "col0"  // Visible column name
}
````

In usually, the `didSelected` property will be listned by the other component to tell the state of the table.

## Method

### `reload`
Replace entire data in the table.
```
reload(table: TableIF) ;
```
See the definition of [TableIF](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/ValueTable.md).

### `filter`
The event method to select the record or not. The table selects the records whose return value is true.
````
filter: Event(record: RecordIF) %{
        return true /* or false */ ;
%}
````

### `pressed`
The event method to accept clicked event:
````
pressed: Event(col: string, row: number) %{
%}
````
The parameter `col` is clicked column name.
The `row` is row number.

### `removeSelectedRows`
Delete the selected rows in the table.
`````
removeSelectedRows() ;
`````

## Note
In the above example, the contents of [ValueTable](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/ValueTable.md) is displayed in the view.
The value table uses [Storage](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Storage.md) to construct it.

# Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site

