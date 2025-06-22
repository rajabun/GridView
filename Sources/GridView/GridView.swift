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
/// To make this GridView scrollable, you can embed with a scroll view like this:
///
///     ScrollView(.horizontal) {
///         GridView()
///     }
///
/// or you can use `makeGridScrollable` method like this:
///
///        GridView(gridData: data,
///                 maxRowElement: 3,
///                 rowPriorityAlignment: .top,
///                 rowSpacing: 8, columnSpacing: 8) { row in
///                 YourContentView(image: row.data.image,
///                                 title: row.data.title)
///        } paginationBlock: {
///            YourCustomFunction()
///        }
///        .makeGridScrollable()
///
/// Use `paginationBlock` to trigger your custom function when scroll reached edge
/// - Important: Trigger custom function when scroll reached edge currently only supported when:
///   - GridView with row priority is only stacked with other Views inside HStack.
///   - GridView with column priority is only stacked with other Views inside VStack.
///   
///   Parameter `paginationBlock` already has a default empty value so this parameter can be skipped.
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
        self.gridData = GridDataManager(gridPriority: .rowPriority,
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
        self.gridData = GridDataManager(gridPriority: .columnPriority,
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
        switch gridData.accessGridPriority() {
        case .rowPriority:
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
                let scrollHeight = (value.height - deviceHeight) + 96
                let position = -(value.minY)
                if position == scrollHeight {
                    paginationBlock()
                }
            }
        case .columnPriority:
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
                let scrollWidth = (value.width - deviceWidth)
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
        switch gridData.accessGridPriority() {
        case .rowPriority:
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
                let scrollHeight = (value.height - deviceHeight) + 96
                let position = -(value.minY)
                if position == scrollHeight {
                    paginationBlock()
                }
            }
        case .columnPriority:
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
                let scrollWidth = (value.width - deviceWidth)
                let position = (-value.minX)
                if position == scrollWidth {
                    paginationBlock()
                }
            }
        }
    }
    
    /// Use this to make grid can be scrolled based on axis parameter
    ///
    /// - Parameter isParentScrollDisabled: Set this to true to make the view only have one way scroll
    ///     - Only vertical scroll for row priority
    ///     - Only horizontal scroll for column priority
    /// - Parameter isIndicatorShown: For show/hide scroll indicator
    @ViewBuilder
    public func makeGridScrollable(isParentScrollDisabled: Bool = false, isIndicatorShown: Bool = false) -> some View {
        let childAxis: Axis.Set = gridData.accessGridPriority() == .rowPriority ? .vertical : .horizontal
        let parentAxis: Axis.Set = gridData.accessGridPriority() == .rowPriority ? .horizontal : .vertical
        
        ScrollView(parentAxis, showsIndicators: isIndicatorShown) {
            ScrollView(childAxis, showsIndicators: isIndicatorShown) {
                self
            }
            .coordinateSpace(name: "gridScroll")
        }
        .disableScrolling(disabled: isParentScrollDisabled)
    }
}
