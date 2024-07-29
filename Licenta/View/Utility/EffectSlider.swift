//
//  EffectSlider.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/30/23.
//

import SwiftUI

struct EffectSlider<T: CoreImageFunctionFilterType>: View {
    @Binding var element: OneValueFilter<T>
    @State var value: Double = 0.0
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        VStack {
            Text("\(element.type.displayName)")
            if let range = element.type.range {
                Slider(value: $element.value, in: range) { isEditing in
                    if !isEditing {
                        element.registerUndo(from: value, to: element.value)
                        NotificationCenter.default.post(name: Notification.Name.registerUndo, object: nil)
                    }  else {
                        value = element.value
                    }
                }.onAppear {
                    element.undoManager = undoManager
                }
            }
        }.padding(EdgeInsets(top: 2.0, leading: 15.0, bottom: 20.0, trailing: 15.0))
    }
}
