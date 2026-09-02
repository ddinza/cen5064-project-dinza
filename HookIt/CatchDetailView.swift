//
//  CatchDetailView.swift
//  HookIt
//
//  Created by Dionny Dinza on 7/28/26.
//

import SwiftUI
import UIKit

struct CatchDetailView: View {
    let catchRecord: CatchRecord
    
    @EnvironmentObject var catchManager: CatchManager
    @State private var showingEditCatch = false
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                if let imageData = catchRecord.imageData,
                   let uiImage = UIImage(data: imageData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Text(catchRecord.speciesName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                CatchInfoSection(
                    title: "Length",
                    text: catchRecord.length,
                    icon: "ruler"
                )
                
                CatchInfoSection(
                    title: "Weight",
                    text: catchRecord.weight,
                    icon: "scalemass"
                )
                
                CatchInfoSection(
                    title: "Location",
                    text: catchRecord.location,
                    icon: "mappin.and.ellipse"
                )
                
                CatchInfoSection(
                    title: "Date",
                    text: catchRecord.date.formatted(
                        date: .long,
                        time: .omitted
                    ),
                    icon: "calendar"
                )
                
                if !catchRecord.notes.isEmpty {
                    CatchInfoSection(
                        title: "Notes",
                        text: catchRecord.notes,
                        icon: "note.text"
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Catch Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") {
                showingEditCatch = true
            }
        }
        .sheet(isPresented: $showingEditCatch) {
            EditCatchView(catchRecord: catchRecord)
                .environmentObject(catchManager)
        }
    }
}

struct CatchInfoSection: View {
    let title: String
    let text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
            
            Text(text)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        CatchDetailView(
            catchRecord: CatchRecord(
                speciesName: "Snook",
                length: "31 inches",
                weight: "9 pounds",
                location: "Naples Pier",
                date: Date(),
                notes: "Caught during the incoming tide."
            )
        )
    }
}
