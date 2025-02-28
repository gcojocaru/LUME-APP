//
//  FilterService.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

//
//  FilterService.swift
//  Lume
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// Filter types enum
enum FilterType: String, CaseIterable {
    case none = "Original"
    case sepia = "Sepia"
    case noir = "Noir"
    case vibrant = "Vibrant"
    case chrome = "Chrome"
    case mono = "Mono"
    case fade = "Fade"
    case instant = "Instant"
    case process = "Process"
    
    var name: String {
        return rawValue
    }
    
    // Preview colors for filter buttons
    var previewColor: Color {
        switch self {
        case .none:
            return .gray
        case .sepia:
            return Color(red: 0.7, green: 0.5, blue: 0.3)
        case .noir:
            return .black
        case .vibrant:
            return .purple
        case .chrome:
            return Color(red: 0.8, green: 0.8, blue: 0.9)
        case .mono:
            return .gray
        case .fade:
            return Color(red: 0.7, green: 0.7, blue: 0.7)
        case .instant:
            return Color(red: 0.9, green: 0.8, blue: 0.7)
        case .process:
            return Color(red: 0.6, green: 0.8, blue: 1.0)
        }
    }
    
    // Default intensity value for each filter
    var defaultIntensity: Double {
        switch self {
        case .none:
            return 0.0
        case .sepia, .vibrant:
            return 0.8
        default:
            return 1.0
        }
    }
    
    // Returns true if this filter supports intensity adjustment
    var supportsIntensity: Bool {
        switch self {
        case .none:
            return false
        case .sepia, .vibrant:
            return true
        default:
            return false
        }
    }
    
    // Returns true if this filter supports image adjustments
    var supportsAdjustments: Bool {
        // All filters except 'none' support adjustments
        return self != .none
    }
}

// Filter Service to apply Core Image filters
class FilterService {
    private let context = CIContext()
    
    // Apply a single filter to an image
    func applyFilter(_ filter: FilterType, to inputImage: UIImage, intensity: Double? = nil) -> UIImage? {
        guard let ciImage = CIImage(image: inputImage) else { return nil }
        
        var filteredImage: CIImage?
        
        // Use provided intensity or default
        let filterIntensity = intensity ?? filter.defaultIntensity
        
        switch filter {
        case .none:
            return inputImage
            
        case .sepia:
            let filter = CIFilter.sepiaTone()
            filter.inputImage = ciImage
            filter.intensity = Float(filterIntensity)
            filteredImage = filter.outputImage
            
        case .noir:
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = ciImage
            filteredImage = filter.outputImage
            
        case .vibrant:
            let filter = CIFilter.vibrance()
            filter.inputImage = ciImage
            filter.amount = Float(filterIntensity)
            filteredImage = filter.outputImage
            
        case .chrome:
            let filter = CIFilter.photoEffectChrome()
            filter.inputImage = ciImage
            filteredImage = filter.outputImage
            
        case .mono:
            let filter = CIFilter.photoEffectMono()
            filter.inputImage = ciImage
            filteredImage = filter.outputImage
            
        case .fade:
            let filter = CIFilter.photoEffectFade()
            filter.inputImage = ciImage
            filteredImage = filter.outputImage
            
        case .instant:
            let filter = CIFilter.photoEffectInstant()
            filter.inputImage = ciImage
            filteredImage = filter.outputImage
            
        case .process:
            let filter = CIFilter.photoEffectProcess()
            filter.inputImage = ciImage
            filteredImage = filter.outputImage
        }
        
        // Convert CIImage back to UIImage
        guard let filteredImage = filteredImage,
              let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) else {
            return nil
        }
        
        // Create UIImage with original orientation
        return UIImage(cgImage: cgImage)
    }
    
    // Apply adjustments to an image
    func applyAdjustments(to image: UIImage, adjustments: ImageAdjustments) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        var processedImage = ciImage
        
        // Apply brightness adjustment if needed
        if adjustments.brightness != 0 {
            let brightnessFilter = CIFilter.colorControls()
            brightnessFilter.inputImage = processedImage
            brightnessFilter.brightness = Float(adjustments.brightness)
            if let outputImage = brightnessFilter.outputImage {
                processedImage = outputImage
            }
        }
        
        // Apply contrast adjustment if needed
        if adjustments.contrast != 0 {
            let contrastFilter = CIFilter.colorControls()
            contrastFilter.inputImage = processedImage
            contrastFilter.contrast = Float(1.0 + adjustments.contrast)
            if let outputImage = contrastFilter.outputImage {
                processedImage = outputImage
            }
        }
        
        // Apply saturation adjustment if needed
        if adjustments.saturation != 0 {
            let saturationFilter = CIFilter.colorControls()
            saturationFilter.inputImage = processedImage
            saturationFilter.saturation = Float(1.0 + adjustments.saturation)
            if let outputImage = saturationFilter.outputImage {
                processedImage = outputImage
            }
        }
        
        // Convert back to UIImage
        guard let cgImage = context.createCGImage(processedImage, from: processedImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // Combined method to apply both filter and adjustments
    func processImage(image: UIImage, filter: FilterType, filterIntensity: Double, adjustments: ImageAdjustments) -> UIImage? {
        // First apply the selected filter
        guard let filteredImage = applyFilter(filter, to: image, intensity: filterIntensity) else {
            return nil
        }
        
        // Then apply any adjustments if they exist
        if adjustments.brightness != 0 || adjustments.contrast != 0 || adjustments.saturation != 0 {
            return applyAdjustments(to: filteredImage, adjustments: adjustments)
        }
        
        return filteredImage
    }
}
