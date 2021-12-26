# Collection view component
The collection view is used to display multiple arranged images. The image can be selected by the user. 

The context of the view is defined as an instance of [Collection](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Collection.md) class.

## Syntax
````
collection: CollectionView {
    init: Init %{
        let col0 = Collection() ;
        let paths = [
                Symbols.chevronBackward,
                Symbols.chevronForward,
                Symbols.handRaised,
                Symbols.paintbrush
        ] ;
        col0.add("Header", "Footer", paths) ;
        self.store(col0) ;
    %}
}
````

This is the screenshot of this component:
![Collection View](./Images/collection-view.png)

In the above example, the instance of [Collection](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/Collection.md) class is allocated in `Init` method and stored by `store` method.


## Property values
|Property name  |Type   |Description        |
|:--            |:--    |:--                | 
|sectionCount   |Int    |Number of sections in the collection |
|isSelectable   |Bool   |User can select an item or not|

## Method

### `itemCount`
````
itemCount(secno: number): number
````
Return the count of items in the specified section by argument `secno`.
If the argument is not valid or there are no matched section, the return value will be 0.

# Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
