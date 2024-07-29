//
//  EditedImageView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/17/23.
//

import SwiftUI

//previzualizarea imaginii in editor
struct EditSpaceView: View {
    @Binding var previewImage: UIImage?
    @ObservedObject var viewModel: FilterViewModel
    @Environment(\.undoManager) var undoManager

    var baseImage: CIImage?
    var body: some View {
        if let image = previewImage {
            switch viewModel.selectedCategory {
            case .paint:
                let castedBinding = Binding<DrawingsGroup>(get: { viewModel.filterGroups[.paint] as! DrawingsGroup },
                                                    set: { viewModel.filterGroups[.paint] = $0 })
                DrawingView(group: castedBinding, image: image)
            case .crop:
                VStack {
                    GeometryReader { proxy in
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(Rectangle())
                            CropRectangle(imageBounds: $viewModel.cropGroup.filters[0].cropRect, proxySize: proxy.size) { newRectangle in
                                undoCrop(oldRect: viewModel.cropGroup.filters[0].cropRect, newRect: newRectangle)
                                viewModel.objectWillChange.send()
                            }
                        }
                    }.padding(30.0)
                    Button("Crop") {
                        NotificationCenter.default.post(name: Notification.Name.crop, object: nil)
                    }.buttonStyle(.borderedProminent)
                }
            case .grad:
                GeometryReader { proxy in
                    if (viewModel.filterGroups[.grad] as! GradientGroup).selectedFilter != .normal {
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                            let scale = image.getScaledSize(relativeTo: proxy.size)
                            let offset = scale.adjustedOffset(relativeTo: proxy.size)
                            let pointBind1 = Binding<CIVector> ( get: { (viewModel.filterGroups[.grad] as! GradientGroup).point1 },
                                                                 set: { (viewModel.filterGroups[.grad] as! GradientGroup).point1 = $0 })
                            let colorBind1 = Binding<Color> ( get: { (viewModel.filterGroups[.grad] as! GradientGroup).color1 },
                                                              set: { (viewModel.filterGroups[.grad] as! GradientGroup).color1 = $0 })
                            DraggablePoint(position: pointBind1, color: colorBind1, initialOffset: offset, parentWidth: scale.width, parentHeight: scale.height ) { oldValue, newValue in
                                (viewModel.filterGroups[.grad] as! GradientGroup).undoPoint(from: oldValue, to: newValue, pointNo: 0)
                                viewModel.objectWillChange.send()
                            }
                            let pointBind2 = Binding<CIVector> ( get: { (viewModel.filterGroups[.grad] as! GradientGroup).point2 },
                                                                 set: { (viewModel.filterGroups[.grad] as! GradientGroup).point2 = $0 })
                            let colorBind2 = Binding<Color> ( get: { (viewModel.filterGroups[.grad] as! GradientGroup).color2 },
                                                              set: { (viewModel.filterGroups[.grad] as! GradientGroup).color2 = $0 })
                            DraggablePoint(position: pointBind2, color: colorBind2, initialOffset: offset, parentWidth: scale.width, parentHeight: scale.height ) { oldValue, newValue in
                                (viewModel.filterGroups[.grad] as! GradientGroup).undoPoint(from: oldValue, to: newValue, pointNo: 1)
                                viewModel.objectWillChange.send()
                            }
                        }
                    } else {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Rectangle())
                            .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
                    }
                }.onAppear {
                    (viewModel.filterGroups[.grad] as! GradientGroup).undoManager = undoManager
                }.padding(30.0)
            default:
                GeometryReader { proxy in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Rectangle())
                        .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
                }
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }
    
    func undoCrop(oldRect: CGRect?, newRect: CGRect?) {
        undoManager?.registerUndo(withTarget: undoManager!, handler: { [oldRect] _ in
            undoCrop(oldRect: newRect, newRect: oldRect)
            self.viewModel.cropGroup.filters[0].cropRect = oldRect!
        })
    }
}
