import SwiftUI

struct RegulationDetailView: View {
    let fishName: String
    let imageName: String
    let region: String
    let legalSize: String
    let bagLimit: String
    let season: String
    let notes: String
    
    var body: some View {
        List {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .clipped()
                .listRowInsets(EdgeInsets())
            
            Section("Species") {
                Text(fishName)
            }
            
            Section("Region") {
                Text(region)
            }
            
            Section("Legal Size") {
                Text(legalSize)
            }
            
            Section("Bag Limit") {
                Text(bagLimit)
            }
            
            Section("Season") {
                Text(season)
            }
            
            Section("Important Information") {
                Text(notes)
                
                Text("⚠ Regulations can vary by location, species, season, and year. Always verify current Florida Fish and Wildlife Conservation Commission (FWC) regulations before harvesting fish.")
                    .foregroundStyle(.orange)
            }
            
            if let fish = FishData.findFish(named: fishName) {
                ZStack {
                    SpeciesGuideLinkButton()
                    
                    NavigationLink {
                        FishDetailView(fish: fish)
                    } label: {
                        EmptyView()
                    }
                    .opacity(0)
                }
                .listRowSeparator(.hidden)
            }
        }
        .navigationTitle("Regulations")
    }
}

struct SpeciesGuideLinkButton: View {
    var body: some View {
        HStack {
            Image(systemName: "book.fill")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("View Species Guide")
                    .font(.headline)
                
                Text("See bait, setup, behavior, and catching tips.")
                    .font(.caption)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .foregroundStyle(.white)
        .padding()
        .background(Color.green)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        RegulationDetailView(
            fishName: "Snook",
            imageName: "snook",
            region: "Florida",
            legalSize: "28-33 inches",
            bagLimit: "1 per person",
            season: "Seasonal closures apply",
            notes: "Snook permit required for harvest. Always verify current FWC regulations."
        )
        .environmentObject(FavoritesManager())
    }
}
