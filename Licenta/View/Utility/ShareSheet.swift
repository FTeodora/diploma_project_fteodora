//
//  ShareSheet.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/10/23.
//  sursa https://stackoverflow.com/questions/56533564/showing-uiactivityviewcontroller-in-swiftui

import UIKit
import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
