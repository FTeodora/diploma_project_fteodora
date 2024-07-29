//
//  SliderList.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/30/23.
//

import SwiftUI

//un view care contine o lista de filtre care pot sa aiba valoarea lor reglata prin slidere
//view-ul este pentru EveryFilterGroup
struct EverySliderPicker<T: CoreImageFunctionFilterType>: View {
    @State var selectedFilter: T?
    @Binding var filterGroup: EveryFilterGroup<OneValueFilter<T>>
    
    var body: some View {
        EffectSelectionListView(selectedFilter: $selectedFilter, filters: $filterGroup.filters) { effect in
            VStack {
                EffectPreview(element: effect)
                    .padding(.horizontal)
            }
        } filterView: { $element in
            EffectSlider(element: $element)
        }
    }
}

//la fel ca si EverySliderPicker, dar pentru SingleFilterGroup
struct SingleSliderPicker<T: CoreImageFunctionFilterType>: View {
    @Binding var filterGroup: SingleFilterGroup<OneValueFilter<T>>
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        EffectSelectionListView(selectedFilter: $filterGroup.selectedFilter, filters: $filterGroup.filters) { oldValue, newValue in
            filterGroup.registerUndo(from: oldValue, to: newValue)
        } preview: { effect in
            TextLabelPreview(text: effect.type.displayName)
        } filterView: { $element in
            EffectSlider(element: $element)
        }.onAppear {
            filterGroup.undoManager = undoManager
        }
    }
}
