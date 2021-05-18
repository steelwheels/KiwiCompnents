# Table component
The table has N x M cells on it. 
There are 2 kinds of tables:

1. *Uniform table* : All N x M cells has same format. 
2. *Multi columns  table*: It has N columns. Each colums contain N rows. The cell format is defined for each columns.

## Syntax

### Uniform table
The number of cells are define by `rowCount` and `columnCount`.
In the below example, there are 10 x 20 cells.The format of the table cell is defined by `cell` property. The example has image cells.

The event function named `make` is used to set the contents of cell. The parameter `col` and `row` is used to tell the position of the cell to make.
````
table: Table {
    rowsCount:   Int 10
    columnCount: Int 20
    cell: Image: {
        name: String "null-image"
    }
    make: Event(col: Int, row: Int) %{
        self.image.name = "image-" + col + "x" + row ;
    %}
    pressed: Event(col: Int, row: Int) %{
        console.log("clicked col=" + col + ", row=" + row) ;
    %}
}
````

### Multi columns table
````
table: Columns {
    rowCount:  Int 10
    col0: Column {
        title:  String  "column-0"
        cell: Label {
            title:  String "default"
        }
        make: Event(row: Int) %{
            switch(row) {
              case 0:
                self.title = "a" ;
              break ;
            }
        %}
        pressed: Event(row: Int) %{
            console.log("[col0] clicked row=" + row) ;
        %}
    }
    col1: Column {
        title: String  "column-1"
        cell: Image {
            name: String "image-0"
        }
        make: Event(row: Int) %{
            ...
        %}
        pressed: Event(row: Int) %{
            console.log("[col1] clicked row=" + row) ;
        %}
    }
}

````

## Property values
|Property name  |Type   |Description        |
|:--            |:--    |:--                | 


## Reference
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
