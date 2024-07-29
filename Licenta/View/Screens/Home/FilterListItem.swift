//
//  FilterListItem.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/27/23.
//

import SwiftUI
import CoreImage

struct FilterListItem: View {
    var filter: String
    @State var isPresenting = false
    var body: some View {
        Button(filter) {
            isPresenting = true
        }.sheet(isPresented: $isPresenting) {
            if let ciFilter = CIFilter(name: filter) {
              ScrollView(showsIndicators: false) {
                Text(ciFilter.attributes.description)
              }
            } else {
              Text("Unknown filter!")
            }
        }.padding()
    }
}

struct FilterListItem_Previews: PreviewProvider {
    static var previews: some View {
        FilterListItem(filter: "")
    }
}
