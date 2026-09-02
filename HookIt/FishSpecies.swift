//
//  FishSpecies.swift
//  HookIt
//
//  Created by Dionny Dinza on 6/26/26.
//

import Foundation

class FishSpecies: Identifiable, Codable {
    var id = UUID()
    var imageName: String
    var name: String
    var habitat: String
    var bestBait: String
    var bestTime: String
    var howToCatch: String
    var bestSetup: String
    var eatingQuality: String
    var behavior: String
    var identificationTips: String
    var averageSize: String
    var similarSpecies: [String]
    
    init(
        imageName: String,
        name: String,
        habitat: String,
        bestBait: String,
        bestTime: String,
        howToCatch: String,
        bestSetup: String,
        eatingQuality: String,
        behavior: String,
        identificationTips: String,
        averageSize: String,
        similarSpecies: [String]
    ) {
        self.imageName = imageName
        self.name = name
        self.habitat = habitat
        self.bestBait = bestBait
        self.bestTime = bestTime
        self.howToCatch = howToCatch
        self.bestSetup = bestSetup
        self.eatingQuality = eatingQuality
        self.behavior = behavior
        self.identificationTips = identificationTips
        self.averageSize = averageSize
        self.similarSpecies = similarSpecies
    }
}
