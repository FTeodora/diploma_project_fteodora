//
//  EffectListView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/31/23.
//

import SwiftUI

struct EffectSelectionListView<V: TypedFilter, OptionView: View, FilterView: View>: View {
    @Binding var selectedFilter: V.TypeEnum?
    @Binding var filters: [V]
    var height = 50.0
    var selectorBorderColor: Color = .clear
    var onFilterSelect: (V.TypeEnum?, V.TypeEnum?) -> () = {_, _ in }
    @ViewBuilder var preview: (V) -> (OptionView)
    @ViewBuilder var filterView: (Binding<V>) -> (FilterView)

    var body: some View {
        LazyVStack {
            ForEach($filters) { $filter in
                if filter.type == selectedFilter {
                    filterView($filter)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 1.0) {
                    ForEach($filters) { $filter in
                        ZStack {
                            preview(filter)
                            .frame(height: height+4)
                            .background(.clear)
                            .onTapGesture {
                                onFilterSelect(selectedFilter, filter.type)
                                selectedFilter = filter.type }
                            RoundedRectangle(cornerRadius: 3.0)
                                .stroke(style: StrokeStyle(lineWidth: 2.0))
                                .foregroundColor(filter.type == selectedFilter ? selectorBorderColor : .clear)
                                .frame(height: height)
                                .background(filter.type == selectedFilter ? darkGray.opacity(0.55) : .clear)
                                .allowsHitTesting(false)
                        }.listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
            }.padding(.vertical, 10.0)
            .frame(height: height)
        }
    }
}

