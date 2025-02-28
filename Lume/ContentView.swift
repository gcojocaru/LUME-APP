import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State var inputImage: UIImage?
    @State var filteredImage: UIImage?
    @State var showImagePicker = false
    @State var presets: [String: LightroomPreset] = [:]
    @State var selectedPresetName: String?
    @State var adjustedPreset: LightroomPreset?
    @State var isApplyingPreset = false
    @State var showOriginal = false
    @State var splitScreenMode = false
    @State var filterHistory: [(String, LightroomPreset)] = []
    @State var favoritePresets: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "favoritePresets") ?? [])
    @State private var showPresetManager = false
    
    // For Save Image Alert
    @State private var showSaveAlert = false
    @State private var saveAlertMessage = ""
    
    var body: some View {
        ZStack {
            // Full-screen background gradient
            BackgroundGradientView()
            
            // Main content scroll view
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // App header with logo and title
                    AppHeaderView()
                    
                    // Image Preview Area
                    if let inputImage = inputImage {
                        ImagePreviewView(
                            inputImage: inputImage,
                            filteredImage: filteredImage,
                            showOriginal: $showOriginal,
                            splitScreenMode: $splitScreenMode
                        )
                        .frame(height: 400)
                        .transition(.scale)
                        
                        // Split screen toggle
                        Toggle(isOn: $splitScreenMode) {
                            Text("Before/After Comparison")
                                .foregroundColor(.white)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                        .padding(.horizontal)
                    } else {
                        EmptyImagePlaceholder()
                            .frame(height: 400)
                    }
                    
                    // Preset Selection Section
                    if !presets.isEmpty {
                        PresetSelectionView(
                            presets: presets,
                            selectedPresetName: $selectedPresetName,
                            adjustedPreset: $adjustedPreset,
                            favoritePresets: $favoritePresets
                        )
                        .padding(.horizontal)
                    }
                    
                    // Adjustment Sliders Section
                    if adjustedPreset != nil {
                        AdjustmentSlidersView(adjustedPreset: $adjustedPreset, presets: presets)
                            .frame(height: 280)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 20) {
                        // Image selection button
                        ActionButton(
                            iconName: "photo",
                            title: "Select Image",
                            colors: [.blue, .purple]
                        ) {
                            showImagePicker = true
                        }
                        
                        // Save button appears only if there is a filtered image
                        if filteredImage != nil {
                            ActionButton(
                                iconName: "square.and.arrow.down",
                                title: "Save Image",
                                colors: [.green, .yellow]
                            ) {
                                saveImage()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Preset Management Button
                    Button(action: {
                        showPresetManager = true
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text("Manage Presets")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // History section
                    if !filterHistory.isEmpty {
                        HistoryView(
                            filterHistory: filterHistory,
                            onSelectHistoryItem: { historyItem in
                                selectedPresetName = historyItem.0
                                adjustedPreset = historyItem.1
                            }
                        )
                        .padding(.top)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage, processedImage: $inputImage)
        }
        .sheet(isPresented: $showPresetManager) {
            CustomPresetManager(
                presets: $presets,
                selectedPresetName: $selectedPresetName,
                adjustedPreset: $adjustedPreset
            )
        }
        // Apply preset when adjustedPreset or inputImage changes
        .onChange(of: adjustedPreset) { _ in
            if inputImage != nil, adjustedPreset != nil, let presetName = selectedPresetName {
                applyPreset()
                
                // Add to history if this is a new preset or adjustment
                if filterHistory.isEmpty || filterHistory.last?.0 != presetName || filterHistory.last?.1 != adjustedPreset {
                    // Limit history to last 10 items
                    if filterHistory.count >= 10 {
                        filterHistory.removeFirst()
                    }
                    filterHistory.append((presetName, adjustedPreset!))
                }
            }
        }
        .onChange(of: inputImage) { _ in
            if inputImage != nil, adjustedPreset != nil {
                applyPreset()
            }
        }
        // Save favorites when they change
        .onChange(of: favoritePresets) { newValue in
            UserDefaults.standard.set(Array(newValue), forKey: "favoritePresets")
        }
        // Alert for save completion
        .alert(isPresented: $showSaveAlert) {
            Alert(title: Text("Save Image"), message: Text(saveAlertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            loadPresets()
        }
    }
    
    // Apply the preset using the adjusted values
    func applyPreset() {
        guard let inputImage = inputImage, let preset = adjustedPreset else { return }
        isApplyingPreset = true
        
        // Use background thread for heavy processing
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
    
    // Load presets from JSON if available; otherwise, use hardcoded defaults
    func loadPresets() {
        // First load system presets
        if let loadedPresets = PresetLoader.loadAllPresets() {
            presets = loadedPresets
        } else {
            presets = [
                "Vintage Film": vintageFilmPreset,
                "Faded Retro": fadedRetroPreset,
                "Polaroid": polaroidPreset
            ]
        }
        
        // Then try to load any custom presets and merge them
        if let customPresets = PresetLoader.loadCustomPresets() {
            for (key, value) in customPresets {
                presets[key] = value
            }
        }
        
        // Set a default preset if none is selected
        if selectedPresetName == nil && !presets.isEmpty {
            selectedPresetName = presets.keys.sorted().first
            adjustedPreset = presets[selectedPresetName!]
        }
    }
    
    // Save the filtered image to the Photo Library
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

// App header with logo and app name
struct AppHeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "camera.filters")
                .font(.system(size: 30))
                .foregroundColor(.white)
            
            Text("Lume Filter App")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
        .padding(.top, 40)
    }
}

// Background gradient for the app
struct BackgroundGradientView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color("BackgroundStart"),
                Color("BackgroundEnd")
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
