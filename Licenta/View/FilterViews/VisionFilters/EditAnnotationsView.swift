//
//  EditAnnotationsView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 7/21/23.
//

import SwiftUI

//Ecranul pentru editarea adnotarilor
struct EditAnnotationsView: View {
    @StateObject var viewModel: EditAnnotationsViewModel
    @Binding var classes: [PredictionMaskFilter]
    @Environment(\.dismiss) var dismiss
    @Environment(\.undoManager) var undoManager
    
    var onDismiss: (CGImage?) -> () = {_ in}
    var body: some View {
        VStack {
            HStack {
                Button {
                    viewModel.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .resizable()
                }.buttonStyle(MenuButtonStyle())
                .disabled($viewModel.lines.isEmpty)
                Button {
                    viewModel.redo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .resizable()
                }.buttonStyle(MenuButtonStyle())
                .disabled($viewModel.poppedLines.isEmpty)
                Spacer()
                Button {
                    if !viewModel.lines.isEmpty {
                        viewModel.updateAnnotations()
                        onDismiss(viewModel.segmentationMap)
                    } else {
                        viewModel.poppedLines.removeAll()
                    }
                    dismiss()
                } label: {
                    Image(systemName: "x.square")
                        .resizable()
                }.buttonStyle(MenuButtonStyle())
            }.background(.black)
            
            HStack {
                Spacer()
                Button {
                    viewModel.isAddingClass = true
                } label: {
                    Label("Add class", systemImage: "plus.circle.fill")
                }.padding()
            }
            
            if let annotations = viewModel.annotationsPreview {
                Image(uiImage: annotations)
                    .resizable()
                    .scaledToFit()
                    .allowsHitTesting(false)
                    .overlay {
                        if let _ = viewModel.selectedClass {
                            GeometryReader { proxy in
                                Canvas { context, size in
                                    for line in viewModel.lines {
                                        var path = Path()
                                        path.addLines(line.points)
                                        context.stroke(path, with: .color(Color(line.color)), lineWidth: line.lineWidth)
                                    }
                                    var path = Path()
                                    path.addLines(viewModel.currentLine.points)
                                    context.stroke(path, with: .color(Color(viewModel.currentLine.color)), lineWidth: viewModel.currentLine.lineWidth)
                                }.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                    .onChanged({ value in
                                        let newPoint = value.location
                                        viewModel.currentLine.points.append(newPoint)
                                        })
                                    .onEnded({ value in
                                        //cand utilizatorul ridica degetul, linia curenta este terminata, adaugata in lista liniilor si resetata
                                        viewModel.lines.append(viewModel.currentLine)
                                        viewModel.currentLine = Line(points: [], color: viewModel.currentLine.color, lineWidth: viewModel.thickness, modelClass: viewModel.selectedClass)
                                        viewModel.proxy = proxy.size
                                    }))
                            }
                        }
                    }.overlay {
                        Image(uiImage: viewModel.baseImage)
                            .resizable()
                            .scaledToFit()
                            .opacity(0.4)
                    }.overlay {
                        if viewModel.previewDot {
                            Rectangle()
                                .fill(.black)
                                .frame(width: viewModel.thickness, height: viewModel.thickness)
                        }
                    }
            }
            Spacer()
            VStack {
                Text("LINE WIDTH")
                //reglarea dimensiunii pensulei de adnotare
                Slider(value: $viewModel.thickness, in: (5.0...20.0)) { isEditing in
                    viewModel.previewDot = isEditing
                }
            }.padding()
            Spacer()
            EffectSelectionListView(selectedFilter: $viewModel.selectedClass, filters: $classes) { modelClass in
                TextLabelPreview(text: modelClass.type.displayName, background: Color(uiColor: modelClass.type.color))
            } filterView: { _ in
                EmptyView()
            }

        }.background(darkGray)
        //un sheet care expune ecranul de adaugare de clasa noua
        .sheet(isPresented: $viewModel.isAddingClass) {
            //determinarea claselor care pot fi adaugate prin operatia de diferenta pe set-uri
            let allClasses = Set(ModelClass.allCases)
            let currentClasses = Set(classes.map{ $0.type })
            AddClassView(classes: Array(allClasses.subtracting(currentClasses))) { newClass in
                classes.append(PredictionMaskFilter(predictionClass: newClass))
            }
        }
    }
}
