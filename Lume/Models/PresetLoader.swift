//
//  PresetLoader.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 24.02.2025.
//

import Foundation

/// A service for loading, saving, and managing presets from both bundle resources and user storage
class PresetLoader {
    
    // MARK: - Constants
    
    /// Filename for storing custom presets
    private static let customPresetsFilename = "custom_presets.json"
    
    // MARK: - Bundle Presets
    
    /// Loads all presets from bundle JSON files
    /// - Returns: Dictionary of preset names to preset objects, or nil if loading fails
    static func loadAllPresets() -> [String: LightroomPreset]? {
        var presets: [String: LightroomPreset] = [:]
        guard let bundleURL = Bundle.main.resourceURL else {
            print("❌ Resource folder not found")
            return nil
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil)
            for file in files where file.pathExtension == "json" {
                let filename = file.deletingPathExtension().lastPathComponent
                if let preset = loadPresetFromJSON(file: file) {
                    presets[filename] = preset
                }
            }
            
            if !presets.isEmpty {
                print("✅ Loaded \(presets.count) presets from bundle")
            } else {
                print("⚠️ No presets found in bundle")
            }
            
            return presets
        } catch {
            print("❌ Error loading presets: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Loads a single preset from a JSON file
    /// - Parameter file: URL to the JSON file
    /// - Returns: A LightroomPreset object if successful, nil otherwise
    static func loadPresetFromJSON(file: URL) -> LightroomPreset? {
        do {
            let data = try Data(contentsOf: file)
            let decoder = JSONDecoder()
            let preset = try decoder.decode(LightroomPreset.self, from: data)
            return preset
        } catch {
            print("❌ Error decoding JSON at \(file.lastPathComponent): \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Custom Presets
    
    /// Saves custom presets to the documents directory
    /// - Parameter presets: Dictionary of preset names to preset objects
    /// - Returns: Boolean indicating success/failure
    @discardableResult
    static func saveCustomPresets(_ presets: [String: LightroomPreset]) -> Bool {
        do {
            // Filter to only save user-created presets (not system ones that start with '_')
            let userPresets = presets.filter { !$0.key.hasPrefix("_") && !$0.key.contains(" 2") }
            
            guard !userPresets.isEmpty else {
                print("ℹ️ No custom presets to save")
                return true
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(userPresets)
            
            let fileURL = getCustomPresetsFileURL()
            try data.write(to: fileURL)
            
            print("✅ Saved \(userPresets.count) custom presets")
            return true
        } catch {
            print("❌ Error saving custom presets: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Loads custom presets from the documents directory
    /// - Returns: Dictionary of preset names to preset objects, or nil if none exist
    static func loadCustomPresets() -> [String: LightroomPreset]? {
        let fileURL = getCustomPresetsFileURL()
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("ℹ️ No custom presets file found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let loadedPresets = try decoder.decode([String: LightroomPreset].self, from: data)
            
            print("✅ Loaded \(loadedPresets.count) custom presets")
            return loadedPresets
        } catch {
            print("❌ Error loading custom presets: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Deletes a custom preset by name
    /// - Parameter name: Name of the preset to delete
    /// - Returns: Boolean indicating success/failure
    @discardableResult
    static func deleteCustomPreset(named name: String) -> Bool {
        guard var customPresets = loadCustomPresets() else {
            return false
        }
        
        guard customPresets[name] != nil else {
            print("⚠️ Preset '\(name)' not found")
            return false
        }
        
        customPresets.removeValue(forKey: name)
        return saveCustomPresets(customPresets)
    }
    
    // MARK: - Helper Methods
    
    /// Gets the file URL for custom presets storage
    /// - Returns: URL for the custom presets file
    private static func getCustomPresetsFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(customPresetsFilename)
    }
    
    /// Checks if a preset is a system preset
    /// - Parameter name: Name of the preset to check
    /// - Returns: Boolean indicating if it's a system preset
    static func isSystemPreset(_ name: String) -> Bool {
        return name.hasPrefix("_") || name.contains(" 2")
    }
}
