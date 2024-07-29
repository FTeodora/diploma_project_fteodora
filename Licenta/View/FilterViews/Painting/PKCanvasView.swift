//
//  CanvasView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/30/23.
//

import SwiftUI
import PencilKit

//Integrarea librariei de PencilKit pentru desenarea pe un canvas
struct CanvasView {
    @Binding var canvasView: PKCanvasView
    @State var toolPicker = PKToolPicker()
    var originalDrawings = PKDrawing()
}

extension CanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.isOpaque = false
        canvasView.backgroundColor = UIColor.clear
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        canvasView.drawingPolicy = .anyInput
        canvasView.drawing = originalDrawings
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(canvasView: $canvasView, toolPicker: toolPicker) }
}

class Coordinator: NSObject, PKCanvasViewDelegate, PKToolPickerObserver {
    @Binding var canvasView: PKCanvasView
    private let toolPicker: PKToolPicker

    deinit {
        toolPicker.setVisible(false, forFirstResponder: $canvasView.wrappedValue)
        toolPicker.removeObserver($canvasView.wrappedValue)
    }

    init(canvasView: Binding<PKCanvasView>, toolPicker: PKToolPicker) {
        self._canvasView = canvasView
        self.toolPicker = toolPicker
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        NotificationCenter.default.post(name: Notification.Name.registerUndo, object: nil)
    }

}
