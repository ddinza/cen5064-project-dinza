//
//  CatchRecord.swift
//  HookIt
//
//  Created by Dionny Dinza on 6/29/26.
//

import Foundation

class CatchRecord: Identifiable, Codable {
    var id = UUID()
    var speciesName: String
    var length: String
    var weight: String
    var location: String
    var date: Date
    var notes: String
    var imageData: Data?
    
    init(
        speciesName: String,
        length: String,
        weight: String,
        location: String,
        date: Date,
        notes: String,
        imageData: Data? = nil
    ) {
        self.speciesName = speciesName
        self.length = length
        self.weight = weight
        self.location = location
        self.date = date
        self.notes = notes
        self.imageData = imageData
    }
}
