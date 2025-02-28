//
//  PresetProcessor.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 24.02.2025.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

// MARK: - Supporting Structures

struct WhiteBalance: Codable, Equatable {
    var temp: Float
    var tint: Float
}

struct ToneCurvePoint: Codable, Equatable {
    var x: Float
    var y: Float
}

struct LightroomPreset: Codable, Equatable {
    var exposure: Float
    var contrast: Float
    var saturation: Float
    var highlights: Float
    var shadows: Float
    var whiteBalance: WhiteBalance
    var toneCurve: [ToneCurvePoint]
    var hueAdjustments: [String: Float]?
    var saturationAdjustments: [String: Float]?
    var luminanceAdjustments: [String: Float]?
    var clarity: Float?
    var vibrance: Float?
    var sharpness: Float?
    var grainAmount: Float?
    var grainSize: Float?
    var grainFrequency: Float?
    var lutImage: String?
}

// MARK: - PresetProcessor

final class PresetProcessor {
    // Lazy initialization so that CIContext is created only when needed.
    lazy var context = CIContext()

    /// Applies a Lightroom preset to a given UIImage.
    func applyPreset(to image: UIImage, preset: LightroomPreset) -> UIImage? {
        guard var outputImage = CIImage(image: image) else { return nil }
        
        // 1. White Balance – apply first to normalize colors.
        outputImage = applyWhiteBalance(to: outputImage, whiteBalance: preset.whiteBalance)
        // 2. Exposure adjustment.
        outputImage = applyExposure(to: outputImage, exposure: preset.exposure)
        // 3. Highlights & Shadows.
        outputImage = applyHighlightShadowAdjust(to: outputImage, highlights: preset.highlights, shadows: preset.shadows)
        // 4. Tone Curve.
        if !preset.toneCurve.isEmpty {
            outputImage = applyToneCurve(to: outputImage, controlPoints: preset.toneCurve.map { ($0.x, $0.y) }) ?? outputImage
        }
        // 5. Global Color Controls (Contrast & Saturation).
        outputImage = applyColorControls(to: outputImage, contrast: preset.contrast, saturation: preset.saturation)
        // 6. HSL Adjustments.
        outputImage = applyHSLAdjustments(to: outputImage, preset: preset) ?? outputImage
        // 7. Clarity, Vibrance, and Sharpness.
        if let clarity = preset.clarity {
            outputImage = applyClarity(to: outputImage, amount: CGFloat(clarity)) ?? outputImage
        }
        if let vibrance = preset.vibrance {
            outputImage = applyVibrance(to: outputImage, amount: CGFloat(vibrance)) ?? outputImage
        }
        if let sharpness = preset.sharpness {
            outputImage = applySharpening(to: outputImage, amount: CGFloat(sharpness)) ?? outputImage
        }
        // 8. Grain Effect.
        if let grain = preset.grainAmount,
           let grainSize = preset.grainSize,
           let grainFrequency = preset.grainFrequency {
            outputImage = applyGrain(to: outputImage, amount: CGFloat(grain), size: CGFloat(grainSize), frequency: CGFloat(grainFrequency)) ?? outputImage
        }
        // 9. LUT Processing: if a LUT image is provided, apply it.
        if let lutPath = preset.lutImage, !lutPath.isEmpty,
           let lutUIImage = UIImage(contentsOfFile: lutPath) {
            outputImage = applyLUT(to: outputImage, lutImage: lutUIImage) ?? outputImage
        }

        // Convert CIImage back to UIImage.
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    // MARK: - Filter Application Functions

    private func applyExposure(to image: CIImage, exposure: Float) -> CIImage {
        let filter = CIFilter.exposureAdjust()
        filter.inputImage = image
        filter.ev = exposure
        return filter.outputImage ?? image
    }

    private func applyColorControls(to image: CIImage, contrast: Float, saturation: Float) -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.contrast = 1.0 + contrast
        filter.saturation = 1.0 + saturation
        return filter.outputImage ?? image
    }

    private func applyHighlightShadowAdjust(to image: CIImage, highlights: Float, shadows: Float) -> CIImage {
        let filter = CIFilter.highlightShadowAdjust()
        filter.inputImage = image
        filter.highlightAmount = 1.0 + highlights
        filter.shadowAmount = 1.0 + shadows
        return filter.outputImage ?? image
    }

    private func applyWhiteBalance(to image: CIImage, whiteBalance: WhiteBalance) -> CIImage {
        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = image
        filter.neutral = CIVector(x: CGFloat(whiteBalance.temp), y: CGFloat(whiteBalance.tint))
        return filter.outputImage ?? image
    }

    /// Applies a tone curve using up to 5 control points. Missing points are filled with an identity curve.
    private func applyToneCurve(to image: CIImage, controlPoints: [(Float, Float)]) -> CIImage? {
        let filter = CIFilter.toneCurve()
        filter.inputImage = image
        
        // Define identity curve points normalized to 0...1.
        let identityPoints: [CGPoint] = [
            CGPoint(x: 0/255.0,   y: 0/255.0),
            CGPoint(x: 64/255.0,  y: 64/255.0),
            CGPoint(x: 128/255.0, y: 128/255.0),
            CGPoint(x: 192/255.0, y: 192/255.0),
            CGPoint(x: 255/255.0, y: 255/255.0)
        ]
        
        var finalPoints = identityPoints
        let count = min(controlPoints.count, 5)
        for i in 0..<count {
            finalPoints[i] = CGPoint(x: CGFloat(controlPoints[i].0 / 255.0),
                                     y: CGFloat(controlPoints[i].1 / 255.0))
        }
        filter.point0 = finalPoints[0]
        filter.point1 = finalPoints[1]
        filter.point2 = finalPoints[2]
        filter.point3 = finalPoints[3]
        filter.point4 = finalPoints[4]
        
        return filter.outputImage
    }

