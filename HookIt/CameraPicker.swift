//
//  CameraPicker.swift
//  HookIt
//

import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {
    let onImageCaptured: (Data) -> Void
    let onCancel: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        
        return picker
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
        // No updates needed.
    }
    
    final class Coordinator:
        NSObject,
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate {
        
        private let parent: CameraPicker
        
        init(parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [
                UIImagePickerController.InfoKey: Any
            ]
        ) {
            guard let originalImage =
                    info[.originalImage] as? UIImage else {
                parent.onCancel()
                return
            }
            
            let resizedImage =
                originalImage.preparingThumbnail(
                    of: CGSize(width: 1200, height: 1200)
                ) ?? originalImage
            
            guard let imageData = resizedImage.jpegData(
                compressionQuality: 0.75
            ) else {
                parent.onCancel()
                return
            }
            
            DispatchQueue.main.async {
                self.parent.onImageCaptured(imageData)
            }
        }
        
        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            DispatchQueue.main.async {
                self.parent.onCancel()
            }
        }
    }
}
