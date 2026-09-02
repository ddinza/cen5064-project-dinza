//
//  EditCatchView.swift
//  HookIt
//

import SwiftUI
import PhotosUI
import UIKit

struct EditCatchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var catchManager: CatchManager
    
    let catchRecord: CatchRecord
    
    @State private var speciesName: String
    @State private var length: String
    @State private var lengthUnit: String
    @State private var weight: String
    @State private var weightUnit: String
    @State private var location: String
    @State private var notes: String
    @State private var date: Date
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isLoadingPhoto = false
    
    init(catchRecord: CatchRecord) {
        self.catchRecord = catchRecord
        
        let parsedLength = Self.parseMeasurement(
            catchRecord.length,
            defaultUnit: "in"
        )
        
        let parsedWeight = Self.parseMeasurement(
            catchRecord.weight,
            defaultUnit: "lb"
        )
        
        _speciesName = State(initialValue: catchRecord.speciesName)
        _length = State(initialValue: parsedLength.value)
        _lengthUnit = State(initialValue: parsedLength.unit)
        _weight = State(initialValue: parsedWeight.value)
        _weightUnit = State(initialValue: parsedWeight.unit)
        _location = State(initialValue: catchRecord.location)
        _notes = State(initialValue: catchRecord.notes)
        _date = State(initialValue: catchRecord.date)
        _selectedImageData = State(initialValue: catchRecord.imageData)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Catch Photo") {
                    if let imageData = selectedImageData,
                       let uiImage = UIImage(data: imageData) {
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Label(
                                "Change Photo",
                                systemImage: "photo.on.rectangle"
                            )
                        }
                        
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
                        }
                    }
                    
                    if isLoadingPhoto {
                        HStack {
                            ProgressView()
                            Text("Loading photo…")
                                .foregroundStyle(.secondary)
                        }
                    }
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
                    
                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: .date
                    )
                }
                
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Catch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
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
    
    private func saveChanges() {
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
        
        let updatedCatch = CatchRecord(
            speciesName: speciesName.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            length: formattedLength,
            weight: formattedWeight,
            location: location.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            date: date,
            notes: notes.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            imageData: selectedImageData
        )
        
        updatedCatch.id = catchRecord.id
        
        catchManager.updateCatch(updatedCatch)
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
        }
    }
    
    private static func parseMeasurement(
        _ text: String,
        defaultUnit: String
    ) -> (value: String, unit: String) {
        let trimmed = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard trimmed.lowercased() != "not provided" else {
            return ("", defaultUnit)
        }
        
        let parts = trimmed.split(separator: " ")
        
        guard let firstPart = parts.first else {
            return ("", defaultUnit)
        }
        
        let value = String(firstPart)
        let unit = parts.count > 1
            ? String(parts[1])
            : defaultUnit
        
        return (value, unit)
    }
}

#Preview {
    EditCatchView(
        catchRecord: CatchRecord(
            speciesName: "Snook",
            length: "31 in",
            weight: "9 lb",
            location: "Naples Pier",
            date: Date(),
            notes: "Caught during the incoming tide."
        )
    )
    .environmentObject(CatchManager())
}
