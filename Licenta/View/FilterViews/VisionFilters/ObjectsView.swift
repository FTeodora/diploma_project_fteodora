//
//  ObjectsView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/1/23.
//

import SwiftUI

//portiunea de view pentru obiectele detectate in imagine
struct ObjectsView: View {
    @Binding var visionGroup: ObjectsGroup
    @State var isEditingAnnotations: Bool = false
    @State var isSelectingColor: Bool = false
    @Environment(\.undoManager) var undoManager
    var body: some View {
        VStack {
            if visionGroup.filters.count > 1 {
                if visionGroup.selectedFilter != nil {
                    VStack {
                        HStack {
                            ResetButton(selectedFilter: $visionGroup.selectedFilter) {
                                visionGroup.registerUndo(from: visionGroup.selectedFilter, to: nil)
                            }
                            Spacer()
                            InvertButton(inverted: $visionGroup.inverted) {
                                visionGroup.registerInvertUndo()
                            }
                        }
                        HStack {
                            ForEach(ObjectsGroup.BackgroundMode.allCases, id: \.rawValue) { bgMode in
                                ModeButton(selectedMode: $visionGroup.selectedMode, buttonMode: bgMode)
                            }
                        }.padding(.vertical, 6.0)
                        switch visionGroup.selectedMode {
                        case .remove:
                            EmptyView()
                        case .color:
                            ColorPicker("Pick a background color", selection: $visionGroup.color)
                        case .image:
                            PickImageButton(image: $visionGroup.pickedImage)
                                .padding(.vertical, 5.0)
                        case .blur:
                            EffectSlider(element: $visionGroup.blurFilter)
                        }
                    }.padding(.horizontal, 15.0)
                }
                
                EffectSelectionListView(selectedFilter: $visionGroup.selectedFilter, filters: $visionGroup.filters,onFilterSelect: { oldValue, newValue in
                    visionGroup.registerUndo(from: oldValue, to: newValue)
                }) { modelClass in
                    TextLabelPreview(text: modelClass.type.displayName)
                } filterView: { _ in
                    EmptyView()
                }.onAppear {
                    visionGroup.undoManager = undoManager
                }
            } else {
                Text("The model couldn't detect at least two classes. You can add more by editing the annotations")
            }
            Button {
                isEditingAnnotations = true
            }label: {
                Text("Edit annotations")
            }.padding()
        }.fullScreenCover(isPresented: $isEditingAnnotations) {
            if let viewModel = visionGroup.editAnnotationsViewModel {
                EditAnnotationsView(viewModel: viewModel, classes: $visionGroup.filters) { newMask in
                    self.visionGroup.predictionMask = newMask
                    self.visionGroup.updateMasks()
                }
            }
        }
    }
}

struct ResetButton: View {
    @Binding var selectedFilter: ModelClass?
    var onTap: () -> ()
    var body: some View {
        Button("Back to image") {
            onTap()
            selectedFilter = nil
        }
    }
}

struct InvertButton: View {
    @Binding var inverted: Bool
    var onTap: () -> ()
    var body: some View {
        Button("Invert") {
            onTap()
            inverted.toggle()
        }
    }
}

struct PickImageButton: View {
    @Binding var image: UIImage?
    @State var isPresenting = false
    var body: some View {
        Button( image == nil ? "Pick an image" : "Choose another image") {
            isPresenting = true
        }.sheet(isPresented: $isPresenting) {
            ImagePicker(selectedImage: $image, allowsEditing: true)
        }.padding()
        .background(Color.accentColor)
        .foregroundColor(.white)
        .cornerRadius(8.0)
    }
}

struct ModeButton: View {
    @Binding var selectedMode: ObjectsGroup.BackgroundMode
    var buttonMode: ObjectsGroup.BackgroundMode
    var body: some View {
        Button(buttonMode.rawValue.capitalized) {
            selectedMode = buttonMode
        }.frame(maxWidth: .infinity)
        .foregroundColor(selectedMode == buttonMode ? .white : .accentColor)
    }
}
