import SwiftUI

struct EffortRatingView: View {
    // Configurable properties
    let title: String
    let onEffortSelected: (Intensity, Int) -> Void
    
    // State management
    @State private var selectedLevel: Int = 0
    @State private var selectedIntensity: Intensity = .easy
    @Environment(\.presentationMode) var presentationMode
    
    enum Intensity: String, CaseIterable {
        case easy = "Easy"
        case moderate = "Moderate"
        case hard = "Hard"
        case allOut = "All Out"
        
        var color: Color {
            switch self {
            case .easy: return .green
            case .moderate: return .blue
            case .hard: return .purple
            case .allOut: return .red
            }
        }
        
        var bars: Int {
            switch self {
            case .easy: return 3
            case .moderate: return 3
            case .hard: return 2
            case .allOut: return 2
            }
        }
    }
    
    init(
        title: String = "Rate Your Effort",
        onEffortSelected: @escaping (Intensity, Int) -> Void
    ) {
        self.title = title
        self.onEffortSelected = onEffortSelected
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                VStack {
                    Text(title)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    Spacer()
                    
                    HStack(alignment: .bottom, spacing: 3) {
                        let baseHeight: CGFloat = 30
                        let heightIncrement: CGFloat = 15
                        
                        // Easy bars
                        ForEach(0..<3) { index in
                            createBar(
                                intensity: .easy,
                                relativeIndex: index,
                                absoluteIndex: index,
                                baseHeight: baseHeight,
                                heightIncrement: heightIncrement
                            )
                        }
                        
                        // Moderate bars
                        ForEach(0..<3) { index in
                            createBar(
                                intensity: .moderate,
                                relativeIndex: index,
                                absoluteIndex: index + 3,
                                baseHeight: baseHeight,
                                heightIncrement: heightIncrement
                            )
                        }
                        
                        // Hard bars
                        ForEach(0..<2) { index in
                            createBar(
                                intensity: .hard,
                                relativeIndex: index,
                                absoluteIndex: index + 6,
                                baseHeight: baseHeight,
                                heightIncrement: heightIncrement
                            )
                        }
                        
                        // All out bars
                        ForEach(0..<2) { index in
                            createBar(
                                intensity: .allOut,
                                relativeIndex: index,
                                absoluteIndex: index + 8,
                                baseHeight: baseHeight,
                                heightIncrement: heightIncrement
                            )
                        }
                    }
                    .frame(height: 200)
                    .padding(.bottom, 40)
                    
                    SelectedLevelView(
                        intensity: selectedIntensity,
                        level: absoluteLevelFor(
                            intensity: selectedIntensity,
                            relativeIndex: selectedLevel
                        )
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 60)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        let absoluteLevel = absoluteLevelFor(
                            intensity: selectedIntensity,
                            relativeIndex: selectedLevel
                        )
                        onEffortSelected(selectedIntensity, absoluteLevel)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .tint(.white)
        }
    }
    
    private func createBar(
        intensity: Intensity,
        relativeIndex: Int,
        absoluteIndex: Int,
        baseHeight: CGFloat,
        heightIncrement: CGFloat
    ) -> some View {
        IntensityBar(
            color: intensity.color,
            height: baseHeight + (CGFloat(absoluteIndex) * heightIncrement),
            isSelected: selectedIntensity == intensity && selectedLevel == relativeIndex,
            onTap: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedIntensity = intensity
                    selectedLevel = relativeIndex
                }
            }
        )
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                selectedIntensity.color.opacity(0.5),
                selectedIntensity.color.opacity(0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: selectedIntensity)
    }
    
    private func absoluteLevelFor(
        intensity: Intensity,
        relativeIndex: Int
    ) -> Int {
        switch intensity {
        case .easy: return relativeIndex
        case .moderate: return relativeIndex + 3
        case .hard: return relativeIndex + 6
        case .allOut: return relativeIndex + 8
        }
    }
}

// Existing IntensityBar and SelectedLevelView structs remain the same
struct IntensityBar: View {
    let color: Color
    let height: CGFloat
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: height/2)
            .fill(isSelected ? color : Color.black.opacity(0.3))
            .frame(width: 30, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: height/2)
                    .stroke(color, lineWidth: isSelected ? 2 : 0)
            )
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
            .onTapGesture(perform: onTap)
    }
}

struct SelectedLevelView: View {
    let intensity: EffortRatingView.Intensity
    let level: Int
    
    var body: some View {
        HStack {
            Text("\(level + 1)")
                .font(.title3)
                .bold()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(intensity.color))
            
            Text(intensity.rawValue)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "info.circle")
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.15))
        )
    }
}

// Example usage preview
#Preview {
    EffortRatingView(
        title: "How Hard Did You Try?",
        onEffortSelected: { intensity, level in
            print("Selected \(intensity.rawValue) at level \(level)")
        }
    )
}
