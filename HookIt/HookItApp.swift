//
//  HookItApp.swift
//  HookIt
//
//  Created by Dionny Dinza on 6/24/26.
//

import SwiftUI

@main
struct HookItApp: App {
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var catchManager = CatchManager()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(favoritesManager)
                .environmentObject(catchManager)
        }
    }
}
