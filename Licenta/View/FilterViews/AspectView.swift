//
//  AspectView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/31/23.
//

import SwiftUI

struct AspectView: View {
    @Binding var effectGroup: EffectFilterGroup
    @Environment(\.undoManager) var undoManager

    var body: some View {
        EffectSelectionListView(selectedFilter: $effectGroup.selectedFilter, filters: $effectGroup.filters, height: 60, selectorBorderColor: .white) { oldValue, newValue in
            effectGroup.registerUndo(from: oldValue, to: newValue)
        } preview: { effect in
            if let previewImage = effectGroup.previewImage, let image = effect.apply(input: previewImage)?.uIImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 43, height: 55, alignment: .center)
                    .clipped()
                    .foregroundColor(.white)
            }
        } filterView: { $element in
            Text("\(element.type.displayName)")
        }.onAppear {
            effectGroup.undoManager = undoManager
        }
    }
}
