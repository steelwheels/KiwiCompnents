# AddressBook

The addressbook database module does not have the view. This databased is accessed by functions of the other components.

In usually, the addressbook is implemented in Card view.
The `index` property of the card view is used to access records in the addressbook.

## Sample
````
op: Card {
  db: AddressBook {
    // Select the record by the index property of Card view
    index: Int Listner(idx: top.index) %{
      return idx ;
    %}
  }
  nameField: LabeledBox {
    title: String "Name"
    names: HBox {
      familyName: TextField {
          // Listen the update of record
          text: String Listner(record: top.db.record) %{
            // get the family name from the addressbook record
            return record.familyName ;
          %}
      }
      ...
    }
  }
}
````

You can see the entire script at [addressbook.jspkg](https://github.com/steelwheels/JSTerminal/tree/master/Resource/Sample/addressbook.jspkg).

## Properties
|Property name  |Type       |Description        |
|:--            |:--        |:--                |
|index          |number     |Index number to select record in the database. |
|count          |number     |The number of records in the database |
|record         |[ContactRecord](https://github.com/steelwheels/KiwiScript/blob/master/KiwiLibrary/Document/Class/ContactRecord.md) |The record indexed by `index`. |

The interface of `ContactRecord` for TypeScript is defined as `ContactRecordIF`.

## Reference
* [Library](https://github.com/steelwheels/KiwiCompnents/blob/master/Document/Library.md): The list of components. 
* [README](https://github.com/steelwheels/KiwiCompnents): Top page of KiwiComponents project.
* [Steel Wheels Project](https://steelwheels.github.io): Developer's web site
