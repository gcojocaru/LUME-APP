//
//  vintageFilmPreset.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 24.02.2025.
//

import Foundation
let vintageFilmPreset = LightroomPreset(
    exposure: 0.1,
    contrast: -0.1,
    saturation: -0.2,
    highlights: -0.3,
    shadows: 0.2,
    whiteBalance: WhiteBalance(temp: 6500, tint: 10),
    toneCurve: [
        ToneCurvePoint(x: 0,   y: 20),
        ToneCurvePoint(x: 64,  y: 80),
        ToneCurvePoint(x: 128, y: 128),
        ToneCurvePoint(x: 192, y: 175),
        ToneCurvePoint(x: 255, y: 235)
    ],
    hueAdjustments: [
        "Red": 5,
        "Orange": -5,
        "Yellow": 3,
        "Green": 0,
        "Aqua": -3,
        "Blue": -10,
        "Purple": 0,
        "Magenta": 5
    ],
    saturationAdjustments: [
        "Red": -10,
        "Orange": -10,
        "Yellow": -10,
        "Green": -5,
        "Aqua": -5,
        "Blue": -5,
        "Purple": -5,
        "Magenta": -10
    ],
    luminanceAdjustments: [
        "Red": 10,
        "Orange": 10,
        "Yellow": 5,
        "Green": 0,
        "Aqua": -5,
        "Blue": -10,
        "Purple": 0,
        "Magenta": -5
    ],
    clarity: -5,
    vibrance: -10,
    sharpness: -5,
    grainAmount: 40,
    grainSize: 50,
    grainFrequency: 30,
    lutImage: nil
)

let fadedRetroPreset = LightroomPreset(
    exposure: 0.0,
    contrast: -0.2,
    saturation: -0.3,
    highlights: -0.1,
    shadows: 0.3,
    whiteBalance: WhiteBalance(temp: 6800, tint: 15),
    toneCurve: [
        ToneCurvePoint(x: 0,   y: 10),
        ToneCurvePoint(x: 64,  y: 70),
        ToneCurvePoint(x: 128, y: 128),
        ToneCurvePoint(x: 192, y: 186),
        ToneCurvePoint(x: 255, y: 245)
    ],
    hueAdjustments: [
        "Red": 3,
        "Orange": 0,
        "Yellow": -2,
        "Green": 2,
        "Aqua": -2,
        "Blue": -8,
        "Purple": 4,
        "Magenta": 0
    ],
    saturationAdjustments: [
        "Red": -5,
        "Orange": -5,
        "Yellow": -5,
        "Green": -5,
        "Aqua": -5,
        "Blue": -5,
        "Purple": -5,
        "Magenta": -5
    ],
    luminanceAdjustments: [
        "Red": 5,
        "Orange": 5,
        "Yellow": 5,
        "Green": 0,
        "Aqua": -5,
        "Blue": -5,
        "Purple": 0,
        "Magenta": 0
    ],
    clarity: -10,
    vibrance: -15,
    sharpness: -3,
    grainAmount: 50,
    grainSize: 60,
    grainFrequency: 40,
    lutImage: nil
)

let polaroidPreset = LightroomPreset(
    exposure: 0.2,
    contrast: -0.3,
    saturation: -0.4,
    highlights: -0.2,
    shadows: 0.4,
    whiteBalance: WhiteBalance(temp: 7000, tint: 20),
    toneCurve: [
        ToneCurvePoint(x: 0,   y: 5),
        ToneCurvePoint(x: 64,  y: 50),
        ToneCurvePoint(x: 128, y: 128),
        ToneCurvePoint(x: 192, y: 200),
        ToneCurvePoint(x: 255, y: 240)
    ],
    hueAdjustments: [
        "Red": 7,
        "Orange": -3,
        "Yellow": 0,
        "Green": 5,
        "Aqua": -7,
        "Blue": -15,
        "Purple": 10,
        "Magenta": 5
    ],
    saturationAdjustments: [
        "Red": -15,
        "Orange": -15,
        "Yellow": -10,
        "Green": -10,
        "Aqua": -10,
        "Blue": -10,
        "Purple": -15,
        "Magenta": -15
    ],
    luminanceAdjustments: [
        "Red": 10,
        "Orange": 10,
        "Yellow": 5,
        "Green": 0,
        "Aqua": -5,
        "Blue": -10,
        "Purple": -5,
        "Magenta": 0
    ],
    clarity: -8,
    vibrance: -12,
    sharpness: -6,
    grainAmount: 60,
    grainSize: 70,
    grainFrequency: 50,
    lutImage: nil
)
