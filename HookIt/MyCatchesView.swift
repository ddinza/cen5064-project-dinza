//
//  MyCatchesView.swift
//  HookIt
//
//  Created by Dionny Dinza on 6/26/26.
//

import SwiftUI
import UIKit

struct MyCatchesView: View {
    @EnvironmentObject var catchManager: CatchManager
    @State private var showingAddCatch = false
    
    var longestCatch: CatchRecord? {
        catchManager.catches.max {
            normalizedLengthInInches(from: $0.length)
                < normalizedLengthInInches(from: $1.length)
        }
    }

    var heaviestCatch: CatchRecord? {
        catchManager.catches.max {
            normalizedWeightInPounds(from: $0.weight)
                < normalizedWeightInPounds(from: $1.weight)
        }
    }
    
    var body: some View {
        List {
            if catchManager.catches.isEmpty {
                VStack(spacing: 12) {
                    Image("mycatchesempty")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .clipped()
                    
                    Text("No Catches Yet")
                        .font(.headline)
                    
                    Text("Tap + to log your first catch.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                Section("🏆 Personal Records") {
                    if let longestCatch {
                        Text(
                            "Longest Catch: \(longestCatch.speciesName) — \(longestCatch.length)"
                        )
                    }
                    
                    if let heaviestCatch {
                        Text(
                            "Heaviest Catch: \(heaviestCatch.speciesName) — \(heaviestCatch.weight)"
                        )
                    }
                    
                    Text("Total Catches: \(catchManager.catches.count)")
                }
                
                Section("Saved Catches") {
                    ForEach(catchManager.catches) { catchRecord in
                        NavigationLink {
                            CatchDetailView(catchRecord: catchRecord)
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                catchThumbnail(for: catchRecord)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(catchRecord.speciesName)
                                        .font(.headline)
                                    
                                    Text(
                                        "\(catchRecord.length) • \(catchRecord.weight) • \(catchRecord.location)"
                                    )
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    
                                    if !catchRecord.notes.isEmpty {
                                        Text(catchRecord.notes)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                    
                                    Text(catchRecord.date, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .onDelete(perform: catchManager.deleteCatch)
                }
            }
        }
        .navigationTitle("My Catches")
        .toolbar {
            Button {
                showingAddCatch = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddCatch) {
            AddCatchView()
                .environmentObject(catchManager)
        }
    }
    
    @ViewBuilder
    private func catchThumbnail(for catchRecord: CatchRecord) -> some View {
        if let imageData = catchRecord.imageData,
           let uiImage = UIImage(data: imageData) {
            
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 75)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .clipped()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.12))
                
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 100, height: 75)
        }
    }
    
    private func extractNumber(from text: String) -> Double {
        let filtered = text.filter {
            $0.isNumber || $0 == "."
        }

        return Double(filtered) ?? 0
    }

    private func normalizedLengthInInches(from text: String) -> Double {
        let value = extractNumber(from: text)
        let lowercasedText = text.lowercased()

        if lowercasedText.contains("cm") {
            return value / 2.54
        }

        return value
    }

    private func normalizedWeightInPounds(from text: String) -> Double {
        let value = extractNumber(from: text)
        let lowercasedText = text.lowercased()

        if lowercasedText.contains("kg") {
            return value * 2.20462
        }

        return value
    }
}

#Preview {
    NavigationStack {
        MyCatchesView()
            .environmentObject(CatchManager())
    }
}
