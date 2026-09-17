import SwiftUI

struct SimilarSpeciesView: View {
    let fish: FishSpecies
    
    var availableSimilarFish: [FishSpecies] {
        fish.similarSpecies.compactMap { speciesName in
            FishData.findFish(named: speciesName)
        }
    }
    
    var body: some View {
        List {
            if availableSimilarFish.isEmpty {
                VStack(spacing: 12) {
                    Text("No Similar Species Available")
                        .font(.headline)

                    Text("More related species will be added soon.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(availableSimilarFish) { similarFish in
                    NavigationLink {
                        FishDetailView(fish: similarFish)
                    } label: {
                        HStack(spacing: 12) {
                            Image(similarFish.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 75)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Text(similarFish.name)
                                .font(.headline)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Similar Species")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SimilarSpeciesView(
            fish: FishData.allFish[0]
        )
        .environmentObject(FavoritesManager())
    }
}
