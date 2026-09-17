import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        List {
            if favoritesManager.favoriteFish.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 45))
                        .foregroundStyle(.yellow)
                    
                    Text("No Favorites Yet")
                        .font(.headline)
                    
                    Text("Tap the star on a fish detail page in Species Guide to save it here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(favoritesManager.favoriteFish) { fish in
                    NavigationLink(destination: FishDetailView(fish: fish)) {
                        HStack(spacing: 12) {
                            Image(fish.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)

                                    Text(fish.name)
                                        .font(.headline)
                                }
                                
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
        .navigationTitle("Favorites")
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
            .environmentObject(FavoritesManager())
    }
}
