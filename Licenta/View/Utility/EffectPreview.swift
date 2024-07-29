//
//  EffectPreview.swift
//  Licenta
//
//   Created by Fariseu, Teodora on 5/30/23.
//

import SwiftUI

struct EffectPreview<T: CoreImageFunctionFilterType>: View {
    @ObservedObject var element: OneValueFilter<T>
    
    var body: some View {
        element.type.icon
            .resizable()
            .scaledToFit()
            .frame(width: 35.0, height: 35.0)
            .padding()
    }
}

struct TextLabelPreview: View {
    var text: String
    var background: Color = Color.accentColor
    
    var body: some View {
        Text("\(text)")
            .padding(10.0)
            .background(background)
            .cornerRadius(8.0)
            .foregroundColor(.white)
            .padding(.horizontal, 3.0)
    }
}
