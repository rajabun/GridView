//
//  GridDataManager.swift
//  GridView
//
//  Created by Muhammad Rajab on 04-06-2025.
//  Copyright © 2025 Muhammad Rajab. All rights reserved.
//

import SwiftUI

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

    func updateDataArray(updatedData: [T]) {
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

@available(iOS 13.0, *)
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { }
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

@available(iOS 13.0, *)
extension View {
    /// A backwards compatible wrapper for iOS 16 `scrollDisabled`
    @ViewBuilder func disableScrolling(disabled: Bool) -> some View {
        if #available(iOS 16.0, *) {
            self.scrollDisabled(disabled)
        } else {
            modifier(DisableScrolling(disabled: disabled))
        }
    }
}

@available(iOS 13.0, *)
struct DisableScrolling: ViewModifier {
    var disabled: Bool

    func body(content: Content) -> some View {
        if disabled {
            content
                .simultaneousGesture(DragGesture(minimumDistance: 0))
        } else {
            content
        }
    }
}
