/*
  Copyright (c) 2017-2019 M.I. Hollemans

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
*/

import CoreGraphics

extension CGImage {
  /**
    Converts the image into an array of RGBA bytes.
  */
  @nonobjc public func toByteArrayRGBA() -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: width * height * 4)
    bytes.withUnsafeMutableBytes { ptr in
      if let colorSpace = colorSpace,
         let context = CGContext(
                    data: ptr.baseAddress,
                    width: width,
                    height: height,
                    bitsPerComponent: bitsPerComponent,
                    bytesPerRow: bytesPerRow,
                    space: colorSpace,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(self, in: rect)
      }
    }
    return bytes
  }

  /**
    Creates a new CGImage from an array of RGBA bytes.
  */
  @nonobjc public class func fromByteArrayRGBA(_ bytes: [UInt8],
                                               width: Int,
                                               height: Int) -> CGImage? {
    return fromByteArray(bytes, width: width, height: height,
                         bytesPerRow: width * 4,
                         colorSpace: CGColorSpaceCreateDeviceRGB(),
                         alphaInfo: .premultipliedLast)
  }

  /**
    Creates a new CGImage from an array of grayscale bytes.
  */
  @nonobjc public class func fromByteArrayGray(_ bytes: [UInt8],
                                               width: Int,
                                               height: Int) -> CGImage? {
    return fromByteArray(bytes, width: width, height: height,
                         bytesPerRow: width,
                         colorSpace: CGColorSpaceCreateDeviceGray(),
                         alphaInfo: .none)
  }

    @nonobjc class func fromByteArray(_ bytes: [UInt8],
                                    width: Int,
                                    height: Int,
                                    bytesPerRow: Int,
                                    colorSpace: CGColorSpace,
                                    alphaInfo: CGImageAlphaInfo) -> CGImage? {
        return bytes.withUnsafeBytes { ptr in
            guard let address = ptr.baseAddress else { return nil}
        let context = CGContext(data: UnsafeMutableRawPointer(mutating: address),
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: alphaInfo.rawValue)
        return context?.makeImage()
        }
    }
}


extension CGImage {
    // functie preluata din https://rockyshikoku.medium.com/resize-cgimage-baf23a0f58ab
    func resize(size: CGSize) -> CGImage? {
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)

        let bytesPerPixel = self.bitsPerPixel / self.bitsPerComponent
        let destBytesPerRow = width * bytesPerPixel


        guard let colorSpace = self.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: self.bitsPerComponent, bytesPerRow: destBytesPerRow, space: colorSpace, bitmapInfo: self.alphaInfo.rawValue) else { return nil }

        context.interpolationQuality = .none
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()
    }
    
    //realizeaza o masca pentru o anumita clasa
    func mask(modelClass: ModelClass) -> CGImage? {
        guard let cfData = dataProvider?.data, let pointer = CFDataGetBytePtr(cfData) else { return nil }
        let bounds = CGRect(x: 0, y:0, width: width, height: height)
        let bitmapContext = CGContext(data: nil,
                                      width: width, height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width,
                                      space: CGColorSpaceCreateDeviceGray(),
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue)
        guard let cgContext = bitmapContext else { return nil }
        cgContext.saveGState()
        cgContext.setFillColor(gray: 0, alpha: 1.0)
        cgContext.fill(bounds)
        guard let buffer = cgContext.data else { return nil }

        let pixelBuffer = buffer.bindMemory(to: UInt8.self, capacity: width * height)
        let value = modelClass.orderNumber
        for x in 0..<width {
            for y in 0..<height {
                let pixelAddress = 4*(x + y * width)
                if pointer[pixelAddress] == value {
                    pixelBuffer[pixelAddress/4] = 255
                }
            }
        }
        
        let mask = cgContext.makeImage()
        cgContext.restoreGState()
        return mask
    }
    
    //realizeaza lista de clase din imagine
    func classes() -> [ModelClass] {
        guard let cfData = dataProvider?.data, let pointer = CFDataGetBytePtr(cfData) else { return [] }
        
        var pixelCount:[ModelClass: Int] = ModelClass.allCases.reduce([:]) { partialResult, mClass in
            var newResult = partialResult
            newResult[mClass] = 0
            return newResult
        }
        
        for x in 0..<width {
            for y in 0..<height {
                let pixelAddress = 4*(x + y * width)
                pixelCount[ModelClass.modelClass(with: pointer[pixelAddress])]! += 1
            }
        }
        
        return pixelCount.filter({ key, value in
            value > 0
        }).filter({ $1 > 0 }).sorted { $0.value > $1.value } .map { $0.key }
    }
    
    //realizeaza harta de adnotari pentru in UI in functie de anumite culori RGB asociate unei clase
    func previewMap() -> CGImage? {
        guard let cfData = dataProvider?.data, let pointer = CFDataGetBytePtr(cfData) else { return nil }
        let bounds = CGRect(x: 0, y:0, width: width, height: height)
        let bitmapContext = CGContext(data: nil,
                                      width: width, height: height,
                                      bitsPerComponent: 8 ,
                                      bytesPerRow: width * 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let cgContext = bitmapContext else { return nil }
        cgContext.saveGState()
        cgContext.setFillColor(gray: 0, alpha: 1.0)
        cgContext.fill(bounds)
        guard let buffer = cgContext.data else { return nil }

        let pixelBuffer = buffer.bindMemory(to: UInt8.self, capacity: 4 * width * height)
        for x in 0..<width {
            for y in 0..<height {
                let pixelAddress = 4*(x + y * width)
                let color = ModelClass.modelClass(with: pointer[pixelAddress]).color
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0

                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                pixelBuffer[pixelAddress] = (Float32(red) * 255).toUInt8
                pixelBuffer[pixelAddress + 1] = (Float32(green) * 255).toUInt8
                pixelBuffer[pixelAddress + 2] = (Float32(blue) * 255).toUInt8
                pixelBuffer[pixelAddress + 3] = (Float32(alpha) * 255).toUInt8
            }
        }
        
        let map = cgContext.makeImage()
        cgContext.restoreGState()
        return map
    }
}
