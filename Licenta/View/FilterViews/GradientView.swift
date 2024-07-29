//
//  GradientView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/16/23.
//

import SwiftUI
import UIKit

struct GradientView: View {
    @Binding var gradientGroup: GradientGroup
    @Environment(\.undoManager) var undoManager
    var body: some View {
        VStack {
            if gradientGroup.selectedFilter != .normal {
                HStack {
                    ColorPicker("First color", selection: $gradientGroup.color1)
                    Spacer()
                        .frame(width: 30.0)
                    ColorPicker("Second color", selection: $gradientGroup.color2)
                }.padding(.horizontal, 15.0)
            }
            EffectSelectionListView(selectedFilter: $gradientGroup.selectedFilter, filters: $gradientGroup.filters,onFilterSelect: { oldValue, newValue in
                gradientGroup.registerUndo(from: oldValue, to: newValue)
            }) { filters in
                TextLabelPreview(text: filters.type.displayName)
            } filterView: { _ in EmptyView() }
        }.onAppear {
            gradientGroup.undoManager = undoManager
        }
    }
}

struct DraggablePoint: View {
    @Binding var position: CIVector
    @Binding var color: Color
    @State var offset: CGPoint
    var off: CGSize
    var parentW: Double = 1
    var parentH: Double = 1
    var size: Double = 40.0
    var onDragFinished: (_ oldValue: CIVector, _ newValue: CIVector) -> ()
    let maxWidth = 200.0
    let maxHeight = 200.0
    
    init(position: Binding<CIVector>, color: Binding<Color>, initialOffset: CGSize, parentWidth: Double, parentHeight: Double, onDragFinish: @escaping (CIVector, CIVector) -> ()) {
        self._position = position
        self._color = color
        parentW = parentWidth
        parentH = parentHeight
        off = initialOffset
        offset = CGPoint(x: (position.wrappedValue.x*parentWidth)/maxWidth, y: parentHeight * ((maxHeight - position.wrappedValue.y)/maxHeight))
        self.onDragFinished = onDragFinish
    }
    
    var body: some View {
        Circle()
            .scaledToFill()
            .frame(width: size, height: size)
            .overlay {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 4.0)
                        .foregroundColor(.black)
                    Circle()
                        .stroke(lineWidth: 2.0)
                        .foregroundColor(.white)
                }.frame(width: size, height: size)

            }
            .position(offset)
            .offset(off)
            .foregroundColor(color)
            .gesture(DragGesture()
                .onChanged { drag in
                    offset.x = drag.location.x - off.width
                    offset.y = drag.location.y - off.height
                }.onEnded { _ in
                    let newPosition = CIVector(x: (offset.x * maxWidth)/parentW, y: maxHeight * (1-offset.y/parentH))
                    onDragFinished(position, newPosition)
                    position = newPosition
                }
            )
    }
}
