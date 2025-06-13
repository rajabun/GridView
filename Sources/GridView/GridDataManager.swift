//
//  GridDataManager.swift
//  GridView
//
//  Created by Muhammad Rajab on 04-06-2025.
//  Copyright © 2025 Muhammad Rajab. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
class GridDataManager<T: Hashable>: ObservableObject {
    @Published private var rowDataArray: [[GridDataModel<T>]] = [[]]
    @Published private var columnDataArray: [[GridDataModel<T>]] = [[]]
    private var rowData: [GridDataModel<T>] = []
    private var columnData: [GridDataModel<T>] = []
    private var isRowPriority: Bool
    private var isColumnPriority: Bool
    private var maxRowElement: Int
    private var maxColumnElement: Int
    private var data: [T]
    
    init(isRowPriority: Bool, isColumnPriority: Bool, maxRowElement: Int, maxColumnElement: Int, data: [T]) {
        self.isRowPriority = isRowPriority
        self.isColumnPriority = isColumnPriority
        self.maxRowElement = maxRowElement
        self.maxColumnElement = maxColumnElement
        self.data = data
        dataProcessing()
    }

    public func updateDataArray(updatedData: [T]) {
        self.data = updatedData
        dataProcessing()
    }

    func accessRowDataArray() -> [[GridDataModel<T>]] {
        return rowDataArray
    }

    func accessColumnDataArray() -> [[GridDataModel<T>]] {
        return columnDataArray
    }
    
    func accessIsRowPriority() -> Bool {
        return isRowPriority
    }
    
    func accessIsColumnPriority() -> Bool {
        return isColumnPriority
    }

    func getRowTotalCount() -> Int {
        return accessRowDataArray().count
    }

    func getColumnTotalCount() -> Int {
        return accessColumnDataArray().count
    }

    private func dataProcessing() {
        if isRowPriority {
            var indexRow: Int = 1
            var indexMaxRow: Int = 0
            for input in data {
                //Fill data based on row
                let rowSingleData = GridDataModel(row: indexRow, column: indexMaxRow+1, data: input)
                self.rowData.append(rowSingleData)
                indexMaxRow+=1
                if indexMaxRow == maxRowElement {
                    indexMaxRow = 0
                    indexRow+=1
                }
            }
            rowDataArray = (Dictionary(grouping: rowData, by: { $0.row })).sorted(by: { $0.key < $1.key }).map({ $0.value })
        } else if isColumnPriority {
            var indexColumn: Int = 1
            var indexMaxColumn: Int = 0
            for input in data {
                //Fill data based on column
                let columnSingleData = GridDataModel(row: indexMaxColumn+1,column: indexColumn, data: input)
                self.columnData.append(columnSingleData)
                indexMaxColumn+=1
                if indexMaxColumn == maxColumnElement {
                    indexMaxColumn = 0
                    indexColumn+=1
                }
            }
            columnDataArray = (Dictionary(grouping: columnData, by: { $0.column })).sorted(by: { $0.key < $1.key }).map({ $0.value })
        }
    }
}

public struct GridDataModel<T: Hashable> {
    public let row: Int
    public let column: Int
    public let data: T
}
