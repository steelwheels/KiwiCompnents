# Segue class
The segue class is used to switch GUI page.

## Global variable
The singleton object `segue` is defined for Segue class.

|Variable   |Class    | Description                     |
|:---       |:---     |:---                             |
|segue      |Segue    |Singleton object of Segue class  |

## `enter` method
Allocate new page and move to it.
````
segue.enter(URL("/url/of/view")) ;
segue.enter(name) ;
````

### Parameter(s)
The parameter can have String or URL type.

|Parameter  |Type   |Description                    |
|:---       |:---   |:---                           |
|url        |[URL](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/URL.md)    |URL of source script |
|name       |String |Identifier of the view item in Manifest file  |

The view name must be define in the [manifest file](https://github.com/steelwheels/JSTools/blob/master/Document/jspkg.md) in the source package.

## `leave` method
Return to previous page.
````
segue.leave() ;
````

### Parameter(s)
none

## References
* [Kiwi Component Framework](https://github.com/steelwheels/KiwiCompnents): Document of this framework.


