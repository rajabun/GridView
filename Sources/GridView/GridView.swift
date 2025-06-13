//
//  GridView.swift
//  GridView
//
//  Created by Muhammad Rajab on 04-06-2025.
//  Copyright © 2025 Muhammad Rajab. All rights reserved.
//

import SwiftUI

/// Collection of views based on row and column
///
/// Grid View is useful to show collection of views based on row and column.
/// You can create the grid based on column priority or row priority.
///
/// Column priority will prioritize elements to fill column first,
/// then if column is reached maximum based on `maxColumnElement`
/// it will create a new column to the right of the existing column
///
/// Row priority will prioritize elements to fill row first,
/// then if row is reached maximum based on `maxRowElement`
/// it will create a new row below the current row
///
/// Use init with `maxColumnElement` to choose column priority and
/// use init with `maxRowElement` to choose row priority.
///
/// Below is an example to create grid view based on column priority:
///
///     var body: some View {
///         GridView(gridData: data,
///                  maxColumnElement: 3,
///                  columnPriorityAlignment: .top,
///                  rowSpacing: 8, columnSpacing: 8) { column in
///                  YourContentView(image: column.data.image,
///                                  title: column.data.title)
///         }
///     }
/// `YourContentView` is your custom view.
///
@available(iOS 13.0, *)
public struct GridView<Content: View, T: Hashable>: View {
    @ViewBuilder var rowContentView: (GridDataModel<T>) -> any View
    @ViewBuilder var columnContentView: (GridDataModel<T>) -> any View
    var gridData: GridDataManager<T>
    var rowPriorityAlignment: HorizontalAlignment
    var columnPriorityAlignment: VerticalAlignment
    var rowSpacing: CGFloat
    var columnSpacing: CGFloat
    
    /// Use this to make the grid prioritize the row to be filled.
    ///
    /// - Parameter gridData: Data for the grid content
    /// - Parameter maxRowElement: Maximum amount of elements in a row
    /// - Parameter rowPriorityAlignment: Priority alignment for amount of elements when row isn't fully filled
    /// - Parameter rowSpacing: Spacing between rows
    /// - Parameter columnSpacing: Spacing between columns
    /// - Parameter rowContentView: View for each elements
    public init(gridData: [T],
                maxRowElement: Int,
                rowPriorityAlignment: HorizontalAlignment,
                rowSpacing: CGFloat, columnSpacing: CGFloat,
                rowContentView: @escaping (GridDataModel<T>) -> Content) {
        self.columnContentView = { _ in AnyView(HStack { Text("Empty") })}
        self.columnPriorityAlignment = .top
        self.gridData = GridDataManager(isRowPriority: true,
                                        isColumnPriority: false,
                                        maxRowElement: maxRowElement,
                                        maxColumnElement: 0,
                                        data: gridData)
        self.rowPriorityAlignment = rowPriorityAlignment
        self.rowSpacing = rowSpacing
        self.columnSpacing = columnSpacing
        self.rowContentView = rowContentView
    }
    
    /// Use this to make the grid prioritize the column to be filled.
    ///
    /// - Parameter gridData: Data for the grid content
    /// - Parameter maxColumnElement: Maximum amount of elements in a column
    /// - Parameter columnPriorityAlignment: Priority alignment for amount of elements when column isn't fully filled
    /// - Parameter rowSpacing: Spacing between rows
    /// - Parameter columnSpacing: Spacing between columns
    /// - Parameter columnContentView: View for each elements
    public init(gridData: [T],
                maxColumnElement: Int,
                columnPriorityAlignment: VerticalAlignment,
                rowSpacing: CGFloat, columnSpacing: CGFloat,
                columnContentView: @escaping (GridDataModel<T>) -> Content) {
        self.rowContentView = { _ in AnyView(VStack { Text("Empty") })}
        self.rowPriorityAlignment = .trailing
        self.gridData = GridDataManager(isRowPriority: false,
                                        isColumnPriority: true,
                                        maxRowElement: 0,
                                        maxColumnElement: maxColumnElement,
                                        data: gridData)
        self.columnPriorityAlignment = columnPriorityAlignment
        self.rowSpacing = rowSpacing
        self.columnSpacing = columnSpacing
        self.columnContentView = columnContentView
    }
    
