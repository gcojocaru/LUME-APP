//
//  LightroomPreset.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 24.02.2025.
//

import Foundation
import UIKit

// MARK: - Supporting Structures

/// Represents white balance settings with temperature and tint
struct WhiteBalance: Codable, Equatable {
    /// Color temperature, typically between 2000K and 8000K
    var temp: Float
    
    /// Color tint adjustment, typically between -150 and +150
    var tint: Float
}

/// Represents a single point on the tone curve
struct ToneCurvePoint: Codable, Equatable {
    /// X coordinate (input value), range 0-255
    var x: Float
    
    /// Y coordinate (output value), range 0-255
    var y: Float
}

/// Represents a complete Lightroom-style editing preset
struct LightroomPreset: Codable, Equatable, Identifiable {
    // MARK: - Properties
    
    /// Unique identifier for the preset
    var id: String {
        // Generate a hash from preset values to use as identifier
        let values = [
            String(exposure),
            String(contrast),
            String(saturation),
            String(highlights),
            String(shadows),
            String(whiteBalance.temp),
            String(whiteBalance.tint)
        ]
        return values.joined(separator: "_").hash.description
    }
    
    // MARK: - Basic Adjustments
    
    /// Exposure adjustment, typically -5.0 to 5.0
    var exposure: Float
    
    /// Contrast adjustment, typically -100.0 to 100.0
    var contrast: Float
    
    /// Color saturation adjustment, typically -100.0 to 100.0
    var saturation: Float
    
    // MARK: - Light Adjustments
    
    /// Highlights recovery, typically -100.0 to 100.0
    var highlights: Float
    
    /// Shadow recovery, typically -100.0 to 100.0
    var shadows: Float
    
    /// White balance settings
    var whiteBalance: WhiteBalance
    
    // MARK: - Tone Curve
    
    /// Points defining the tone curve
    var toneCurve: [ToneCurvePoint]
    
    // MARK: - Color Adjustments
    
    /// Hue adjustments per color channel
    var hueAdjustments: [String: Float]?
    
    /// Saturation adjustments per color channel
    var saturationAdjustments: [String: Float]?
    
    /// Luminance adjustments per color channel
    var luminanceAdjustments: [String: Float]?
    
    // MARK: - Detail Adjustments
    
    /// Clarity/texture adjustment, typically -100.0 to 100.0
    var clarity: Float?
    
    /// Vibrance adjustment, typically -100.0 to 100.0
    var vibrance: Float?
    
    /// Sharpness adjustment, typically 0.0 to 150.0
    var sharpness: Float?
    
    // MARK: - Effects
    
    /// Film grain amount, typically 0.0 to 100.0
    var grainAmount: Float?
    
    /// Film grain size, typically 0.0 to 100.0
    var grainSize: Float?
    
    /// Film grain frequency, typically 0.0 to 100.0
    var grainFrequency: Float?
    
    /// Path to a LUT file for color grading
    var lutImage: String?
    
    // MARK: - Methods
    
    /// Creates a copy of this preset
    func copy() -> LightroomPreset {
        return LightroomPreset(
            exposure: self.exposure,
            contrast: self.contrast,
            saturation: self.saturation,
            highlights: self.highlights,
            shadows: self.shadows,
            whiteBalance: WhiteBalance(
                temp: self.whiteBalance.temp,
                tint: self.whiteBalance.tint
            ),
            toneCurve: self.toneCurve.map { ToneCurvePoint(x: $0.x, y: $0.y) },
            hueAdjustments: self.hueAdjustments,
            saturationAdjustments: self.saturationAdjustments,
            luminanceAdjustments: self.luminanceAdjustments,
            clarity: self.clarity,
            vibrance: self.vibrance,
            sharpness: self.sharpness,
            grainAmount: self.grainAmount,
            grainSize: self.grainSize,
            grainFrequency: self.grainFrequency,
            lutImage: self.lutImage
        )
    }
    
    /// Creates a reset version of this preset with default values
    static func reset() -> LightroomPreset {
        return LightroomPreset(
            exposure: 0.0,
            contrast: 0.0,
            saturation: 0.0,
            highlights: 0.0,
            shadows: 0.0,
            whiteBalance: WhiteBalance(temp: 6500, tint: 0),
            toneCurve: [
                ToneCurvePoint(x: 0, y: 0),
                ToneCurvePoint(x: 255, y: 255)
            ],
            hueAdjustments: [
                "Red": 0, "Orange": 0, "Yellow": 0, "Green": 0,
                "Aqua": 0, "Blue": 0, "Purple": 0, "Magenta": 0
            ],
            saturationAdjustments: [
                "Red": 0, "Orange": 0, "Yellow": 0, "Green": 0,
                "Aqua": 0, "Blue": 0, "Purple": 0, "Magenta": 0
            ],
            luminanceAdjustments: [
                "Red": 0, "Orange": 0, "Yellow": 0, "Green": 0,
                "Aqua": 0, "Blue": 0, "Purple": 0, "Magenta": 0
            ],
            clarity: 0,
            vibrance: 0,
            sharpness: 0,
            grainAmount: 0,
            grainSize: 0,
            grainFrequency: 0,
            lutImage: nil
        )
    }
}
