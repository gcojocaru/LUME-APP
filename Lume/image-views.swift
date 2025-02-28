import SwiftUI
import UIKit

// MARK: - Image Preview with Split Screen Capability

struct ImagePreviewView: View {
    let inputImage: UIImage
    let filteredImage: UIImage?
    @Binding var showOriginal: Bool
    @Binding var splitScreenMode: Bool
    
    var body: some View {
        ZStack {
            if splitScreenMode, let filteredImage = filteredImage {
                // Split screen view with before/after
                GeometryReader { geometry in
                    ZStack {
                        // Original image background
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(20)
                        
                        // Filtered image overlay with mask
                        Image(uiImage: filteredImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(20)
                            .mask(
                                Rectangle()
                                    .frame(width: geometry.size.width / 2, height: geometry.size.height)
                                    .position(x: geometry.size.width * 0.75, y: geometry.size.height / 2)
                            )
                        
                        // Divider line
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2, height: geometry.size.height)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        
                        // Before/After labels
                        HStack {
                            Text("Before")
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.leading)
                            
                            Spacer()
                            
                            Text("After")
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.trailing)
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.9)
                    }
                }
            } else {
                // Standard view with long press to preview original
                Image(uiImage: showOriginal ? inputImage : (filteredImage ?? inputImage))
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.8), lineWidth: 4)
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
                    .onLongPressGesture(minimumDuration: 0.1) {
                        withAnimation { showOriginal = true }
                    } onPressingChanged: { isPressing in
                        withAnimation { showOriginal = isPressing }
                    }
                    .overlay(
                        showOriginal ? 
                            Text("Original Image")
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding()
                                .position(x: 100, y: 40)
                        : nil
                    )
            }
        }
        .padding()
    }
}

// MARK: - Empty Image Placeholder

struct EmptyImagePlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
            
            VStack(spacing: 20) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Select an image to get started")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.headline)
            }
        }
        .padding()
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var processedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                let fixedImage = ImageUtils.fixImageOrientation(uiImage)
                parent.image = fixedImage
                parent.processedImage = fixedImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// MARK: - Image Utilities

enum ImageUtils {
    // Fix image orientation for proper display
    static func fixImageOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return fixedImage ?? image
    }
}

// MARK: - Image Saver Helper

class ImageSaver: NSObject {
    var onComplete: ((Error?) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage, completion: @escaping (Error?) -> Void) {
        onComplete = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        onComplete?(error)
    }
}
