//
//  SampleView.swift
//  GridView
//
//  Created by Muhammad Rajab on 18-06-2025.
//

import SwiftUI

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
        .makeGridScrollable(isParentScrollDisabled: true)
        Spacer()
        GridView(gridData: data, maxRowElement: 4, rowPriorityAlignment: .leading, rowSpacing: 8, columnSpacing: 8) { data in
            SingleContentView(iconColor: data.data.icon, price: "Row: \(data.row) Column: \(data.column)")
        } paginationBlock: {
            print("MENTOK BAWAH")
        }
        .makeGridScrollable()
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
