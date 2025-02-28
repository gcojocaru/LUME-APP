import SwiftUI

// MARK: - Action Button Component

/// A reusable gradient button with icon and text
struct ActionButton: View {
    var iconName: String
    var title: String
    var colors: [Color]
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: colors[0].opacity(0.5), radius: 5, x: 0, y: 3)
        }
    }
}

// MARK: - Preview

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ActionButton(
                iconName: "photo",
                title: "Select Image",
                colors: [.blue, .purple]
            ) {
                print("Select Image tapped")
            }
            
            ActionButton(
                iconName: "square.and.arrow.down",
                title: "Save Image",
                colors: [.green, .yellow]
            ) {
                print("Save Image tapped")
            }
            
            ActionButton(
                iconName: "gear",
                title: "Settings",
                colors: [.gray, .black]
            ) {
                print("Settings tapped")
            }
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
}
