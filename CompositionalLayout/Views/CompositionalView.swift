//
//  CompositionalView.swift
//  CompositionalLayout
//
//  Created by Rendi Wijiatmoko on 26/04/22.
//

import SwiftUI

// MARK: Building Custom View like ForEach
struct CompositionalView<Content, Item, ID>: View where Content: View, ID: Hashable, Item: RandomAccessCollection, Item.Element: Hashable {
    var content: (Item.Element)-> Content
    var items: Item
    var id: KeyPath<Item.Element, ID>
    var spacing: CGFloat
    
    init(items: Item, id: KeyPath<Item.Element, ID>, spacing: CGFloat = 5, @ViewBuilder content: @escaping (Item.Element) -> Content) {
        self.content = content
        self.items = items
        self.id = id
        self.spacing = spacing
    }
    
    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(generatingColumns(), id: \.self) { row in
//                content(row.first!)
                RowView(row: row)
            }
        }
    }
    
    // MARK: Indetifyng Row Type
    func layoutType(row: [Item.Element])-> LAYOUT_TYPE {
        let index = generatingColumns().firstIndex { item in
            return item == row
        } ?? 0
        
        // MARK: Order will be 1,2,3,1,2,3...
        var types: [LAYOUT_TYPE] = []
        generatingColumns().forEach { _ in
            if types.isEmpty {
                types.append(.type1)
            } else if types.last == .type1 {
                types.append(.type2)
            } else if types.last == .type2 {
                types.append(.type3)
            } else if types.last == .type3 {
                types.append(.type1)
            } else {}
        }
        
        return types[index]
    }
    
    // MARK: Row View
    @ViewBuilder
    func RowView(row: [Item.Element]) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = (proxy.size.height - spacing) / 2
            let type = layoutType(row: row)
            let columnWidth = (width > 0 ? ((width - (spacing*2)) / 3 ) : 0)
            
            HStack(spacing: spacing) {
                if (type == .type1) {
                    SafeView(row: row, index: 0)
                    VStack(spacing: spacing) {
                        SafeView(row: row, index: 1)
                            .frame(height: height)
                        SafeView(row: row, index: 2)
                            .frame(height: height)
                    }
                    .frame(width: columnWidth)
                }
                if type == .type2 {
                    HStack(spacing:spacing) {
                        SafeView(row: row, index: 2)
                            .frame(width: columnWidth)
                        SafeView(row: row, index: 1)
                            .frame(width: columnWidth)
                        SafeView(row: row, index: 0)
                            .frame(width: columnWidth)
                    }
                }
                if (type == .type3) {
                    VStack(spacing: spacing) {
                        SafeView(row: row, index: 0)
                        SafeView(row: row, index: 1)
                    }
                    .frame(width: columnWidth)
                    SafeView(row: row, index: 2)
                }
            }
        }
        .frame(height: layoutType(row: row) == .type1 || layoutType(row: row) == .type3 ? 250 : 120)
    }
    
    // MARK: Safely unwrapping content index
    @ViewBuilder
    func SafeView(row: [Item.Element], index: Int)-> some View {
        if(row.count - 1) >= index {
            content(row[index])
        }
    }
    
    // MARK: Constructing Custom Rows and Columns
    func generatingColumns()->[[Item.Element]] {
        var columns: [[Item.Element]] = []
        var row: [Item.Element] = []
        
        for item in items {
            // MARK: Each row Consists of 3 Views
            if row.count == 3 {
                columns.append(row)
                row.removeAll()
                row.append(item )
            } else {
                row.append(item)
            }
        }
        
        // MARK: Adding Exhaust Once
        columns.append(row)
        row.removeAll()
        return columns
    }
}

struct CompositionalView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


enum LAYOUT_TYPE {
    case type1
    case type2
    case type3
}
