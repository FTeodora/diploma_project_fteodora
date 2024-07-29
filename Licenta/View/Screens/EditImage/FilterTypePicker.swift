//
//  FilterTypePicker.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/30/23.
//

import SwiftUI

//meniul de selectie pentru tipul de filtru
struct FilterTypePicker: View {
    @Environment(\.undoManager) var undoManager
    @ObservedObject var viewModel: FilterViewModel
    var body: some View {
        VStack {
            if let selectedGroup = viewModel.selectedCategory {
                Group {
                    switch selectedGroup {
                    case .color:
                        let castedBinding = Binding<EveryFilterGroup<OneValueFilter<ColorFilters>>>(get: {viewModel.filterGroups[selectedGroup] as! EveryFilterGroup<OneValueFilter<ColorFilters>>},
                                                                                                    set: { viewModel.filterGroups[selectedGroup] = $0 })
                        EverySliderPicker<ColorFilters>(filterGroup: castedBinding)
                    case .light:
                        let castedBinding = Binding<EveryFilterGroup<OneValueFilter<LightFilters>>>(get: { viewModel.filterGroups[selectedGroup] as! EveryFilterGroup<OneValueFilter<LightFilters>>},
                                                                                                    set: { viewModel.filterGroups[selectedGroup] = $0 })
                        EverySliderPicker<LightFilters>(filterGroup: castedBinding)
                    case .filters:
                        let castedBinding = Binding<SingleFilterGroup<OneValueFilter<ImageFilterFilters>>>(get: { viewModel.filterGroups[selectedGroup] as! SingleFilterGroup<OneValueFilter<ImageFilterFilters>>},
                                                                                                    set: { viewModel.filterGroups[selectedGroup] = $0 })
                        SingleSliderPicker(filterGroup: castedBinding)
                    case .effects:
                        let castedBinding = Binding<EffectFilterGroup>(get: { viewModel.filterGroups[selectedGroup] as! EffectFilterGroup},
                                                                       set: { viewModel.filterGroups[selectedGroup] = $0 })
                        AspectView(effectGroup: castedBinding)
                    case .object:
                        let castedBinding = Binding<ObjectsGroup>(get: { viewModel.filterGroups[selectedGroup] as! ObjectsGroup},
                                                                      set: { viewModel.filterGroups[selectedGroup] = $0 })
                        ObjectsView(visionGroup: castedBinding)
                    case .crop:
                        let castedBinding = Binding<AffineGroup>(get: {viewModel.filterGroups[selectedGroup] as! AffineGroup},
                                                                 set: { viewModel.filterGroups[selectedGroup] = $0 })
                        AffineGroupView(affineGroup: castedBinding, cropGroup: $viewModel.cropGroup)
                    case .grad:
                        let castedBinding = Binding<GradientGroup>(get: { viewModel.filterGroups[selectedGroup] as! GradientGroup},
                                                                   set: { viewModel.filterGroups[selectedGroup] = $0 })
                        GradientView(gradientGroup: castedBinding)
                    default:
                        EmptyView()
                    }
                }.padding(.vertical, 15.0)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(FilterCategory.allCases.sorted(), id: \.self) { type in
                        VStack {
                            type.image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20.0, height: 20.0)
                            Text(type.rawValue.uppercased())
                                .font(.caption)
                        }
                        .padding()
                        .frame(width: 85.0, height: 60.0)
                        .background(type == viewModel.selectedCategory ? .gray : .clear)
                        .foregroundColor(type == viewModel.selectedCategory ? Color.accentColor : .white)
                        .onTapGesture {
                            viewModel.selectedCategory = type == viewModel.selectedCategory ? nil : type
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        
                    }
                }
            }.frame(height: 60.0)
            .background(.black)
            if viewModel.selectedCategory == .paint {
                Spacer()
                    .frame(height: 85.0)
            }
        }
    }
}
