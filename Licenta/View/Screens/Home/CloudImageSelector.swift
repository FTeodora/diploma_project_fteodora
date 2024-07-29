//
//  CloudImageSelector.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 7/30/23.
//

import SwiftUI
import FirebaseStorage

struct ImageCell: View {
    @StateObject var loader: ImageLoader
    var name: String
    let imageSize = (UIScreen.main.bounds.width - 30.0)/3.0
    
    var body: some View {
        VStack {
            Group {
                if loader.isLoading {
                    ProgressView()
                } else {
                    if let image = loader.uiImage {
                        Image(uiImage: image)
                            .resizable()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaledToFit()
            .frame(width: imageSize, height: imageSize, alignment: .center)
            .aspectRatio(1.0, contentMode: .fit)
            
                
            Text(name)
        }.frame(width: imageSize)
        .onAppear {
                loader.loadImage()
            }
    }
}

//gruparea imaginilor intr-un rand de 3 celule
struct ImageRow: View {
    var images: [CloudImage]
    var storage: Storage
    var onImageTap: (CloudImage) -> Void
    
    var body: some View {
        LazyHStack {
            ForEach(images) { image in
                ImageCell(loader: ImageLoader(storage: storage, url: image.generateUrl(for: .thumbnail)), name: image.name)
                    .onTapGesture {
                        onImageTap(image)
                    }
                Spacer()
            }
        }
    }
}

@MainActor
class CloudImageSelectorViewModel: ObservableObject {
    var db: Database
    
    @Published var images: [CloudImage] = []
    init(db: Database) {
        self.db = db
    }
    
    func loadImagesNames(for userId: String?) async {
        do {
            guard let userId = userId else { return }
            images = try await CloudImage.images(from: db, for: userId) ?? []
        } catch( let error) {
            print("Failed to fetch images: \(error.localizedDescription)")
        }
    }
}

struct CloudImageSelector: View {
    @StateObject var viewModel: CloudImageSelectorViewModel
    @Binding var selectedImage: CloudImage?
    @Binding var userId: String?
    @Environment(\.dismiss) var dismiss
    
    var storage: Storage
    
    var body: some View {
        HStack {
            Spacer()
            Button("Logout") {
                userId = nil
                dismiss()
            }.padding()
        }
        ScrollView(.vertical) {
            LazyVStack {
                if viewModel.images.isEmpty {
                    //textul pentru cand utilizatorul nu are imagini
                    Text("You do not have any images yet")
                } else {
                    ForEach(viewModel.images.chunked(into: 3), id: \.first?.id) { images in
                        ImageRow(images: images, storage: storage) { image in
                            selectedImage = image
                            dismiss()
                        }
                    }
                }
            }
        }.task {
            await viewModel.loadImagesNames(for: userId)
        }
    }
}
