# TableView component
The table view is used to present the content of database. 
The content of the table will be given by [ValueTable](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/ValueTable.md) or
[ContactTable](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/ContactTable.md).

This is sample script and it's view:

![Table View](./Images/table-view.png)

You can see the entire script at [value-table-4.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/value-table-4.jspkg).

## Interface
````
Interface TableView {
        dataTable:              TableIF ;
        reload():               boolean ;

        hasHeader:              boolean ;
        fieldNames: [
                {field:"field_0", title:"title-0"},
                {field:"field_1", title:"title-1"},
                ...
        ]
        readonly rowCount:      int ;
        visibleRowCount:        int ;

        isSelectable:           boolean ;
        isEditable:             boolean ;
        readonly isDirty:       boolean ;

        didSelected:            boolean ;
        selectedRecords():      RecordIF[] ;
        removeSelectedRows():   boolean ;
       
        filter:                 func(record: RecordIF) ;
        pressed:                func(column: string, row: int) ;
        visibleFields: {
                column_name0:   func(self: TableView, record: RecordIF)
                column_name1:   func(self: TableView, record: RecordIF)
        }
}
````

## Property values
|Property name  |Type   |Description        |
|:--            |:--    |:--                | 
|dataTable      |[TableIF](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Table.md)  |Source data table. It can be loaded by `reload` method. |
|hasHeader      |boolean   |The visibility of column title at the top of table view|
|rowCount       |int    |Number of rows in table (Read only)|
|visibleRowCount |int    |Minimum umber of visible rows|
|isSelectable   |boolean |You can select row or not |
|isEditable     |boolean |Set editable or not |
|isDirty        |boolean |The table data is modifed. Call `save` method of `data table` to cleanup (Read only). |
|didSelected    |boolean |This value will true when the use selecs 1 or more rows in the table. |


## Structured property

### `fieldNames`
Define the correspondence between field name and column name. The field name must be defined as the label in the [Data Table](https://github.com/steelwheels/Coconut/blob/master/CoconutData/Source/Data/CNTable.swifts).

All field names (and column titles) must be defined to be visible in the table.

````
fieldNames: {
        {field:"field_0", title:"title-0"},
        {field:"field_1", title:"title-1"},
        ...
}
````

## Method

### `reload`
Replace entire data in the table. If you update the `dataTable` property, call this method.
```
reload(): boolean
```

### `selectedRecords`
Return the array of [RecordIF](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Record.md) objects. 
````
selectedRecords(): RecordIF[]
````

### `removeSelectedRows`
Remove the user selected rows.
````
removeSelectedRows(): boolean
````

### `filter`
The event method to show the record or not. The table show the records whose return value is true.
 See the [RecordIF](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Record.md).

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
The `col` is the field name of the clicked record and the `row` is the index number of record.

### `removeSelectedRows`
Delete the selected rows in the table.
`````
removeSelectedRows() ;
`````

# Reference
* [TableIF](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Table.md): The data table in thie view 
* [RecordIF](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Record.md) : The data record in the data table
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site

