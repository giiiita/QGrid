//
//  ScrollTrackerView.swift
//  
//
//  Created by giiiita on 2020/06/08.
//

import SwiftUI

struct ScrollTrackerView<Content>: View where Content: View {
    let showIndicators: Bool
    let content: Content
    let parentMinY: CGFloat
    private var contentOffsetChanged: (() -> Void)?
    
    @Binding var contentOffset: CGFloat
    
    init(showIndicators: Bool = true, parentMinY: CGFloat, contentOffset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self.showIndicators = showIndicators
        self._contentOffset = contentOffset
        self.content = content()
        self.parentMinY = parentMinY
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: self.showIndicators) {
            ZStack(alignment: .top) {
                GeometryReader { insideProxy in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(insideProxy: insideProxy)])
                }
                VStack {
                    self.content
                }
            }
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            self.contentOffset = value[0]
            guard let contentOffsetChanged = self.contentOffsetChanged else { return }
            contentOffsetChanged()
        }
    }
    
    private func calculateContentOffset(insideProxy: GeometryProxy) -> CGFloat {
        return self.parentMinY - insideProxy.frame(in: .global).minY
    }
}

extension ScrollTrackerView: Buildable {
    func contentOffsetChanged(_ contentOffsetChanged: (() -> Void)?) -> Self {
        mutating(keyPath: \.contentOffsetChanged, value: contentOffsetChanged)
    }
    
}
struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]
    
    static var defaultValue: [CGFloat] = [0]
    
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

