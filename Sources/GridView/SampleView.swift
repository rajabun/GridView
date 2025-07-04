//
//  SampleView.swift
//  GridView
//
//  Created by Muhammad Rajab on 18-06-2025.
//

import SwiftUI

@available(iOS 14.0, *)
#Preview {
    SomeView()
}

@available(iOS 14.0, *)
struct SomeView: View {
    @State var dataRow: [SomeData] = []
    @State var dataColumn: [SomeData] = []
    
    var body: some View {
        GridView(gridData: dataColumn, maxColumnElement: 3, columnPriorityAlignment: .top, rowSpacing: 8, columnSpacing: 8) { data in
            SingleContentView(iconColor: data.data.icon, price: "Row: \(data.row) Column: \(data.column)")
        } paginationBlock: {
            dataColumn.append(SomeData(icon: .yellow, price: "Kuning"))
            print("MENTOK KANAN")
        }
        .makeGridScrollable(isParentScrollDisabled: true)
        .onAppear {
            dataColumn = Array(repeating: SomeData(icon: .blue, price: "Biru"), count: 50)
        }
        .padding(.all)
        Spacer()
        GridView(gridData: dataRow, maxRowElement: 4, rowPriorityAlignment: .leading, rowSpacing: 8, columnSpacing: 8) { data in
            SingleContentView(iconColor: data.data.icon, price: "Row: \(data.row) Column: \(data.column)")
        } paginationBlock: {
            dataRow.append(SomeData(icon: .red, price: "Merah"))
            print("MENTOK BAWAH")
        }
        .makeGridScrollable()
        .onAppear {
            dataRow = Array(repeating: SomeData(icon: .blue, price: "Biru"), count: 50)
        }
        .padding(.all)
    }
}

@available(iOS 14.0, *)
struct SomeData: Hashable {
    let icon: Color
    let price: String
}

@available(iOS 14.0, *)
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
