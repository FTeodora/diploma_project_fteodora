//
//  DrawingsGroup.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/7/23.
//

import Foundation
import PencilKit
import Combine

//filtrul pentru categoria de desene introduse de utilizator
class DrawingsGroup: EveryFilterGroup<UserDrawing> {
    @Published var markups: PKDrawing = PKDrawing()
    //ultimele desene realizate sunt pastrate separat deoarece trebuie sa existe posibilitatea modificarii ulterioare a acestora
    @Published var currentDrawings: UserDrawing
    //indica daca imaginea se afla in modul de desenare
    @Published var isDrawing: Bool = false
    
    init(with bounds: CGRect?) {
        currentDrawings = UserDrawing(bounds: bounds ?? .zero)
        super.init(type: .paint)
    }
    
    init(copying value: DrawingsGroup) {
        markups = value.markups
        currentDrawings = value.currentDrawings
        super.init(type: .paint)
        filters = value.filters.map { UserDrawing(markups: $0.markups, bounds: $0.bounds)}
    }
    
    //schimbarea desenelor atunci cand utilizatorul incheie desenatul
    func updateDrawings(with undoManager: UndoManager?, from canvasView: PKCanvasView) {
        let capturedValue = DrawingsGroup(copying: self)
        let newMarkups = canvasView.drawing
        let bounds = canvasView.bounds
        guard bounds.height > 0, bounds.width > 0 else { return }
        let drawings = CIImage(image: newMarkups.image(from: bounds, scale: UIScreen.main.scale))
        currentDrawings.markups = drawings
        markups = newMarkups
        registerUndo(with: undoManager, from: capturedValue, to: self)
    }
    //deoarece ultimele adnotari sunt urmarite separat, ele trebuie adaugate in functie de starea aplicatiei
    //daca aplicatia este in modul de desenare, desenele vor fi afisate deja prin pkdrawings
    //daca nu, ele trebuie suprapuse peste imagine
    override var appliableFilters: [UserDrawing] {
        isDrawing ? filters : filters + [currentDrawings]
    }
    
    //schimbarea dimensiunii imaginii prin crop
    func updateBounds(with newBounds: CGRect) {
        markups = PKDrawing()
        if currentDrawings.markups != nil { filters.append(currentDrawings) }
        currentDrawings = UserDrawing(bounds: newBounds)
    }
    
    func registerUndo(with undoManager: UndoManager?, from oldValue: DrawingsGroup, to newValue: DrawingsGroup) {
        undoManager?.registerUndo(withTarget: self, handler: { [weak self] handler in
            handler.registerUndo(with: undoManager, from: newValue, to: oldValue)
            self?.markups = oldValue.markups
            self?.filters = oldValue.filters
            self?.currentDrawings = oldValue.currentDrawings
        })
    }
}
