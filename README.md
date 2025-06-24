<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/Swift_Package_Manager-compatible-Green.svg?style=flat"></a>
<img src="https://img.shields.io/badge/iOS-iPadOS-blue?logo=swift"/>
<img src="https://img.shields.io/badge/Minimum-Swift_5.4-blue?logo=swift"/>
<img src="https://img.shields.io/badge/Minimum-iOS_14.0-blue"/>

**Grid View** is useful to show collection of views based on row and column.
You can create the grid based on column priority or row priority.

## Features
- Flexible as a SwiftUI View (can add padding, background color, etc)
- Easy to use & simple syntax
- Can use your custom view as an element in grid
- Can detect when scroll reached edge (with some limitations for now)

## How to Install
* [Swift Package Manager](https://swift.org/package-manager/):

```swift
dependencies: [
  .package(url: "https://github.com/rajabun/GridView.git", from: "1.0.0")
]
```
- Direct in XCode

  - Click file in menu bar then click Add Package Dependencies
  - Enter `https://github.com/rajabun/GridView.git` in Search or Enter Package URL
  - Select Dependency Rule `Up to Next Major Version` and Add to Project `Your target project`
  - Click Add Package
 
## Overview
There will be two method based on how the element of views will be filled

- **Row Priority**

This priority will prioritize elements to fill row first.
Then if row is reached maximum based on `maxRowElement`,
it will create a new row below the current row.

![GridView-Row_Priority](https://github.com/user-attachments/assets/43a9a16b-da41-4620-b734-e39e78754a8d)

- **Column Priority**

This priority will prioritize elements to fill column first.
Then if column is reached maximum based on `maxColumnElement`,
it will create a new column to the right of existing column.

![GridView-Column_Priority](https://github.com/user-attachments/assets/65631d87-3e3a-463d-a4a3-3d6b772d2efa)

## How to Use
- Use init with `maxColumnElement` to choose column priority.
- Use init with `maxRowElement` to choose row priority.

Example for GridView based on Column Priority
```swift
GridView(gridData: data,
         maxColumnElement: 3,
         columnPriorityAlignment: .top,
         rowSpacing: 8, columnSpacing: 8) { column in
         YourContentView(image: column.data.image,
                         title: column.data.title)
```
- `maxColumnElement` is the maximum amount of elements in a column
- `YourContentView` is your custom view.

To make this GridView scrollable, you can embed with a scroll view like this:
```swift
ScrollView(.horizontal) {
    GridView()
}
```

or you can use `makeGridScrollable` method like this:
```swift
GridView(gridData: data,
         maxRowElement: 3,
         rowPriorityAlignment: .top,
         rowSpacing: 8, columnSpacing: 8) { row in
         YourContentView(image: row.data.image,
                         title: row.data.title)
} paginationBlock: {
    YourCustomFunction()
}
.makeGridScrollable()
```

Function `makeGridScrollable()` will make grid view scrollable in two way (horizontal & vertical)

Use `paginationBlock` to trigger your custom function when scroll reached edge
> **Important**
>
> Trigger custom function when scroll reached edge currently only supported when:
>   - GridView with row priority is only stacked with other Views inside HStack.
>   - GridView with column priority is only stacked with other Views inside VStack.

Parameter `paginationBlock` already has a default empty value so this parameter can be skipped.

## Parameters

| Parameters | Overview
| ------- | -------
| **gridData** | Data for the grid content
| **maxRowElement** | Maximum amount of elements in a row
| **maxColumnElement** | Maximum amount of elements in a column
| **rowPriorityAlignment** | Priority alignment for amount of elements when row isn't fully filled
| **columnPriorityAlignment** | Priority alignment for amount of elements when column isn't fully filled
| **rowSpacing** | Spacing between rows
| **columnSpacing** | Spacing between columns
| **rowContentView** | View for each elements in rowPriority method
| **columnContentView** | View for each elements in columnPriority method
| **paginationBlock** | An action when scroll reached edge of scrolled grid view
| **isParentScrollDisabled** | Set this to true to make the view only have one way scroll*
| **isIndicatorShown** | For show/hide scroll indicator

*Only vertical scroll for row priority & only horizontal scroll for column priority.
