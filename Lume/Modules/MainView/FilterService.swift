//
//  FilterService.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
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
}

// Filter Service to apply Core Image filters
class FilterService {
    private let context = CIContext()
    
    func applyFilter(_ filter: FilterType, to inputImage: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: inputImage) else { return nil }
        
        var filteredImage: CIImage?
        
        switch filter {
        case .none:
            return inputImage
            
        case .sepia:
            let filter = CIFilter.sepiaTone()
            filter.inputImage = ciImage
            filter.intensity = 0.8
            filteredImage = filter.outputImage
            
        case .noir:
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = ciImage
            filteredImage = filter.outputImage
            
        case .vibrant:
            let filter = CIFilter.vibrance()
            filter.inputImage = ciImage
            filter.amount = 1.0
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
        
        // Create UIImage without specifying orientation to preserve the original
        return UIImage(cgImage: cgImage)
    }
}
