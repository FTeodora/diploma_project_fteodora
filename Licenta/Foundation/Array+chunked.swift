//
//  Array+chunked.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 7/30/23.
//

import Foundation

extension Array {
    //grupeaza elemntele dintr-un array in bucati de maxim size elemente
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
