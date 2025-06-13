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
    @Published private var elementDataArray: [[GridDataModel<T>]]
    private var elementData: [GridDataModel<T>]
    private var isRowPriority: Bool
    private var isColumnPriority: Bool
    private var maxRowElement: Int
    private var maxColumnElement: Int
    private var data: [T]
    
    init(elementDataArray: [[GridDataModel<T>]] = [[]], elementData: [GridDataModel<T>] = [],
         isRowPriority: Bool, isColumnPriority: Bool, maxRowElement: Int, maxColumnElement: Int, data: [T]) {
        self.elementDataArray = elementDataArray
        self.elementData = elementData
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

    func accessElementDataArray() -> [[GridDataModel<T>]] {
        return elementDataArray
    }
    
    func accessIsRowPriority() -> Bool {
        return isRowPriority
    }
    
    func accessIsColumnPriority() -> Bool {
        return isColumnPriority
    }

    func getElementTotalCount() -> Int {
        return accessElementDataArray().count
    }

    private func dataProcessing() {
        var indexElement: Int = 1
        var indexMaxElement: Int = 0
        for input in data {
            let rowSingleData = GridDataModel(row: isRowPriority ? indexElement : indexMaxElement+1,
                                              column: isColumnPriority ? indexElement : indexMaxElement+1,
                                              data: input)
            self.elementData.append(rowSingleData)
            indexMaxElement+=1
            if (isRowPriority && indexMaxElement == maxRowElement) || (isColumnPriority && indexMaxElement == maxColumnElement) {
                indexMaxElement = 0
                indexElement+=1
            }
        }
        elementDataArray = (Dictionary(grouping: elementData, by: { isRowPriority ? $0.row : $0.column })).sorted(by: { $0.key < $1.key }).map({ $0.value })
    }
}

public struct GridDataModel<T: Hashable> {
    public let row: Int
    public let column: Int
    public let data: T
}
