# Collection view component
The collection view is used to display multiple arranged images. The image can be selected by the user. 

The context of the view is defined as an instance of [Collection](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Collection.md) class.

## Sanple screen shot
![Collection View](./Images/collection-view.png)

You can see the entire script at [checkbox.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/collection1.jspkg).

The instance of [Collection](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Collection.md) class is allocated in `Init` method and stored by `store` method.

You can see the entire script at [collection1.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/collection1.jspkg).

## Interface
````
interface CollectionView
{
        sectionCount:   int
        isSelectable:   boolean

        func  itemCount(section):       number
        event selected(section, item):  void
        func  store(collection):        void
}
````

## Properties
|Property name  |Type   |Access |Description        |
|:--            |:--    |:--    |:--                | 
|sectionCount   |number |readonly |Number of sections in the collection |
|isSelectable   |Bool   |readonly |User can select an item or not|

## Method

### `itemCount`
Return the count of items in the specified section by argument `secno`.
If the argument is not valid or there are no matched section, the return value will be 0.
````
itemCount(secno: number): number
````

### `selected` method
This function will be called when the use click select new item in the collection view.
````
selected: Event(section, item) %{
%}
````

|Property name  |Type   |Description        |
|:--            |:--    |:--                | 
|section        |number |Section number of clicked cell |
|item           |number |Item number of clicked cell |

### `store` method
In usually, this method is called in the function.
````
init: Init %{
        self.store(db) ;
%}
````

|Property name  |Type   |Description        |
|:--            |:--    |:--                | 
|db             |[Collection](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Collection.md) |The database of collection data |

# Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