    public var body: some View {
        if #available(iOS 14.0, *) {
            lazyLoadContentView()
        } else {
            contentView()
        }
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        if gridData.accessIsRowPriority() {
            VStack(alignment: rowPriorityAlignment, spacing: rowSpacing) { //HStack for based on Column, VStack for Row
                ForEach(Array(gridData.accessRowDataArray().enumerated()), id: \.offset) { index, element in
                    HStack(spacing: columnSpacing) { //VStack for based on Column, HStack for Row
                        ForEach(gridData.accessRowDataArray()[index], id: \.column) { element in
                            AnyView(rowContentView(element))
                        }
                    }
                }
            }
        } else if gridData.accessIsColumnPriority() {
            HStack(alignment: columnPriorityAlignment, spacing: columnSpacing) { //HStack for based on Column, VStack for Row
                ForEach(Array(gridData.accessColumnDataArray().enumerated()), id: \.offset) { index, element in
                    VStack(spacing: rowSpacing) { //VStack for based on Column, HStack for Row
                        ForEach(gridData.accessColumnDataArray()[index], id: \.row) { element in
                            AnyView(columnContentView(element))
                        }
                    }
                }
            }
        }
    }
    
    /// Use this to make contents lazy loaded on grid view. Useful when the received data is large
    ///
    /// - Minimum iOS 14.0
    @available(iOS 14.0, *)
    @ViewBuilder
    private func lazyLoadContentView() -> some View {
        if gridData.accessIsRowPriority() {
            LazyVStack(alignment: rowPriorityAlignment, spacing: rowSpacing) {
                ForEach(Array(gridData.accessRowDataArray().enumerated()), id: \.offset) { index, element in
                    LazyHStack(spacing: columnSpacing) {
                        ForEach(gridData.accessRowDataArray()[index], id: \.column) { element in
                            AnyView(rowContentView(element))
                        }
                    }
                }
            }
            .padding(.leading, 8)
        } else if gridData.accessIsColumnPriority() {
            LazyHStack(alignment: columnPriorityAlignment, spacing: columnSpacing) {
                ForEach(Array(gridData.accessColumnDataArray().enumerated()), id: \.offset) { index, element in
                    LazyVStack(spacing: rowSpacing) {
                        ForEach(gridData.accessColumnDataArray()[index], id: \.row) { element in
                            AnyView(columnContentView(element))
                        }
                    }
                }
            }
        }
    }
    
    /// Use this to make grid can be scrolled based on axis parameter
    ///
    /// - Parameter axis: Set this to horizontal or vertical
    /// - Parameter isIndicatorShown: For show/hide scroll indicator
    @ViewBuilder
    func makeGridScrollable(_ axis: Axis.Set, isIndicatorShown: Bool = false) -> some View {
        ScrollView(axis, showsIndicators: isIndicatorShown) {
            self
        }
    }
}

@available(iOS 13.0, *)
#Preview {
    SomeView()
}

@available(iOS 13.0, *)
struct SomeView: View {
    var data: [SomeData] = [SomeData(icon: .blue, price: "Biru"),
                            SomeData(icon: .orange, price: "Orange"),
                            SomeData(icon: .yellow, price: "Kuning"),
                            SomeData(icon: .blue, price: "Biru"),
                            SomeData(icon: .orange, price: "Orange"),
                            SomeData(icon: .yellow, price: "Kuning"),
                            SomeData(icon: .blue, price: "Biru"),
                            SomeData(icon: .orange, price: "Orange"),
                            SomeData(icon: .yellow, price: "Kuning")]
    
    var body: some View {
        GridView(gridData: data, maxColumnElement: 3, columnPriorityAlignment: .top, rowSpacing: 8, columnSpacing: 8) { data in
            SingleContentView(iconColor: data.data.icon, price: "Row: \(data.row) Column: \(data.column)")
        }
        Spacer()
        GridView(gridData: data, maxRowElement: 4, rowPriorityAlignment: .leading, rowSpacing: 8, columnSpacing: 8) { data in
            SingleContentView(iconColor: data.data.icon, price: "Row: \(data.row) Column: \(data.column)")
        }
    }
}

@available(iOS 13.0, *)
struct SomeData: Hashable {
    let icon: Color
    let price: String
}

@available(iOS 13.0, *)
struct SingleContentView: View {
    var iconColor: Color
    var price: String
    
    init(iconColor: Color, price: String) {
        self.iconColor = iconColor
        self.price = price
    }
    
    var body: some View {
        VStack {
            Rectangle().fill(iconColor)
            Text(price)
        }
        .frame(width: 100, height: 100)
    }
}
