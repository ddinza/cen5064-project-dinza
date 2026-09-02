//
//  FavoritesManager.swift
//  HookIt
//
//  Created by Dionny Dinza on 6/29/26.
//

import Foundation

import Combine

class FavoritesManager: ObservableObject {
    @Published var favoriteFish: [FishSpecies] = [] {
        didSet {
            saveFavorites()
        }
    }
    
    private let favoritesKey = "favoriteFish"
    
    init() {
        loadFavorites()
    }
    
    func isFavorite(_ fish: FishSpecies) -> Bool {
        favoriteFish.contains { $0.name == fish.name }
    }
    
    func toggleFavorite(_ fish: FishSpecies) {
        if isFavorite(fish) {
            favoriteFish.removeAll { $0.name == fish.name }
        } else {
            favoriteFish.append(fish)
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteFish) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([FishSpecies].self, from: data) {
            favoriteFish = decoded
        }
    }
}
