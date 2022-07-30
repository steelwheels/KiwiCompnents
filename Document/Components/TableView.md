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
        // setup
        hasHeader:              boolean ;
        isEditable:             boolean ;
        fieldNames: [
                {field:"field_0", title:"title-0"},
                {field:"field_1", title:"title-1"},
                ...
        ]
        virtualFields: {
                column_name0:   func(self: TableView, record: RecordIF)
                column_name1:   func(self: TableView, record: RecordIF)
                ...
        }
        filter:                 func(self: TableView, record: RecordIF): boolean ;
        isEnable:               func(self: TableView, record: RecordIF): boolean ;
        sortOrder:              SortOrder ;
        compare:                event(rec0: RecordIF, rec1: RecordIf): ComparisonResult ;

        dataTable:              TableIF ;

        // status
        readonly recordCount:   number ;
        readonly rowCount:      number ;
        selectedRecord():       RecordIF | null ;

        // events
        didSelected:            boolean ;
        pressed:                func(column: string, row: int) ;

        // edit        
        removeSelectedRecord(): boolean ;
        reload():               boolean ;      
}
````

### Field names
The `fieldNames` property defines the pair of field name of the record and the column title of the table view.

For example, following property defines the 2 column titles named "Name" and "Hit point". The value for each fields are loaded from "name" and "hitPoint" field in the source table.

````
fieldNames: [
        {title:"Name",      field:"name"},
        {title:"Hit point", field:"hitPoint"}
]
````

### Virtual fields
In usually, the value for each field cell are given by source table (set by `dataTable` property).
In this case, the `field` value in `fieldNames` propery will matche to the `field` name of source table.

You can define extra fields which is not contained in source table. Such field is called `virtual field`.
The `virtualFields` property define functions to caclulate the value for each virtual fields.

In the following example, the source table have "a", "b" field. The virtual field "sum" is calculated by `sun` function. 
````
table: TableView {
        fieldNames: [
                {field: "a",   title: "Column-A"},
                {field: "b",   title: "Column-B"}
                {field: "sum", title: "A+B"}
        ],
        virtualFields: {
                sum: Func(self, record) %{
                        return record.a + record.b ;
                %}
        }
}
````

## Property values
|Property name  |Type   |Description        |
|:--            |:--    |:--                | 
|dataTable      |[TableIF](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Table.md)  |Source data table. It can be loaded by `reload` method. |
|hasHeader      |boolean   |The visibility of column title at the top of table view|
|recordCount       |int    |Number of records in table (Read only)|
|rowCount 			|int    |Minimum umber of visible rows|
|isEditable     |boolean |Set editable or not |
|isDirty        |boolean |The table data is modifed. Call `save` method of `data table` to cleanup (Read only). |
|didSelected    |boolean |This value will true when the use selecs 1 or more rows in the table. |


## Structured property

### `fieldNames`
Define the correspondence between field name and column name. The field name must be defined as the label in the [Data Table](https://github.com/steelwheels/Coconut/blob/master/CoconutData/Source/Data/CNTable.swifts).

All field names (and column titles) must be defined to be visible in the table.

````
fieldNames: [
        {field:"field_0", title:"title-0"},
        {field:"field_1", title:"title-1"},
        ...
]
````

### `virtualFields`
This property will have dictionary:
* The key is string for virtual field name
* The value is function to calculate value for above key.

## Method

### `reload`
Replace entire data in the table. If you update the `dataTable` property, call this method.
```
reload(): boolean
```

### `selectedRecord`
Return the selected record object ([RecordIF](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Record.md)). If there are no seleted records, this value will be `null`.
````
selectedRecord(): RecordIF | null ;
````

### `removeSelectedRecord`
Remove the user selected record.
````
removeSelectedRecord(): boolean
````

### `filter`
The method to show the record or not. The table show the records whose return value is true.

````
Func(self: TableView, record: RecordIF) %{
        return true /* or false */ ;
%}
````

In the following example, only the record
whose field `isVisible` value is true:
````
filter: Func(self, record) %{
        return record.isVisible ;
%}
````

 See the [RecordIF](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Record.md).

### `pressed`
The event method to accept clicked event:
````
pressed: Event(col: string, row: number) %{
%}
````
The `col` is the field name of the clicked record and the `row` is the index number of record.

# Reference
* [TableIF](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Table.md): The data table in thie view 
* [RecordIF](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Record.md) : The data record in the data table
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site

