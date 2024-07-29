//
//  EditCanvasView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/10/23.
//

import SwiftUI
import CoreImage

//Ecranul intreg pentru editare al imaginii
struct EditCanvasView: View {
    @StateObject var viewModel: FilterViewModel
    
    @State var previewImage: UIImage?
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .background(.clear)
            } else {
                OptionsHeader(viewModel: viewModel, isEditing: $isEditing, baseImage: viewModel.baseImage)
                Spacer()
                EditSpaceView(previewImage: $previewImage, viewModel: viewModel, baseImage: viewModel.baseImage)
                Spacer()
                FilterTypePicker(viewModel: viewModel)
            }
        }
       .background(darkGray)
       .onAppear {
           guard let baseImage = viewModel.baseImage else { viewModel.loadBaseImage(); return }
           previewImage = UIImage(ciImage: baseImage)
           viewModel.initializePrediction(with: previewImage!.ciImage!)
           viewModel.objectWillChange.send()
           
       }.navigationBarTitle("")
        .navigationBarHidden(true)
        .onReceive(viewModel.objectWillChange) {
            previewImage = viewModel.makePreview()
        }
    }
}
