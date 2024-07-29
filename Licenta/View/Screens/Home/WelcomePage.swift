//
//  WelcomePage.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/16/23.
//

import SwiftUI
import Combine
import Firebase
import FirebaseStorage

struct WelcomePage: View {
    @StateObject var viewModel: WelcomePageViewModel = WelcomePageViewModel()
    var database: Database
    var storage: Storage
    @State var isPickingImage = false
    @State private var isLoadingImage = false
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        FirebaseApp.configure()
        database = Database(db: Firestore.firestore())
        //link-ul catre storage-ul de firebase. certificatul este automat handle-uit de xcode prin fisierul de plist
        storage = Storage.storage(url: "gs://licenta-fcd8c.appspot.com")
        
        //personalizarea globala a scrollview-urilor
        UITableView.appearance().showsVerticalScrollIndicator = false
        UITableView.appearance().showsHorizontalScrollIndicator = false
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let pickedImage =  viewModel.pickedImage {
                    let ciImage = CIImage(image: pickedImage)
                    NavigationLink(destination: EditCanvasView(viewModel: FilterViewModel(for: viewModel.userId, with: ciImage, orientation: pickedImage.imageOrientation, model: viewModel.model, storage: storage, db: database), isEditing: $viewModel.didPickImage), isActive: $viewModel.didPickImage) { EmptyView() }
                }
                
                if let selectedImage = viewModel.selectedImage {
                    NavigationLink(destination: EditCanvasView(viewModel: FilterViewModel(with: storage, db: database, loading: selectedImage), isEditing: $viewModel.didSelectImage), isActive: $viewModel.didSelectImage) { EmptyView() }
                }
                if let clipboardImage = viewModel.clipboardImage {
                    //incarcarea imaginii din clipboard daca una este disponibila
                    Text("You can use your clipboard image")
                    Button {
                        viewModel.pickedImage = clipboardImage
                    } label: {
                        Image(uiImage: clipboardImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250.0)
                            .padding()
                    }.frame(maxWidth: .infinity)
                    Text("OR")
                        .font(.title)
                }
                
                //incarcarea unei imagini din galeria locala
                Text("Tap on the photo icon below to pick from your library")
                Button {
                    isPickingImage = true
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100.0)
                        .padding()
                }.frame(maxWidth: .infinity)
                .sheet(isPresented: $isPickingImage) {
                    ImagePicker(selectedImage: $viewModel.pickedImage)
                }
                Text("OR")
                    .font(.title)
                //incarcarea imaginii din cloud sau logarea/crearea contului
                Button {
                    isLoadingImage = true
                } label: {
                    Text(viewModel.userId == nil ? "Log in and load from cloud" : "Load from your cloud")
                }.buttonStyle(.borderedProminent)
                .fullScreenCover(isPresented: $isLoadingImage) {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                isLoadingImage = false
                            } label: {
                                Image(systemName: "x.square")
                                    .resizable()
                            }.buttonStyle(MenuButtonStyle())
                        }.padding()
                        .background(.black)
                        if viewModel.userId != nil {
                            CloudImageSelector(viewModel: CloudImageSelectorViewModel(db: database), selectedImage: $viewModel.selectedImage, userId: $viewModel.userId, storage: storage)
                            Spacer()
                        } else {
                            LoginView(userId: $viewModel.userId, viewModel: LoginViewModel(db: database))
                        }
                    }
                }
            }.padding()
        }.background(.black)
        .onAppear {
            viewModel.clipboardImage = UIPasteboard.general.image
        }.onChange(of: scenePhase) { newValue in
            if newValue == .active, let copiedImage = UIPasteboard.general.image {
                viewModel.clipboardImage = copiedImage
            }
        }
    }
}

struct WelcomePage_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage()
    }
}
