//
//  OptionsHeader.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/23/23.
//

import SwiftUI
import Combine

struct MenuButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaledToFit()
            .frame(width: 20.0, height: 20.0)
            .foregroundColor(isEnabled ? (configuration.isPressed ? .accentColor : .white) : .gray)
            .padding()
            .background(.black)
    }
}
//meniul de sus pentru ecranul de editare care contine optiunile de undo/redo si meniul de overflow cu toate optiunile de exportare
struct OptionsHeader: View {
    @Environment(\.undoManager) private var undoManager
    @ObservedObject var viewModel: FilterViewModel
    @Binding var isEditing: Bool
    @State private var showSheet = false
    @State private var isSharing = false
    @State private var aboutToExit = false
    @State private var saveMessage: String?
    @State private var showSave = false
    @State private var canUndo = false
    @State private var canRedo = false
    var baseImage: CIImage?
    
    var body: some View {
        HStack {
            Group {
                //butonul de unto
                Button {
                    undoManager?.undo()
                    viewModel.objectWillChange.send()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .resizable()
                }
                .disabled(!canUndo)
                .buttonStyle(MenuButtonStyle())

                //butonul de redo
                Button {
                    undoManager?.redo()
                    viewModel.objectWillChange.send()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .resizable()
                }.disabled(!canRedo)
                .buttonStyle(MenuButtonStyle())
            }.onReceive(viewModel.objectWillChange) {
                canUndo = undoManager?.canUndo ?? false
                canRedo = undoManager?.canRedo ?? false
            }.onReceive(NotificationCenter.default.publisher(for: Notification.Name.registerUndo)) { value in
                viewModel.objectWillChange.send()
            }
            
            Spacer()
            
            //meniul de overflow din dreapta
            Menu {
                //butonul de distribuire a imaginii editate
                Button {
                    isSharing = true
                } label: {
                    Label("Share edited image", systemImage: "square.and.arrow.up")
                }.buttonStyle(MenuButtonStyle())
                .disabled(viewModel.makePreview() == nil)
                
                //butonul de salvare a imaginiii editate in galerie
                Button {
                    guard let image = viewModel.makePreview() else { return }
                    let saver = ImageSaver { success in
                        saveMessage = success?.localizedDescription
                        showSave = true
                    }
                    saver.writeToPhotoAlbum(image: image)
                } label: {
                    Label("Save image to gallery", systemImage: "square.and.arrow.down")
                }.buttonStyle(MenuButtonStyle())
                .disabled(viewModel.makePreview() == nil)
                
                //salvarea imaginii pe cloud. disponibil doar daca utilizatorul e logat
                if let currentUser = viewModel.currentUser {
                    Button {
                        viewModel.saveImageToCloud()
                    } label: {
                        Label("Export annotations", systemImage: "icloud.and.arrow.up")
                    }
                }
                
                //butonul de iesire din editor pentru a deschide o alta imagine
                Button(role: .destructive) {
                    aboutToExit = true
                } label: {
                    Label("Exit", systemImage: "rectangle.portrait.and.arrow.forward")
                }.buttonStyle(MenuButtonStyle())

            } label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding()
            }.sheet(isPresented: $isSharing) {
                if let image = viewModel.makePreview() {
                    ActivityView(image: image)
                }
            }
        }
        .padding(.vertical, 10.0)
        .background(.black)
        .alert(saveMessage ?? "Image has been saved to your library", isPresented: $showSave) {
                Button("OK", role: .cancel) { }
        }
        .alert(isPresented: $aboutToExit) {
            Alert(title: Text("Are you sure you want to exit? Your unsaved edits will be lost"), primaryButton: .cancel(Text("NO")), secondaryButton: .default(Text("YES"), action: { isEditing = false; undoManager?.removeAllActions()}))
        }
    }
}

