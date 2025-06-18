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
    @State var scrollViewWidth: CGFloat
    @State var scrollViewHeight: CGFloat
    var deviceWidth: CGFloat
    var deviceHeight: CGFloat
    var gridData: GridDataManager<T>
    var rowPriorityAlignment: HorizontalAlignment
    var columnPriorityAlignment: VerticalAlignment
    var rowSpacing: CGFloat
    var columnSpacing: CGFloat
    var paginationBlock: (() -> Void)
    
    /// Use this to make the grid prioritize the row to be filled.
    ///
    /// - Parameter gridData: Data for the grid content
    /// - Parameter maxRowElement: Maximum amount of elements in a row
    /// - Parameter rowPriorityAlignment: Priority alignment for amount of elements when row isn't fully filled
    /// - Parameter rowSpacing: Spacing between rows
    /// - Parameter columnSpacing: Spacing between columns
    /// - Parameter rowContentView: View for each elements
    /// - Parameter paginationBlock: An action when scroll reached edge of scrolled grid view
    public init(gridData: [T],
                maxRowElement: Int,
                rowPriorityAlignment: HorizontalAlignment,
                rowSpacing: CGFloat, columnSpacing: CGFloat,
                rowContentView: @escaping (GridDataModel<T>) -> Content,
                paginationBlock: @escaping (() -> Void) = { }) {
        self.columnContentView = { _ in AnyView(HStack { Text("Empty") })}
        self.deviceWidth = UIScreen.current?.bounds.width ?? 0
        self.deviceHeight = UIScreen.current?.bounds.height ?? 0
        self.scrollViewWidth = 0
        self.scrollViewHeight = 0
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
        self.paginationBlock = paginationBlock
    }
    
    /// Use this to make the grid prioritize the column to be filled.
    ///
    /// - Parameter gridData: Data for the grid content
    /// - Parameter maxColumnElement: Maximum amount of elements in a column
    /// - Parameter columnPriorityAlignment: Priority alignment for amount of elements when column isn't fully filled
    /// - Parameter rowSpacing: Spacing between rows
    /// - Parameter columnSpacing: Spacing between columns
    /// - Parameter columnContentView: View for each elements
    /// - Parameter paginationBlock: An action when scroll reached edge of scrolled grid view
    public init(gridData: [T],
                maxColumnElement: Int,
                columnPriorityAlignment: VerticalAlignment,
                rowSpacing: CGFloat, columnSpacing: CGFloat,
                columnContentView: @escaping (GridDataModel<T>) -> Content,
                paginationBlock: @escaping (() -> Void) = { }) {
        self.rowContentView = { _ in AnyView(VStack { Text("Empty") })}
        self.deviceWidth = UIScreen.current?.bounds.width ?? 0
        self.deviceHeight = UIScreen.current?.bounds.height ?? 0
        self.scrollViewWidth = 0
        self.scrollViewHeight = 0
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
        self.paginationBlock = paginationBlock
    }
    
    public var body: some View {
        if #available(iOS 14.0, *) {
            lazyLoadContentView()
                .padding(.leading, 8)
        } else {
            contentView()
        }
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        if gridData.accessIsRowPriority() {
            VStack(alignment: rowPriorityAlignment, spacing: rowSpacing) { //HStack for based on Column, VStack for Row
                ForEach(Array(gridData.accessElementDataArray().enumerated()), id: \.offset) { index, element in
                    HStack(spacing: columnSpacing) { //VStack for based on Column, HStack for Row
                        ForEach(gridData.accessElementDataArray()[index], id: \.column) { element in
                            AnyView(rowContentView(element))
                        }
                    }
                }
            }
            .background(GeometryReader { geometry in
                let frame = geometry.frame(in: .named("gridScroll"))
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: frame)
                    .onAppear {
                        scrollViewHeight = frame.height
                    }
            })
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let scrollHeight = (value.height - UIScreen.main.bounds.height) + 96
                let position = -(value.minY)
                if position == scrollHeight {
                    paginationBlock()
                }
            }
        } else if gridData.accessIsColumnPriority() {
            HStack(alignment: columnPriorityAlignment, spacing: columnSpacing) { //HStack for based on Column, VStack for Row
                ForEach(Array(gridData.accessElementDataArray().enumerated()), id: \.offset) { index, element in
                    VStack(spacing: rowSpacing) { //VStack for based on Column, HStack for Row
                        ForEach(gridData.accessElementDataArray()[index], id: \.row) { element in
                            AnyView(columnContentView(element))
                        }
                    }
                }
            }
            .background(GeometryReader { geometry in
                let frame = geometry.frame(in: .named("gridScroll"))
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: frame)
                    .onAppear {
                        scrollViewWidth = frame.width
                    }
            })
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let scrollWidth = (value.width - (UIScreen.current?.bounds.width ?? 0))
                let position = (-value.minX)
                if position == scrollWidth {
                    paginationBlock()
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
                ForEach(Array(gridData.accessElementDataArray().enumerated()), id: \.offset) { index, element in
                    LazyHStack(spacing: columnSpacing) {
                        ForEach(gridData.accessElementDataArray()[index], id: \.column) { element in
                            AnyView(rowContentView(element))
                        }
                    }
                }
            }
            .background(GeometryReader { geometry in
                let frame = geometry.frame(in: .named("gridScroll"))
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: frame)
                    .onAppear {
                        scrollViewHeight = frame.height
                    }
            })
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let scrollHeight = (value.height - UIScreen.main.bounds.height) + 96
                let position = -(value.minY)
                if position == scrollHeight {
                    paginationBlock()
                }
            }
        } else if gridData.accessIsColumnPriority() {
            LazyHStack(alignment: columnPriorityAlignment, spacing: columnSpacing) {
                ForEach(Array(gridData.accessElementDataArray().enumerated()), id: \.offset) { index, element in
                    LazyVStack(spacing: rowSpacing) {
                        ForEach(gridData.accessElementDataArray()[index], id: \.row) { element in
                            AnyView(columnContentView(element))
                        }
                    }
                }
            }
            .background(GeometryReader { geometry in
                let frame = geometry.frame(in: .named("gridScroll"))
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: frame)
                    .onAppear {
                        scrollViewWidth = frame.width
                    }
            })
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let scrollWidth = (value.width - (UIScreen.current?.bounds.width ?? 0))
                let position = (-value.minX)
                if position == scrollWidth {
                    paginationBlock()
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
        .coordinateSpace(name: "gridScroll")
    }
}

@available(iOS 13.0, *)
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { }
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
        } paginationBlock: {
            print("MENTOK KANAN")
        }
        .makeGridScrollable(.horizontal)
        Spacer()
        GridView(gridData: data, maxRowElement: 4, rowPriorityAlignment: .leading, rowSpacing: 8, columnSpacing: 8) { data in
            SingleContentView(iconColor: data.data.icon, price: "Row: \(data.row) Column: \(data.column)")
        } paginationBlock: {
            print("MENTOK BAWAH")
        }
        .makeGridScrollable(.vertical)
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

@available(iOS 13.0, *)
extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}

@available(iOS 13.0, *)
extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}
