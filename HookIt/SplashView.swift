//
//  SplashView.swift
//  HookIt
//
//  Created by Dionny Dinza on 7/2/26.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            AppShellView()
        } else {
            ZStack {
                Image("homebackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.25)
                
                VStack(spacing: 20) {
                    Image("hookitlogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(radius: 10)
                    
                    Text("HookIt")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your Personal Fishing Guide")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
