//
//  FishDetailView.swift
//  HookIt
//
//  Created by Dionny Dinza on 6/26/26.
//

import SwiftUI

struct FishDetailView: View {
    let fish: FishSpecies
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Image(fish.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .clipped()
                
                Text(fish.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                InfoSection(
                    title: "How to Identify",
                    text: fish.identificationTips,
                    icon: "eye"
                )
                
                InfoSection(
                    title: "Average Size",
                    text: fish.averageSize,
                    icon: "ruler"
                )
                
                if !fish.similarSpecies.isEmpty {
                    NavigationLink {
                        SimilarSpeciesView(fish: fish)
                    } label: {
                        SimilarSpeciesLinkButton()
                    }
                    .buttonStyle(.plain)
                }
                
                InfoSection(
                    title: "Best Bait",
                    text: fish.bestBait,
                    icon: "fish"
                )
                
                InfoSection(
                    title: "Best Time",
                    text: fish.bestTime,
                    icon: "clock"
                )
                
                InfoSection(
                    title: "Where to Find It",
                    text: fish.habitat,
                    icon: "map"
                )
                
                InfoSection(
                    title: "Best Setup",
                    text: fish.bestSetup,
                    icon: "gearshape"
                )
                
                InfoSection(
                    title: "How to Catch It",
                    text: fish.howToCatch,
                    icon: "figure.fishing"
                )
                
                InfoSection(
                    title: "Eating Quality",
                    text: fish.eatingQuality,
                    icon: "fork.knife"
                )
                
                InfoSection(
                    title: "Behavior",
                    text: fish.behavior,
                    icon: "waveform.path.ecg"
                )
                
                if let regulation = RegulationData.findRegulation(named: fish.name) {
                    NavigationLink {
                        RegulationDetailView(
                            fishName: regulation.fishName,
                            imageName: regulation.imageName,
                            region: regulation.region,
                            legalSize: regulation.legalSize,
                            bagLimit: regulation.bagLimit,
                            season: regulation.season,
                            notes: regulation.notes
                        )
                    } label: {
                        RegulationLinkButton()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle(fish.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                favoritesManager.toggleFavorite(fish)
            } label: {
                Image(
                    systemName: favoritesManager.isFavorite(fish)
                    ? "star.fill"
                    : "star"
                )
                .foregroundStyle(.yellow)
            }
        }
    }
}

struct InfoSection: View {
    let title: String
    let text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct SimilarSpeciesLinkButton: View {
    var body: some View {
        HStack {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Similar Species")
                    .font(.headline)
                
                Text("View fish with similar features.")
                    .font(.caption)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .foregroundStyle(.white)
        .padding()
        .background(Color.teal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct RegulationLinkButton: View {
    var body: some View {
        HStack {
            Image(systemName: "ruler")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("View Fishing Regulations")
                    .font(.headline)
                
                Text("Check legal size, bag limit, and season.")
                    .font(.caption)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .foregroundStyle(.white)
        .padding()
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        FishDetailView(
            fish: FishSpecies(
                imageName: "snook",
                name: "Snook",
                habitat: "Found near mangroves, bridges, docks, and inlets. They also love the mix of fresh and saltwater.",
                bestBait: "Live pilchards, shrimp, pinfish, and artificial swimbaits.",
                bestTime: "Early morning, late afternoon, and moving tides.",
                howToCatch: "Cast near structure and retrieve slowly if using artificial bait. Snook often ambush bait near cover.",
                bestSetup: "Medium-heavy spinning rod with a 3000-4000 size reel, 20-30 lb braid, and 30-40 lb fluorocarbon leader.",
                eatingQuality: "Excellent table fish with mild, flaky white meat.",
                behavior: "Snook are ambush predators that hide near structure and strike quickly.",
                identificationTips: "Easily recognized by its long silver body, dark black stripe along the side, and slightly protruding lower jaw. The fins often have a yellow tint.",
                averageSize: "20–40 inches (common), occasionally over 48 inches.",
                similarSpecies: ["Tarpon", "Ladyfish", "Redfish"]
            )
        )
        .environmentObject(FavoritesManager())
    }
}
