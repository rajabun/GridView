//
//  GridDataManager.swift
//  GridView
//
//  Created by Muhammad Rajab on 04-06-2025.
//

import Foundation

@available(iOS 13.0, *)
public class GridDataManager<T: Hashable>: ObservableObject {
    @Published private var rowDataArray: [[RowPriorityData<T>]] = [[]]
    @Published private var columnDataArray: [[ColumnPriorityData<T>]] = [[]]
    private var rowData: [RowPriorityData<T>] = []
    private var columnData: [ColumnPriorityData<T>] = []
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

    func accessRowDataArray() -> [[RowPriorityData<T>]] {
        return rowDataArray
    }

    func accessColumnDataArray() -> [[ColumnPriorityData<T>]] {
        return columnDataArray
    }
    
    func accessIsRowPriority() -> Bool {
        return isRowPriority
    }
    
    func accessIsColumnPriority() -> Bool {
        return isColumnPriority
    }

    public func getRowTotalCount() -> Int {
        return accessRowDataArray().count
    }

    public func getColumnTotalCount() -> Int {
        return accessColumnDataArray().count
    }

    private func dataProcessing() {
        if isRowPriority {
            var indexRow: Int = 1
            var indexData: Int = 1
            for input in data {
                //Fill data based on row
                if indexData > maxRowElement {
                    indexData = 1
                    indexRow+=1
                }
                let rowSingleData = RowPriorityData(row: indexRow, data: input)
                self.rowData.append(rowSingleData)
                indexData+=1
            }
            rowDataArray = (Dictionary(grouping: rowData, by: { $0.row })).sorted(by: { $0.key < $1.key }).map({ $0.value })
        } else if isColumnPriority {
            var indexColumn: Int = 1
            var indexMaxColumn: Int = 0
            for input in data {
                //Fill data based on column
                let columnSingleData = ColumnPriorityData(column: indexColumn, data: input)
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

public struct RowPriorityData<T: Hashable> {
    let row: Int
    let data: T
}

public struct ColumnPriorityData<T: Hashable> {
    let column: Int
    let data: T
}
