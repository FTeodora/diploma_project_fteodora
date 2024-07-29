/*
  Copyright (c) 2017-2020 M.I. Hollemans

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

import Accelerate
import CoreML

public func clamp<T: Comparable>(_ x: T, min: T, max: T) -> T {
  if x < min { return min }
  if x > max { return max }
  return x
}

public protocol MultiArrayType: Comparable {
  static var multiArrayDataType: MLMultiArrayDataType { get }
  static func +(lhs: Self, rhs: Self) -> Self
  static func -(lhs: Self, rhs: Self) -> Self
  static func *(lhs: Self, rhs: Self) -> Self
  static func /(lhs: Self, rhs: Self) -> Self
  init(_: Int)
  var toUInt8: UInt8 { get }
}

extension Float: MultiArrayType {
  public static var multiArrayDataType: MLMultiArrayDataType { return .float32 }
  public var toUInt8: UInt8 { return UInt8(self) }
}
// Am modificat si adaptat functiile pentru modelul meu
extension MLMultiArray {

    public func annotationImage() -> CGImage? {
      if let (b, w, h) = toRawBytes() {
          return CGImage.fromByteArrayRGBA(b, width: w, height: h)
      }
      return nil
  }
    
    public func labelsToImage(with size: CGSize) -> CGImage? {
        let heightAxis: Int = 0
        let widthAxis: Int = 1

        let height = self.shape[0].intValue
        let width = self.shape[1].intValue
        let yStride = self.strides[heightAxis].intValue
        let xStride = self.strides[widthAxis].intValue

        let bytesPerPixel: Int = 4

        let count = height * width * bytesPerPixel
        var pixels = [UInt8](repeating: 0, count: count)

        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(self.dataPointer))
        for y in 0..<height {
            for x in 0..<width {
                let value = ptr[y*yStride + x*xStride]
                pixels[(y*width + x)*bytesPerPixel] = value.toUInt8
                pixels[(y*width + x)*bytesPerPixel + 1] = value.toUInt8
                pixels[(y*width + x)*bytesPerPixel + 2] = value.toUInt8
                pixels[(y*width + x)*bytesPerPixel + 3] = 255
            }
        }
        return CGImage.fromByteArrayRGBA(pixels, width: width, height: height)?.resize(size: size)
    }
    
    public func toRawBytes() -> (bytes: [UInt8], width: Int, height: Int)? {
        let heightAxis: Int = 0
        let widthAxis: Int = 1

        let height = self.shape[0].intValue
        let width = self.shape[1].intValue
        let yStride = self.strides[heightAxis].intValue
        let xStride = self.strides[widthAxis].intValue

        let bytesPerPixel: Int = 4

        let count = height * width * bytesPerPixel
        var pixels = [UInt8](repeating: 0, count: count)

        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(self.dataPointer))
        for y in 0..<height {
            for x in 0..<width {
                
                let value = ptr[ y*yStride + x*xStride]
                let color = ModelClass.modelClass(with: value.toUInt8).color
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0

                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                pixels[(y*width + x)*bytesPerPixel] = (Float32(red) * 255).toUInt8
                pixels[(y*width + x)*bytesPerPixel + 1] = (Float32(green) * 255).toUInt8
                pixels[(y*width + x)*bytesPerPixel + 2] = (Float32(blue) * 255).toUInt8
                pixels[(y*width + x)*bytesPerPixel + 3] = (Float32(alpha) * 255).toUInt8
            }
        }
        return (pixels, width, height)
    }
    
}

/**
  Fast conversion from MLMultiArray to CGImage using the vImage framework.

  - Parameters:
    - features: A multi-array with data type FLOAT32 and three dimensions
                (3, height, width).
    - min: The smallest value in the multi-array. This value, as well as any
           smaller values, will be mapped to 0 in the output image.
    - max: The largest value in the multi-array. This and any larger values
           will be will be mapped to 255 in the output image.

  - Returns: a new CGImage or nil if the conversion fails
*/
public func createCGImage(fromFloatArray features: MLMultiArray,
                          min: Float = 0,
                          max: Float = 255) -> CGImage? {
  assert(features.dataType == .float32)
  assert(features.shape.count == 3)

  let ptr = UnsafeMutablePointer<Float>(OpaquePointer(features.dataPointer))

  let height = features.shape[1].intValue
  let width = features.shape[2].intValue
  let channelStride = features.strides[0].intValue
  let rowStride = features.strides[1].intValue
  let srcRowBytes = rowStride * MemoryLayout<Float>.stride

  var blueBuffer = vImage_Buffer(data: ptr,
                                 height: vImagePixelCount(height),
                                 width: vImagePixelCount(width),
                                 rowBytes: srcRowBytes)
  var greenBuffer = vImage_Buffer(data: ptr.advanced(by: channelStride),
                                  height: vImagePixelCount(height),
                                  width: vImagePixelCount(width),
                                  rowBytes: srcRowBytes)
  var redBuffer = vImage_Buffer(data: ptr.advanced(by: channelStride * 2),
                                height: vImagePixelCount(height),
                                width: vImagePixelCount(width),
                                rowBytes: srcRowBytes)

  let destRowBytes = width * 4

  var error: vImage_Error = 0
  var pixels = [UInt8](repeating: 0, count: height * destRowBytes)

  pixels.withUnsafeMutableBufferPointer { ptr in
      var destBuffer = vImage_Buffer(data: ptr.baseAddress,
                                   height: vImagePixelCount(height),
                                   width: vImagePixelCount(width),
                                   rowBytes: destRowBytes)

    error = vImageConvert_PlanarFToBGRX8888(&blueBuffer,
                                            &greenBuffer,
                                            &redBuffer,
                                            Pixel_8(255),
                                            &destBuffer,
                                            [max, max, max],
                                            [min, min, min],
                                            vImage_Flags(0))
  }

  if error == kvImageNoError {
    return CGImage.fromByteArrayRGBA(pixels, width: width, height: height)
  } else {
    return nil
  }
}

extension MLMultiArray {
    func classList(padding: Int = 2) -> [ModelClass] {
        var pixelCount:[ModelClass: Int] = ModelClass.allCases.reduce([:]) { partialResult, mClass in
            var newResult = partialResult
            newResult[mClass] = 0
            return newResult
        }
        let heightAxis: Int = 0
        let widthAxis: Int = 1

        let height = self.shape[0].intValue
        let width = self.shape[1].intValue
        let yStride = self.strides[heightAxis].intValue
        let xStride = self.strides[widthAxis].intValue

        let cStride: Int = 0
        let channelOffset: Int = 0

        var ptr = UnsafeMutablePointer<Float32>(OpaquePointer(self.dataPointer))
        ptr = ptr.advanced(by: channelOffset * cStride)
        for y in 0+padding..<height-padding {
            for x in 0+padding..<width-padding {
                let value = ptr[y*yStride + x*xStride].toUInt8
                pixelCount[ModelClass.modelClass(with: value)]! += 1
            }
        }
        return pixelCount.filter{ $0.value > 0 }.sorted { $0.value > $1.value }.map { $0.key }
    }
}
