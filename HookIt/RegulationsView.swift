//
//  RegulationsView.swift
//  HookIt
//
//  Created by Dionny Dinza on 6/26/26.
//

import SwiftUI

struct RegulationsView: View {
    
    @State private var searchText = ""
    
    let regulations = RegulationData.allRegulations
    
    var filteredRegulations: [FishingRegulation] {
        if searchText.isEmpty {
            return regulations
        } else {
            return regulations.filter {
                $0.fishName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List(filteredRegulations) { fish in
            NavigationLink {
                RegulationDetailView(
                    fishName: fish.fishName,
                    imageName: fish.imageName,
                    region: fish.region,
                    legalSize: fish.legalSize,
                    bagLimit: fish.bagLimit,
                    season: fish.season,
                    notes: fish.notes
                )
            } label: {
                HStack(spacing: 12) {
                    Image(fish.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(fish.fishName)
                        .font(.headline)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Fishing Regulations")
        .searchable(text: $searchText, prompt: "Search fish species")
    }
}

#Preview {
    NavigationStack {
        RegulationsView()
    }
}
