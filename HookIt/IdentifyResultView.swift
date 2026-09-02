//
//  IdentifyResultView.swift
//  HookIt
//

import SwiftUI
import UIKit

struct IdentifyResultView: View {
    let imageData: Data
    let result: FishIdentificationResult
    let matchedFish: FishSpecies?
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var catchManager: CatchManager
    @State private var showingAddCatch = false
    @State private var navigateToMyCatches = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                photoPreview
                
                resultHeader
                
                if let matchedFish {
                    matchedSpeciesCard(matchedFish)
                } else {
                    speciesUnavailableCard
                }
                
                Button {
                        showingAddCatch = true
                    } label: {
                        Label(
                            "Save to My Catches",
                            systemImage: "square.and.arrow.down"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                
                if !result.alternativeMatches.isEmpty {
                    alternativesSection
                }
                
                accuracyNotice
                
                Button {
                    dismiss()
                } label: {
                    Text("Identify Another Fish")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle("Identification Result")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddCatch) {
            AddCatchView(
                initialImageData: imageData,
                initialSpeciesName: result.speciesName,
                onCatchSaved: {
                    showingAddCatch = false

                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 0.2
                    ) {
                        navigateToMyCatches = true
                    }
                }
            )
            .environmentObject(catchManager)
        }
        .navigationDestination(
            isPresented: $navigateToMyCatches
        ) {
            MyCatchesView()
                .environmentObject(catchManager)
        }
    }
    
    private var photoPreview: some View {
        Group {
            if let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .frame(maxWidth: .infinity)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        )
                    )
                    .shadow(
                            color: .black.opacity(0.12),
                            radius: 8,
                            y: 4
                        )
            }
        }
    }
    
    private var resultHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 42))
                .foregroundStyle(.green)
            
            Text("Likely Match")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(result.speciesName)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(confidenceText(result.confidence))
                .font(.headline)
                .foregroundStyle(confidenceColor(result.confidence))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }
    
    private func matchedSpeciesCard(
        _ fish: FishSpecies
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available in HookIt")
                .font(.headline)
            
            Text(
                "Open the Species Guide to view habitat, bait, setup, identification tips, and fishing information."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            NavigationLink {
                FishDetailView(fish: fish)
            } label: {
                Label(
                    "Open \(fish.name)",
                    systemImage: "book.pages"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }
    
    private var speciesUnavailableCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(
                "Not Yet in the Species Guide",
                systemImage: "info.circle"
            )
            .font(.headline)
            
            Text(
                "\(result.speciesName) was identified, but its full guide is not currently available in HookIt."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }
    
    private var alternativesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Other Possible Matches")
                .font(.headline)
            
            ForEach(result.alternativeMatches) { match in
                HStack {
                    Text(match.speciesName)
                    
                    Spacer()
                    
                    Text(confidenceText(match.confidence))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                
                if match.id != result.alternativeMatches.last?.id {
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }
    
    private var accuracyNotice: some View {
        Label {
            Text(
                "AI identification may be incorrect. Confirm the species before handling, harvesting, or relying on fishing regulations."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
        }
        .padding()
        .background(Color.orange.opacity(0.08))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }
    
    private func confidenceText(
        _ confidence: Double
    ) -> String {
        "\(Int((confidence * 100).rounded()))% confidence"
    }
    
    private func confidenceColor(
        _ confidence: Double
    ) -> Color {
        switch confidence {
        case 0.85...:
            return .green
        case 0.60..<0.85:
            return .orange
        default:
            return .red
        }
    }
}

#Preview {
    NavigationStack {
        IdentifyResultView(
            imageData: UIImage(
                systemName: "fish.fill"
            )?.pngData() ?? Data(),
            result: FishIdentificationResult(
                speciesName: "Great Barracuda",
                confidence: 0.96,
                alternativeMatches: [
                    FishIdentificationMatch(
                        speciesName: "Wahoo",
                        confidence: 0.03
                    ),
                    FishIdentificationMatch(
                        speciesName: "King Mackerel",
                        confidence: 0.01
                    )
                ]
            ),
            matchedFish: nil
        )
    }
}
