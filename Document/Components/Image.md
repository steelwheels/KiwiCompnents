# Image component
The graphics image

## Sanple
````
img: Image {
  name:   String "amber"
  scale:  Float  0.5
}
````

![Image View](./Images/image-view.png)

You can see the full implementation at [image.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/image.jspkg).

## Properties
|Property name  |Type   |Description            |
|:--            |:--    |:--                    | 
|name           |string |Name of image          |
|scale          |number |Scale of the image. The default value is 1.0. |

The `name` must be defined in [manifest.json](https://github.com/steelwheels/JSTools/blob/master/Document/jspkg.md) as a part of image section.
The `scale` define the size of image in the view. The default value is 1.0.

## Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site


