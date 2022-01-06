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
        let table = ValueTable() ;
        ...

        // Load into table
        self.store(table) ;
    %}
    pressed: Event(col: Int, row: Int) %{
        console.log("clicked col=" + col + ", row=" + row) ;
    %}
}
````

![Table View](./Images/table-view.png)

## Property values
|Property name  |Type   |Description        |
|:--            |:--    |:--                | 
|rowCount       |Int    |Number of rows in table (Reference only)|
|columnCount    |Int    |Number of columns in table (Reference only)|
|hasHeader      |Bool   |The visibility of column title view|

## Method

### `pressed`
The event method to accept clicked event:
````
pressed: Event(col: Int, row: Int) %{
%}
````
The parameter is `col` and `row` which presents the location of clicked cell.

# Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site