    /// Applies HSL adjustments by combining provided channel values.
    private func applyHSLAdjustments(to image: CIImage, preset: LightroomPreset) -> CIImage? {
        var outputImage = image
        
        // Combine hue adjustments (averaging and converting degrees to radians).
        if let hueAdjustments = preset.hueAdjustments, !hueAdjustments.isEmpty {
            let combinedHue = hueAdjustments.values.reduce(0, +) / Float(hueAdjustments.count)
            let hueFilter = CIFilter.hueAdjust()
            hueFilter.inputImage = outputImage
            hueFilter.angle = combinedHue * (.pi / 180)
            outputImage = hueFilter.outputImage ?? outputImage
        }
        
        // Combine saturation adjustments.
        if let satAdjustments = preset.saturationAdjustments, !satAdjustments.isEmpty {
            let combinedSat = satAdjustments.values.reduce(0, +) / Float(satAdjustments.count)
            let saturationFilter = CIFilter.colorControls()
            saturationFilter.inputImage = outputImage
            saturationFilter.saturation = 1.0 + (combinedSat / 100.0)
            outputImage = saturationFilter.outputImage ?? outputImage
        }
        
        // Combine luminance (brightness) adjustments.
        if let lumAdjustments = preset.luminanceAdjustments, !lumAdjustments.isEmpty {
            let combinedLum = lumAdjustments.values.reduce(0, +) / Float(lumAdjustments.count)
            let brightnessFilter = CIFilter.colorControls()
            brightnessFilter.inputImage = outputImage
            brightnessFilter.brightness = combinedLum / 100.0
            outputImage = brightnessFilter.outputImage ?? outputImage
        }
        
        return outputImage
    }

    private func applyClarity(to image: CIImage, amount: CGFloat) -> CIImage? {
        let filter = CIFilter.unsharpMask()
        filter.inputImage = image
        filter.radius = 2.0
        filter.intensity = Float(amount)
        return filter.outputImage
    }

    private func applyVibrance(to image: CIImage, amount: CGFloat) -> CIImage? {
        let filter = CIFilter.vibrance()
        filter.inputImage = image
        filter.amount = Float(amount)
        return filter.outputImage
    }

    private func applySharpening(to image: CIImage, amount: CGFloat) -> CIImage? {
        let filter = CIFilter.sharpenLuminance()
        filter.inputImage = image
        filter.sharpness = Float(amount)
        return filter.outputImage
    }

    private func applyGrain(to image: CIImage, amount: CGFloat, size: CGFloat, frequency: CGFloat) -> CIImage? {
        // Generate noise image and crop it.
        guard let noiseImage = CIFilter.randomGenerator().outputImage?.cropped(to: image.extent) else { return image }
        
        // Blur the noise to control the grain size.
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = noiseImage
        blurFilter.radius = Float(size / 10.0)
        let blurredNoise = blurFilter.outputImage ?? noiseImage
        
        // Adjust noise intensity.
        let exposureFilter = CIFilter.colorControls()
        exposureFilter.inputImage = blurredNoise
        exposureFilter.brightness = Float(amount / 100.0)
        exposureFilter.contrast = Float(frequency / 50.0)
        let adjustedNoise = exposureFilter.outputImage ?? blurredNoise
        
        // Blend the noise over the original image.
        let blendFilter = CIFilter.overlayBlendMode()
        blendFilter.inputImage = adjustedNoise
        blendFilter.backgroundImage = image
        
        return blendFilter.outputImage
    }
    
    /// Applies a LUT (Look-Up Table) to the image using a provided LUT image.
    private func applyLUT(to image: CIImage, lutImage: UIImage) -> CIImage? {
        // Convert the LUT image to a CIImage.
        guard let lutCIImage = CIImage(image: lutImage) else { return image }
        
        // Assume the LUT image is arranged as a square where the cube dimension is the cube root of the pixel count.
        let dimensionFloat = pow(lutCIImage.extent.width * lutCIImage.extent.height, 1.0/3.0)
        let dimension = Int(round(dimensionFloat))
        guard dimension > 0 else { return image }
        
        // Prepare a temporary context for rendering the LUT.
        let tempContext = CIContext(options: nil)
        let lutExtent = CGRect(x: 0, y: 0, width: lutCIImage.extent.width, height: lutCIImage.extent.height)
        let rowBytes = Int(lutExtent.width) * 4
        var bitmap = [UInt8](repeating: 0, count: Int(lutExtent.width * lutExtent.height) * 4)
        tempContext.render(lutCIImage,
                           toBitmap: &bitmap,
                           rowBytes: rowBytes,
                           bounds: lutExtent,
                           format: .RGBA8,
                           colorSpace: CGColorSpaceCreateDeviceRGB())
        
        let data = Data(bitmap)
        
        let colorCubeFilter = CIFilter.colorCube()
        colorCubeFilter.inputImage = image
        colorCubeFilter.cubeDimension = Float(dimension)
        colorCubeFilter.cubeData = data
        
        return colorCubeFilter.outputImage
    }
}
