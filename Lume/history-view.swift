import SwiftUI

// MARK: - History View

/// Displays the history of preset adjustments applied to an image
struct HistoryView: View {
    let filterHistory: [(String, LightroomPreset)]
    let onSelectHistoryItem: ((String, LightroomPreset)) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("History")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<filterHistory.count, id: \.self) { index in
                        let historyItem = filterHistory[filterHistory.count - 1 - index]
                        Button(action: {
                            onSelectHistoryItem(historyItem)
                        }) {
                            VStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hue: Double(historyItem.0.hashValue % 100) / 100, 
                                                      saturation: 0.6, 
                                                      brightness: 0.8),
                                                Color(hue: Double((historyItem.0.hashValue + 30) % 100) / 100, 
                                                      saturation: 0.7, 
                                                      brightness: 0.7)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("\(index + 1)")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                
                                Text(historyItem.0)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            .frame(width: 60)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

// MARK: - Preview

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock data for preview
        let mockHistory = [
            ("Vintage", LightroomPreset(
                exposure: 0.2,
                contrast: -0.1,
                saturation: -0.3,
                highlights: -0.2,
                shadows: 0.2,
                whiteBalance: WhiteBalance(temp: 6500, tint: 10),
                toneCurve: []
            )),
            ("Black & White", LightroomPreset(
                exposure: 0.1,
                contrast: 0.2,
                saturation: -1.0,
                highlights: -0.3,
                shadows: 0.3,
                whiteBalance: WhiteBalance(temp: 6500, tint: 0),
                toneCurve: []
            )),
            ("High Contrast", LightroomPreset(
                exposure: 0.0,
                contrast: 0.5,
                saturation: 0.1,
                highlights: -0.2,
                shadows: -0.2,
                whiteBalance: WhiteBalance(temp: 6500, tint: 0),
                toneCurve: []
            ))
        ]
        
        return ZStack {
            Color.gray.opacity(0.3).edgesIgnoringSafeArea(.all)
            
            HistoryView(
                filterHistory: mockHistory,
                onSelectHistoryItem: { _ in }
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
