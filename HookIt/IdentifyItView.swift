//
//  IdentifyItView.swift
//  HookIt
//

import SwiftUI
import UIKit
import PhotosUI

struct IdentifyItView: View {
    @State private var showingLiveScanAlert = false
    @State private var showingCamera = false
    @State private var capturedImageData: Data?
    @State private var showingCameraUnavailableAlert = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isLoadingPhoto = false
    @State private var identificationResult: FishIdentificationResult?
    @State private var matchedFish: FishSpecies?
    @State private var isAnalyzing = false
    @State private var loadingMessage = "Analyzing your fish..."
    @State private var showingIdentificationError = false
    @State private var identificationErrorMessage = ""
    @State private var showingUnableToIdentifyAlert = false
    
    var body: some View {
        ZStack {
            Image("homebackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.18)
            
            ScrollView {
                VStack(spacing: 20) {
                    Image("identifyitview")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 22,
                                style: .continuous
                            )
                        )
                        .clipped()
                    
                    Text("Identify Your Fish")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(
                        "Use a clear side-profile photo with good lighting for the most accurate result."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    
                    if let imageData = capturedImageData,
                       let capturedImage = UIImage(data: imageData) {
                        
                        VStack(spacing: 12) {
                            Image(uiImage: capturedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 280)
                                .frame(maxWidth: .infinity)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 18,
                                        style: .continuous
                                    )
                                )
                                .shadow(
                                        color: .black.opacity(0.12),
                                        radius: 8,
                                        y: 4
                                    )
                            
                            HStack {
                                Button {
                                    resetIdentification()
                                    openCamera()
                                } label: {
                                    Label(
                                        "Retake",
                                        systemImage: "camera.rotate"
                                    )
                                }
                                .disabled(isAnalyzing)
                                
                                Spacer()
                                
                                Button(role: .destructive) {
                                    resetIdentification()
                                } label: {
                                    Label(
                                        "Remove",
                                        systemImage: "trash"
                                    )
                                }
                                .disabled(isAnalyzing)
                            }
                            
                            Button {
                                Task {
                                    await runGeminiIdentification()
                                }
                            } label: {
                                if isAnalyzing {
                                    HStack(spacing: 10) {
                                        ProgressView()
                                            .tint(.white)
                                        
                                        Text(loadingMessage)
                                    }
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                } else {
                                    Label(
                                        "Identify Fish",
                                        systemImage: "sparkles"
                                    )
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isAnalyzing)
                        }
                    }
                    
                    if isLoadingPhoto {
                        HStack(spacing: 10) {
                            ProgressView()
                            
                            Text("Loading photo…")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    VStack(spacing: 14) {
                        Button {
                            openCamera()
                        } label: {
                            IdentifyOptionCard(
                                title: capturedImageData == nil
                                ? "Take a Photo"
                                : "Take Another Photo",
                                subtitle: "Photograph the fish now.",
                                systemImage: "camera.fill"
                            )
                        }
                        .disabled(isAnalyzing)
                        .buttonStyle(.plain)
                        
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            IdentifyOptionCard(
                                title: capturedImageData == nil
                                ? "Choose from Photos"
                                : "Choose Another Photo",
                                subtitle: "Select an existing fish photo.",
                                systemImage: "photo.on.rectangle"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            showingLiveScanAlert = true
                        } label: {
                            IdentifyOptionCard(
                                title: "Live Scan",
                                subtitle: "Coming soon.",
                                systemImage: "viewfinder",
                                isDisabled: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Identify It")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: selectedPhotoItem) {
            await loadSelectedPhoto()
        }
        .navigationDestination(
            item: $identificationResult
        ) { result in
            IdentifyResultView(
                imageData: capturedImageData ?? Data(),
                result: result,
                matchedFish: matchedFish
            )
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraPicker(
                onImageCaptured: { imageData in
                    capturedImageData = imageData
                    selectedPhotoItem = nil
                    identificationResult = nil
                    matchedFish = nil
                    showingCamera = false
                },
                onCancel: {
                    showingCamera = false
                }
            )
            .ignoresSafeArea()
        }
        .alert(
            "Live Scan Coming Soon",
            isPresented: $showingLiveScanAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(
                "Live fish scanning will be added in a future update."
            )
        }
        .alert(
            "Camera Unavailable",
            isPresented: $showingCameraUnavailableAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(
                "Identify It requires a device with an available camera."
            )
        }
        .alert(
            "Unable to Identify Fish",
            isPresented: $showingIdentificationError
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(
                identificationErrorMessage.isEmpty
                ? "We couldn't identify this fish. Try another clear side-profile photo."
                : identificationErrorMessage
            )
        }
        .alert(
            "Fish Not Identified",
            isPresented: $showingUnableToIdentifyAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(
                "We couldn't confidently identify this fish. Try another clear photo showing the full side of the fish."
            )
        }
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(
            .camera
        ) else {
            showingCameraUnavailableAlert = true
            return
        }
        
        showingCamera = true
    }
    
    private func resetIdentification() {
        capturedImageData = nil
        selectedPhotoItem = nil
        identificationResult = nil
        matchedFish = nil
    }
    
    @MainActor
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
            
            capturedImageData = resizedImage.jpegData(
                compressionQuality: 0.75
            )
            
            identificationResult = nil
            matchedFish = nil
        } catch {
            print(
                "Unable to load selected photo: \(error.localizedDescription)"
            )
            
            capturedImageData = nil
        }
    }
    
    @MainActor
    private func runGeminiIdentification() async {
        guard let capturedImageData,
              !isAnalyzing else {
            return
        }
        
        isAnalyzing = true
        loadingMessage = "Analyzing your fish..."
        
        defer {
            isAnalyzing = false
        }
        
        do {
            let speciesNames = FishData.allFish.map(\.name)
            
            let result = try await GeminiService().identifyFish(
                imageData: capturedImageData,
                availableSpecies: speciesNames,
                onRetry: {
                    await MainActor.run {
                        loadingMessage = "Taking another look..."
                    }
                }
            )
            if result.speciesName.caseInsensitiveCompare(
                "Unable to Identify"
            ) == .orderedSame {
                showingUnableToIdentifyAlert = true
                return
            }
            
            matchedFish = FishData.allFish.first { fish in
                fish.name.caseInsensitiveCompare(
                    result.speciesName
                ) == .orderedSame
            }
            
            identificationResult = result
            
        } catch {
            print("Gemini Error:")
            print(error.localizedDescription)

            if let urlError = error as? URLError {
                switch urlError.code {
                case .timedOut:
                    identificationErrorMessage =
                        "The identification took too long. Please try again."

                case .notConnectedToInternet:
                    identificationErrorMessage =
                        "No internet connection. Please reconnect and try again."

                case .networkConnectionLost:
                    identificationErrorMessage =
                        "The connection was interrupted. Please try again."

                default:
                    identificationErrorMessage =
                        "We couldn't connect to the identification service. Please try again."
                }
            } else {
                identificationErrorMessage =
                    "We couldn't identify this fish. Try another clear side-profile photo."
            }

            showingIdentificationError = true
        }
    }
}
    
    private struct IdentifyOptionCard: View {
        let title: String
        let subtitle: String
        let systemImage: String
        var isDisabled = false
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 28))
                    .foregroundStyle(
                        isDisabled
                        ? Color.secondary
                        : Color.blue
                    )
                    .frame(width: 45)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(
                            isDisabled
                            ? Color.secondary
                            : Color.primary
                        )
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )
            .opacity(isDisabled ? 0.65 : 1)
            .shadow(radius: 3)
        }
    }
    
    #Preview {
        NavigationStack {
            IdentifyItView()
        }
    }

