//
//  SpeciesGuideView.swift
//  HookIt
//
//  Created by Dionny Dinza on 6/26/26.
//

import SwiftUI

struct SpeciesGuideView: View {
    
    @State private var searchText = ""
    
    let fishList = FishData.allFish
    
    var filteredFish: [FishSpecies] {
        if searchText.isEmpty {
            return fishList
        } else {
            return fishList.filter { fish in
                fish.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List {
            Section("Species") {
                ForEach(filteredFish) { fish in
                    NavigationLink(
                        destination: FishDetailView(fish: fish)
                    ) {
                        HStack(spacing: 12) {
                            Image(fish.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 70)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 12,
                                        style: .continuous
                                    )
                                )
                                .clipped()
                            
                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {
                                Text(fish.name)
                                    .font(.headline)
                                
                                Text(fish.habitat)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
        .navigationTitle("Species Guide")
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(
                displayMode: .always
            ),
            prompt: "Search fish species"
        )
        // ⬇️ Prevents the bottom fish from hiding behind the nav bar ⬇️
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 90)
        }
    }
}

#Preview {
    NavigationStack {
        SpeciesGuideView()
    }
}
