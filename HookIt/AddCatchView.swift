//
//  AddCatchView.swift
//  HookIt
//
//  Created by Dionny Dinza on 6/29/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct AddCatchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var catchManager: CatchManager
    
    let initialImageData: Data?
    let initialSpeciesName: String?
    let onCatchSaved: (() -> Void)?
    
    @State private var speciesName = ""
    @State private var length = ""
    @State private var lengthUnit = "in"
    @State private var weight = ""
    @State private var weightUnit = "lb"
    @State private var location = ""
    @State private var notes = ""
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isLoadingPhoto = false
    
    init(
        initialImageData: Data? = nil,
        initialSpeciesName: String? = nil,
        onCatchSaved: (() -> Void)? = nil
    ) {
        self.initialImageData = initialImageData
        self.initialSpeciesName = initialSpeciesName
        self.onCatchSaved = onCatchSaved

        _selectedImageData = State(
            initialValue: initialImageData
        )

        _speciesName = State(
            initialValue: initialSpeciesName ?? ""
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let imageData = selectedImageData,
                       let uiImage = UIImage(data: imageData) {
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        Button(role: .destructive) {
                            selectedPhotoItem = nil
                            selectedImageData = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    } else {
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Label(
                                "Add Catch Photo",
                                systemImage: "photo.on.rectangle"
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    if isLoadingPhoto {
                        HStack {
                            ProgressView()
                            
                            Text("Loading photo…")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Catch Photo")
                }
                
                Section("Catch Information") {
                    TextField("Species", text: $speciesName)
                    
                    HStack {
                        TextField("Length", text: $length)
                            .keyboardType(.decimalPad)
                        
                        Picker("Length Unit", selection: $lengthUnit) {
                            Text("in").tag("in")
                            Text("cm").tag("cm")
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        
                        Picker("Weight Unit", selection: $weightUnit) {
                            Text("lb").tag("lb")
                            Text("kg").tag("kg")
                        }
                        .pickerStyle(.menu)
                    }
                    
                    TextField("Location", text: $location)
                }
                
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Catch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCatch()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task(id: selectedPhotoItem) {
                await loadSelectedPhoto()
            }
        }
    }
    
    private func saveCatch() {
        let trimmedLength = length.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        let trimmedWeight = weight.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        let formattedLength = trimmedLength.isEmpty
            ? "Not provided"
            : "\(trimmedLength) \(lengthUnit)"
        
        let formattedWeight = trimmedWeight.isEmpty
            ? "Not provided"
            : "\(trimmedWeight) \(weightUnit)"
        
        let newCatch = CatchRecord(
            speciesName: speciesName.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            length: formattedLength,
            weight: formattedWeight,
            location: location.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            date: Date(),
            notes: notes.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            imageData: selectedImageData
        )
        
        catchManager.addCatch(newCatch)
        onCatchSaved?()
        dismiss()
    }
    
    private func loadSelectedPhoto() async {
        guard let selectedPhotoItem else {
            return
        }
        
        isLoadingPhoto = true
        
        defer {
            isLoadingPhoto = false
        }
        
        do {
            guard let originalData =
                    try await selectedPhotoItem.loadTransferable(
                        type: Data.self
                    ),
                  let originalImage = UIImage(data: originalData) else {
                return
            }
            
            let resizedImage =
                originalImage.preparingThumbnail(
                    of: CGSize(width: 1200, height: 1200)
                ) ?? originalImage
            
            selectedImageData = resizedImage.jpegData(
                compressionQuality: 0.75
            )
        } catch {
            print(
                "Unable to load selected photo: \(error.localizedDescription)"
            )
            
            selectedImageData = nil
        }
    }
}

#Preview {
    AddCatchView()
        .environmentObject(CatchManager())
}
