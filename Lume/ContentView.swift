//
//  ContentView.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 24.02.2025.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var inputImage: UIImage?
    @State private var filteredImage: UIImage?
    @State private var showImagePicker = false
    @State private var presets: [String: LightroomPreset] = [:]
    @State private var selectedPresetName: String?
    @State private var adjustedPreset: LightroomPreset?
    @State private var isApplyingPreset = false
    @State private var showOriginal = false
    
    // For Save Image Alert
    @State private var showSaveAlert = false
    @State private var saveAlertMessage = ""
    
    var body: some View {
        ZStack {
            // Full-screen background gradient.
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundStart"), Color("BackgroundEnd")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            // Wrap content in a vertical ScrollView
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Title with a bold, rounded font and shadow.
                    Text("Lume Filter App")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                        .padding(.top, 40)
                    
                    // Enlarged Image Preview.
                    if let displayedImage = showOriginal ? inputImage : filteredImage ?? inputImage {
                        ZStack {
                            Image(uiImage: displayedImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.8), lineWidth: 4)
                                )
                                .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
                                .padding()
                                .onLongPressGesture(minimumDuration: 0.1) {
                                    withAnimation { showOriginal = true }
                                } onPressingChanged: { isPressing in
                                    withAnimation { showOriginal = isPressing }
                                }
                        }
                        .frame(height: 400)
                        .transition(.scale)
                    } else {
                        Text("Select an image to get started")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.headline)
                            .frame(height: 400)
                    }
                    
                    // Preset Selection Menu.
                    if !presets.isEmpty {
                        Menu {
                            ForEach(presets.keys.sorted(), id: \.self) { name in
                                Button(action: {
                                    selectedPresetName = name
                                    // Create a working copy for adjustments.
                                    adjustedPreset = presets[name]
                                }) {
                                    Label(name, systemImage: "wand.and.stars")
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedPresetName ?? "Select a Filter")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Adjustment Sliders Section.
                    if adjustedPreset != nil {
                        ScrollView {
                            VStack(spacing: 15) {
                                Group {
                                    adjustmentSlider(title: "Exposure", value: Binding(
                                        get: { adjustedPreset?.exposure ?? 0 },
                                        set: { newVal in adjustedPreset?.exposure = newVal }
                                    ), range: -2...2)
                                    
                                    adjustmentSlider(title: "Contrast", value: Binding(
                                        get: { adjustedPreset?.contrast ?? 0 },
                                        set: { newVal in adjustedPreset?.contrast = newVal }
                                    ), range: -1...1)
                                    
                                    adjustmentSlider(title: "Saturation", value: Binding(
                                        get: { adjustedPreset?.saturation ?? 0 },
                                        set: { newVal in adjustedPreset?.saturation = newVal }
                                    ), range: -1...1)
                                    
                                    adjustmentSlider(title: "Highlights", value: Binding(
                                        get: { adjustedPreset?.highlights ?? 0 },
                                        set: { newVal in adjustedPreset?.highlights = newVal }
                                    ), range: -1...1)
                                    
                                    adjustmentSlider(title: "Shadows", value: Binding(
                                        get: { adjustedPreset?.shadows ?? 0 },
                                        set: { newVal in adjustedPreset?.shadows = newVal }
                                    ), range: -1...1)
                                }
                                
                                Group {
                                    adjustmentSlider(title: "Clarity", value: Binding(
                                        get: { adjustedPreset?.clarity ?? 0 },
                                        set: { newVal in adjustedPreset?.clarity = newVal }
                                    ), range: -1...1)
                                    
                                    adjustmentSlider(title: "Vibrance", value: Binding(
                                        get: { adjustedPreset?.vibrance ?? 0 },
                                        set: { newVal in adjustedPreset?.vibrance = newVal }
                                    ), range: -1...1)
                                    
                                    adjustmentSlider(title: "Sharpness", value: Binding(
                                        get: { adjustedPreset?.sharpness ?? 0 },
                                        set: { newVal in adjustedPreset?.sharpness = newVal }
                                    ), range: -1...1)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                        .frame(height: 280)
                    }
                    
                    // Buttons Section.
                    HStack(spacing: 20) {
                        Button(action: { showImagePicker = true }) {
                            HStack {
                                Image(systemName: "photo")
                                Text("Select Image")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        
                        // Save button appears only if there is a filtered image.
                        if filteredImage != nil {
                            Button(action: saveImage) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Save Image")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.yellow]),
                                    startPoint: .leading,
                                    endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage, processedImage: $inputImage)
        }
        // Automatically reapply preset whenever adjustedPreset or inputImage changes.
        .onChange(of: adjustedPreset) { _ in
            if inputImage != nil, adjustedPreset != nil {
                applyPreset()
            }
        }
        .onChange(of: inputImage) { _ in
            if inputImage != nil, adjustedPreset != nil {
                applyPreset()
            }
        }
        // Alert for save completion.
        .alert(isPresented: $showSaveAlert) {
            Alert(title: Text("Save Image"), message: Text(saveAlertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            loadPresets()
        }
    }
    
    // Reusable slider view for adjustment controls.
    func adjustmentSlider(title: String, value: Binding<Float>, range: ClosedRange<Float>) -> some View {
        VStack(alignment: .leading) {
            Text("\(title): \(value.wrappedValue, specifier: "%.2f")")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            Slider(value: value, in: range)
                .accentColor(.white)
        }
        .padding(.vertical, 5)
    }
    
    // Load presets from JSON if available; otherwise, use hardcoded defaults.
    func loadPresets() {
        if let loadedPresets = loadAllPresets() {
            presets = loadedPresets
        } else {
            presets = [
                "Vintage Film": vintageFilmPreset,
                "Faded Retro": fadedRetroPreset,
                "Polaroid": polaroidPreset
            ]
        }
    }
    
    // Apply the preset using the adjusted values.
    func applyPreset() {
        guard let inputImage = inputImage, let preset = adjustedPreset else { return }
        isApplyingPreset = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let processor = PresetProcessor()
            if let output = processor.applyPreset(to: inputImage, preset: preset) {
                DispatchQueue.main.async {
                    self.filteredImage = output
                    self.isApplyingPreset = false
                }
            }
        }
    }
    
    // Save the filtered image to the Photo Library.
    func saveImage() {
        guard let image = filteredImage else { return }
        let saver = ImageSaver()
        saver.writeToPhotoAlbum(image: image) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.saveAlertMessage = "Error saving image: \(error.localizedDescription)"
                } else {
                    self.saveAlertMessage = "Image saved successfully!"
                }
                self.showSaveAlert = true
            }
        }
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

// MARK: - Image Picker for SwiftUI
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
                let fixedImage = fixImageOrientation(uiImage)
                parent.processedImage = fixedImage
            }
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

// MARK: - Fix Image Orientation
func fixImageOrientation(_ image: UIImage) -> UIImage {
    guard image.imageOrientation != .up else { return image }
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    image.draw(in: CGRect(origin: .zero, size: image.size))
    let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return fixedImage ?? image
}

// MARK: - Load Presets from JSON
func loadAllPresets() -> [String: LightroomPreset]? {
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
    } catch {
        print("❌ Error loading presets:", error)
        return nil
    }
    return presets
}

func loadPresetFromJSON(file: URL) -> LightroomPreset? {
    do {
        let data = try Data(contentsOf: file)
        let decoder = JSONDecoder()
        return try decoder.decode(LightroomPreset.self, from: data)
    } catch {
        print("❌ Error decoding JSON:", error)
        return nil
    }
}

#Preview {
    ContentView()
}
