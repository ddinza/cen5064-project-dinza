//
//  CatchManager.swift
//  HookIt
//
//  Created by Dionny Dinza on 6/29/26.
//

import Foundation
import Combine
import SwiftUI

class CatchManager: ObservableObject {
    @Published var catches: [CatchRecord] = [] {
        didSet {
            saveCatches()
        }
    }
    
    private let catchesKey = "savedCatches"
    
    init() {
        loadCatches()
    }
    
    func addCatch(_ catchRecord: CatchRecord) {
        catches.append(catchRecord)
    }
    
    func updateCatch(_ updatedCatch: CatchRecord) {
        guard let index = catches.firstIndex(
            where: { $0.id == updatedCatch.id }
        ) else {
            return
        }
        
        catches[index] = updatedCatch
    }
    
    func deleteCatch(at offsets: IndexSet) {
        catches.remove(atOffsets: offsets)
    }
    
    private func saveCatches() {
        if let encoded = try? JSONEncoder().encode(catches) {
            UserDefaults.standard.set(encoded, forKey: catchesKey)
        }
    }
    
    private func loadCatches() {
        if let data = UserDefaults.standard.data(forKey: catchesKey),
           let decoded = try? JSONDecoder().decode(
                [CatchRecord].self,
                from: data
           ) {
            catches = decoded
        }
    }
}
