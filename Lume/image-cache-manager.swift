import UIKit
import CoreImage
import Foundation

// MARK: - Image Cache Manager

/// A singleton class that manages image caching for faster preset switching
class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private init() {}
    
    // Cache to store processed images by preset name
    private var imageCache: [String: UIImage] = [:]
    
    // Maximum number of cached images to manage memory usage
    private let cacheLimit = 15
    
    // Track the order of cache access for LRU implementation
    private var cacheAccessOrder: [String] = []
    
    /// Stores a processed image in the cache
    /// - Parameters:
    ///   - image: The processed image to store
    ///   - presetName: The name of the preset used to create the image
    ///   - originalImageID: A unique identifier for the original image
    func cacheImage(_ image: UIImage, forPreset presetName: String, originalImageID: String) {
        let cacheKey = "\(originalImageID)_\(presetName)"
        
        // If this key already exists, update its position in the access order
        if imageCache[cacheKey] != nil {
            if let index = cacheAccessOrder.firstIndex(of: cacheKey) {
                cacheAccessOrder.remove(at: index)
            }
        }
        
        // Add to cache and update access order
        imageCache[cacheKey] = image
        cacheAccessOrder.append(cacheKey)
        
        // If the cache exceeds the limit, remove the least recently used item
        if cacheAccessOrder.count > cacheLimit, let oldestKey = cacheAccessOrder.first {
            imageCache.removeValue(forKey: oldestKey)
            cacheAccessOrder.removeFirst()
        }
    }
    
    /// Retrieves a cached image if available
    /// - Parameters:
    ///   - presetName: The name of the preset
    ///   - originalImageID: A unique identifier for the original image
    /// - Returns: The cached processed image or nil if not found
    func getCachedImage(forPreset presetName: String, originalImageID: String) -> UIImage? {
        let cacheKey = "\(originalImageID)_\(presetName)"
        
        // Update access order when retrieving from cache
        if let image = imageCache[cacheKey] {
            if let index = cacheAccessOrder.firstIndex(of: cacheKey) {
                cacheAccessOrder.remove(at: index)
            }
            cacheAccessOrder.append(cacheKey)
            return image
        }
        
        return nil
    }
    
    /// Clears the entire cache
    func clearCache() {
        imageCache.removeAll()
        cacheAccessOrder.removeAll()
    }
    
    /// Removes cached versions of a specific original image
    /// - Parameter originalImageID: The ID of the original image to remove
    func removeCachedVersions(forOriginalImage originalImageID: String) {
        // Find all keys that start with the original image ID
        let keysToRemove = imageCache.keys.filter { $0.hasPrefix("\(originalImageID)_") }
        
        // Remove from cache
        for key in keysToRemove {
            imageCache.removeValue(forKey: key)
            if let index = cacheAccessOrder.firstIndex(of: key) {
                cacheAccessOrder.remove(at: index)
            }
        }
    }
}

// MARK: - Extensions for UIImage Cache Support

extension UIImage {
    /// Generate a unique identifier for an image based on its data
    var cacheIdentifier: String {
        // If the image has a uniqueID already (perhaps set when loading), use that
        if let id = objc_getAssociatedObject(self, &AssociatedKeys.uniqueID) as? String {
            return id
        }
        
        // Otherwise, generate an ID based on image dimensions and a sample of pixels
        let size = self.size
        let sizeComponent = "\(Int(size.width))x\(Int(size.height))"
        
        // Create a hash from the image data (limited to reduce computation)
        if let imageData = self.jpegData(compressionQuality: 0.1) {
            let hash = imageData.prefix(1024).hashValue
            let identifier = "\(sizeComponent)_\(hash)"
            
            // Store the ID for future reference
            objc_setAssociatedObject(self, &AssociatedKeys.uniqueID, identifier, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return identifier
        }
        
        // Fallback if we can't get image data
        let timestamp = Date().timeIntervalSince1970
        let fallbackID = "\(sizeComponent)_\(timestamp)"
        objc_setAssociatedObject(self, &AssociatedKeys.uniqueID, fallbackID, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return fallbackID
    }
    
    /// Set a specific unique ID for the image (useful when loading from picker)
    func setUniqueIdentifier(_ identifier: String) {
        objc_setAssociatedObject(self, &AssociatedKeys.uniqueID, identifier, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// Associated objects key for UIImage extension
private struct AssociatedKeys {
    static var uniqueID = "UniqueImageIdentifier"
}

// MARK: - Enhanced PresetProcessor with Caching

extension PresetProcessor {
    /// Apply a preset to an image with caching support
    /// - Parameters:
    ///   - image: The original image to process
    ///   - preset: The preset to apply
    ///   - presetName: The name of the preset (for caching)
    ///   - useCache: Whether to use caching (default true)
    /// - Returns: The processed image
    func applyPresetWithCaching(to image: UIImage, preset: LightroomPreset, presetName: String, useCache: Bool = true) -> UIImage? {
        // Check cache first if enabled
        if useCache {
            if let cachedImage = ImageCacheManager.shared.getCachedImage(forPreset: presetName, originalImageID: image.cacheIdentifier) {
                return cachedImage
            }
        }
        
        // Process the image if not in cache
        guard let processedImage = applyPreset(to: image, preset: preset) else {
            return nil
        }
        
        // Store in cache if caching is enabled
        if useCache {
            ImageCacheManager.shared.cacheImage(processedImage, forPreset: presetName, originalImageID: image.cacheIdentifier)
        }
        
        return processedImage
    }
}

// MARK: - ContentView Extension for Using Cache

extension ContentView {
    /// Apply a preset with caching support
    func applyPresetWithCaching() {
        guard let inputImage = inputImage,
              let preset = adjustedPreset,
              let presetName = selectedPresetName else { return }
        
        isApplyingPreset = true
        
        // Use background thread for heavy processing
        DispatchQueue.global(qos: .userInitiated).async {
            let processor = PresetProcessor()
            
            // Determine if we should use caching
            // For custom adjustments, don't use cache since they're temporary
            let useCache = !presetName.hasPrefix("Adjusted_")
            
            if let output = processor.applyPresetWithCaching(
                to: inputImage,
                preset: preset,
                presetName: presetName,
                useCache: useCache
            ) {
                DispatchQueue.main.async {
                    self.filteredImage = output
                    self.isApplyingPreset = false
                }
            }
        }
    }
    
    /// Clear image cache when changing images
    func clearCacheForCurrentImage() {
        if let image = inputImage {
            ImageCacheManager.shared.removeCachedVersions(forOriginalImage: image.cacheIdentifier)
        }
    }
}
