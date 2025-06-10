//
//  GridView.swift
//  GridView
//
//  Created by Muhammad Rajab on 04-06-2025.
//

import SwiftUI

@available(iOS 13.0, *)
struct GridView<Content: View, T: Hashable>: View {
    @ViewBuilder var rowContentView: (RowPriorityData<T>) -> any View
    @ViewBuilder var columnContentView: (ColumnPriorityData<T>) -> any View
    var gridData: GridDataManager<T>
    var rowPriorityAlignment: HorizontalAlignment
    var columnPriorityAlignment: VerticalAlignment
    var rowSpacing: CGFloat
    var columnSpacing: CGFloat
    
    init(gridData: [T], maxRowElement: Int,
         rowPriorityAlignment: HorizontalAlignment,
         rowSpacing: CGFloat, columnSpacing: CGFloat,
         rowContentView: @escaping (RowPriorityData<T>) -> Content) {
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
    
    init(gridData: [T], maxColumnElement: Int,
         columnPriorityAlignment: VerticalAlignment,
         rowSpacing: CGFloat, columnSpacing: CGFloat,
         columnContentView: @escaping (ColumnPriorityData<T>) -> Content) {
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
    
    var body: some View {
        if gridData.accessIsRowPriority() {
            VStack(alignment: rowPriorityAlignment, spacing: rowSpacing) { //HStack for based on Column, VStack for Row
                ForEach(Array(gridData.accessRowDataArray().enumerated()), id: \.offset) { index, element in
                    HStack(spacing: columnSpacing) { //VStack for based on Column, HStack for Row
                        ForEach(gridData.accessRowDataArray()[index], id: \.data) { element in
                            AnyView(rowContentView(element))
                        }
                    }
                }
            }
        } else if gridData.accessIsColumnPriority() {
            HStack(alignment: columnPriorityAlignment, spacing: columnSpacing) { //HStack for based on Column, VStack for Row
                ForEach(Array(gridData.accessColumnDataArray().enumerated()), id: \.offset) { index, element in
                    VStack(spacing: rowSpacing) { //VStack for based on Column, HStack for Row
                        ForEach(gridData.accessColumnDataArray()[index], id: \.data) { element in
                            AnyView(columnContentView(element))
                        }
                    }
                }
            }
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
            SingleContentView(iconColor: data.data.icon, price: data.data.price)
        }
        Spacer()
        GridView(gridData: data, maxRowElement: 4, rowPriorityAlignment: .leading, rowSpacing: 8, columnSpacing: 8) { data in
            SingleContentView(iconColor: data.data.icon, price: data.data.price)
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
