//
//  AddClassView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 8/27/23.
//

import SwiftUI

struct AddClassView: View {
    @State var classes: [ModelClass]
    @State var searchedQuery = ""
    var onClassSelect: (ModelClass) -> () = { _ in }
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Add a class")
                    .font(.title3)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.square")
                        .resizable()
                }.buttonStyle(MenuButtonStyle())
            }
            .background(.black)
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchedQuery)
            }.padding(.horizontal)
            Spacer()
                .frame(height: 20.0)
            ScrollView(.vertical) {
                //filtrele trebuie afisate fie daca nu este scris nimic in field-ul de cautare, fie daca contin textul cautat in nume
                ForEach(classes.filter{ searchedQuery.isEmpty || $0.displayName.contains(searchedQuery) }) { modelClass in
                    HStack {
                        Text(modelClass.displayName)
                            .padding()
                            .font(.body)
                        Spacer()
                    }.background(Color(uiColor: modelClass.color))
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        onClassSelect(modelClass)
                        dismiss()
                    }
                }
            }
        }.background(darkGray)
    }
}
