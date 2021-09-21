# Table component
The table is used to present the content of database. 
The database has multiple records in it.
The record contains multiple value data.
It is displayed in a row in the table.

## Syntax
````
table: Table {
    init: Init %{
       // Allocate table
       let table  = ContactTable() ;
       // ... setup data in the table ...
       // Load into table
       self.reload() ;
    %}
    rowsCount:   Int 10
    columnCount: Int 20
    pressed: Event(col: Int, row: Int) %{
        console.log("clicked col=" + col + ", row=" + row) ;
    %}
}
````

## Property values
|Property name  |Type   |Description        |
|:--            |:--    |:--                | 
|rowCount       |Int    |Number of rows in table |
|columnCount    |Int    |Number of columns in table |
|hasHeader      |Bool   |The visibility of column title view|
|isDirty        |Bool   |Presents the database is updated or not.|

## Method

### `load`
Reload the content of database into the table view.

### `clear`
Replace all values by `nil`.

### `pressed`
The event method to accept clicked event:
````
pressed: Event(col: Int, row: Int) %{
%}
````
The parameter is `col` and `row` which presents the location of clicked cell.

# Reference
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
