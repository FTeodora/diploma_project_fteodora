//
//  AffineGroupView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/12/23.
//

import SwiftUI

struct AffineGroupView: View {
    @Binding var affineGroup: AffineGroup
    @Binding var cropGroup: CropGroup
    @Environment(\.undoManager) var undoManager
    var body: some View {
        HStack {
            ForEach($affineGroup.orientationFilters) { $filter in
                Button {
                    let previousOrientation = affineGroup.filters[0].currentOrientation
                    let previousCropGroup = cropGroup.filters[0].cropRect
                    registerUndo(previousOrientation: previousOrientation, previousCropRect: previousCropGroup)
                    affineGroup.update(by: filter)
                    cropGroup.update(by: filter)
                    
                    NotificationCenter.default.post(name: Notification.Name.registerUndo, object: nil)
                } label: {
                    filter.icon
                        .resizable()
                        .scaledToFit()
                        .frame(height: 25.0)
                        .padding()
                        .background(darkGray)
                }
                
                if filter == .mirror {
                    Spacer()
                }
            }
        }
    }
    
    func registerUndo(previousOrientation: Int, previousCropRect: CGRect) {
        undoManager?.registerUndo(withTarget: affineGroup, handler: { [previousOrientation, previousCropRect] _ in
            registerUndo(previousOrientation: self.affineGroup.filters[0].currentOrientation, previousCropRect: cropGroup.filters[0].cropRect)
            self.affineGroup.filters[0].currentOrientation = previousOrientation
            self.cropGroup.filters[0].cropRect = previousCropRect
        })
    }
}
