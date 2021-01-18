# Table component
The table has N x M cells on it. 
There are 2 kinds of tables:

1. *Uniform table* : All N x M cells has same format. 
2. *Multi columns  table*: It has N columns. Each colums contain N rows. The cell format is defined for each columns.

## Syntax

### Uniform table
The number of cells are define by `rowCount` and `columnCount`.
In the below example, there are 20 x 10 cells. Every cell has an image in it.
The event function named `make` is used to set the values for each cell. The parameter `col` and `row` is used to tell the position of the cell to make.
````
table Table: {
    rowCount:    Int 10
    columnCount: Int 20
    image Image: {
        name: String "null-image"
    }
    make: Event(col, row) %{
        self.image.name = "image-" + col + "x" + row ;
    %}
}
````

### Multi columns table
````
table Columns : {
    rowCount:  Int 10
    col0: Column {
        title:  String  "column-0"
        label: Label {
            title:  String "default"
        }
        make: Event(row) %{
            switch(row) {
              case 0:
                self.label.title = "a" ;
              break ;
            }
        %}
    }
    col1: Column {
        title: String  "column-1"
        image: Image {
            name: String "image-0"
        }
        make: Event(row) %{
            ...
        %}
    }
}

````

## Property values
|Property name  |Type   |Description        |
|:--            |:--    |:--                | 
|text           |String |Content text       |
|isBezeled      |Bool   |Set bezele ON/OFF  |
|fontSize       |[FontSize](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Enum/FontSize.md) | Size of font |

## Reference
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
