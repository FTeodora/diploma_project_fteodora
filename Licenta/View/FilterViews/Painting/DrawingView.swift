//
//  DrawingView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/30/23.
//

import SwiftUI
import PencilKit

//View-ul pentru desenarea peste imagine care va inlocui view-ul de Zoom in modul de desenare
struct DrawingView: View {
    @Binding var group: DrawingsGroup
    @State private var canvasView = PKCanvasView()
    @Environment(\.undoManager) var undoManager
    var image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .edgesIgnoringSafeArea(.all)
            .overlay(CanvasView(canvasView: $canvasView, originalDrawings: group.markups), alignment: .bottomLeading)
            .onDisappear {
                group.updateDrawings(with: undoManager, from: canvasView)
                NotificationCenter.default.post(name: Notification.Name.registerUndo, object: nil)
            }
    }
}
