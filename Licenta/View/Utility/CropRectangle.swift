//
//  CropRectangle.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/14/23.
//

import SwiftUI

extension Notification.Name {
    static let crop = Notification.Name("CropNotification")
    static let registerUndo = Notification.Name("RegisterUndo")
}

//dreptunghiul pentru decupare
struct CropRectangle: View {
    @Binding var imageBounds: CGRect
    @State var rectangle: CGRect
    @State var rectMax: CGRect
    @State var previewRect: CGRect
    @State var trueRectangle: CGRect
    var onCrop: (CGRect) -> () = { _ in}
    @State var scale: Double
    @Environment(\.undoManager) var undoManager
    
    init(imageBounds: Binding<CGRect>, proxySize: CGSize, onCrop: @escaping (CGRect) -> ()) {
        self._imageBounds = imageBounds
        
        let scale = imageBounds.wrappedValue.size.getScale(relativeTo: proxySize)
        self.scale = scale
        let scaledSize = CGSize(width: scale * imageBounds.wrappedValue.size.width, height: scale * imageBounds.wrappedValue.size.height)
        let offset: CGSize = scaledSize.adjustedOffset(relativeTo: proxySize)
        rectMax = CGRect(x: offset.width, y: offset.height, width: scaledSize.width, height: scaledSize.height)
        rectangle = CGRect(x: offset.width, y: offset.height, width: scaledSize.width, height: scaledSize.height)
        previewRect = CGRect(x: offset.width, y: offset.height, width: scaledSize.width, height: scaledSize.height)
        self.onCrop = onCrop
        trueRectangle = imageBounds.wrappedValue
    }
    

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Path(previewRect)
                    .stroke(lineWidth: 3)
                ScalingEdge(rectangle: $rectangle, previewRect: $previewRect, maxRect: rectMax)
                ScalingEdge(rectangle: $rectangle, previewRect: $previewRect, maxRect: rectMax, edgeX: 0)
                ScalingEdge(rectangle: $rectangle, previewRect: $previewRect, maxRect: rectMax, edgeY: 0)
                ScalingEdge(rectangle: $rectangle, previewRect: $previewRect, maxRect: rectMax, edgeX: 0, edgeY: 0)
            }.onReceive(NotificationCenter.default.publisher(for: Notification.Name.crop)) { _ in
                onCrop(trueRectangle)
                imageBounds = trueRectangle
            }.onChange(of: imageBounds) { newValue in
                scale = newValue.size.getScale(relativeTo: proxy.size)
                let rect: CGSize = CGSize(width: scale * newValue.width, height: scale * newValue.height)
                let offset = rect.adjustedOffset(relativeTo: proxy.size)
                rectangle = CGRect(x: offset.width, y: offset.height, width: rect.width, height: rect.height)
                previewRect = CGRect(x: offset.width, y: offset.height, width: rect.width, height: rect.height)
                rectMax = CGRect(x: offset.width, y: offset.height, width: rect.width, height: rect.height)
            }.onChange(of: rectangle) { newValue in
                trueRectangle = CGRect(x: imageBounds.origin.x + (newValue.origin.x - rectMax.origin.x)/scale, y: imageBounds.origin.y + (rectMax.maxY - newValue.maxY)/scale, width: rectangle.width/scale, height: rectangle.height/scale)
            }
        }
    }
}

//un punct din dreptunghiul de decupare
//acesta calculeaza diferenta cu care trebuie modificat dreptunghiul in functie de deplasament
//pozitionarea sa este determinata relativ cu punctul de stanga jos al dreptunghiului
struct ScalingEdge: View {
    @Binding var rectangle: CGRect
    @Binding var previousRect: CGRect
    var edgeX: Double = 1
    var edgeY: Double = 1
    var dotSize: Double
    var minSize: Double
    var maxRect: CGRect
    
    init(rectangle: Binding<CGRect>, previewRect: Binding<CGRect>, maxRect: CGRect, edgeX: Double = 1, edgeY: Double = 1, dotSize: Double = 30.0, minSize: Double = 70.0) {
        self._previousRect = rectangle
        self._rectangle = previewRect
        self.edgeX = edgeX
        self.edgeY = edgeY
        self.dotSize = dotSize
        self.minSize = minSize
        self.maxRect = maxRect
    }
    
    var body: some View {
        Circle()
            .frame(width: dotSize, height: dotSize)
            .offset(x: rectangle.origin.x, y: rectangle.origin.y)
            .position(x: rectangle.size.width*edgeX , y: rectangle.size.height*edgeY)
            .foregroundColor(.white)
            .gesture(DragGesture()
                .onChanged { drag in
                    //calcularea distantei in functie de deplasament si modificarea laturilor potrivite
                    let deltaWidth = (drag.translation.width)
                    let factorx = edgeX < 1.0 ? -1 : 1.0
                    rectangle.size.width = max(previousRect.size.width + factorx * deltaWidth, minSize)
                    rectangle.origin.x = previousRect.origin.x + deltaWidth * (1-edgeX)
                    let deltaHeight = (drag.translation.height)
                    let factory = edgeY < 1.0 ? -1 : 1.0
                    self.rectangle.size.height = max(previousRect.size.height + factory * deltaHeight, minSize)
                    self.rectangle.origin.y = previousRect.origin.y + deltaHeight * (1-edgeY)
                }.onEnded { _ in
                    previousRect = rectangle
                }
            )
    }
}
