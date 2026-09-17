//
//  AppShellView.swift
//  HookIt
//

import SwiftUI

enum AppSection {
    case home
    case species
    case catches
    case regulations
}

struct AppShellView: View {
    @State private var selectedSection: AppSection = .home

    var body: some View {
        Group {
            switch selectedSection {
            case .home:
                NavigationStack {
                    HomeView()
                }

            case .species:
                NavigationStack {
                    SpeciesGuideView()
                }

            case .catches:
                NavigationStack {
                    MyCatchesView()
                }

            case .regulations:
                NavigationStack {
                    RegulationsView()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            AppNavigationBar(
                selectedSection: $selectedSection
            )
        }
    }
}

private struct AppNavigationBar: View {
    @Binding var selectedSection: AppSection

    var body: some View {
        HStack {
            if selectedSection != .home {
                navigationButton(
                    title: "Home",
                    systemImage: "house.fill",
                    section: .home
                )
            }

            if selectedSection != .species {
                navigationButton(
                    title: "Species",
                    systemImage: "fish.fill",
                    section: .species
                )
            }

            if selectedSection != .catches {
                navigationButton(
                    title: "Catches",
                    systemImage: "figure.fishing",
                    section: .catches
                )
            }

            if selectedSection != .regulations {
                navigationButton(
                    title: "Regulations",
                    systemImage: "ruler.fill",
                    section: .regulations
                )
            }
        }
        // Floating Island Modifiers
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private func navigationButton(
        title: String,
        systemImage: String,
        section: AppSection
    ) -> some View {
        Button {
            selectedSection = section
        } label: {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(.primary)

                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AppShellView()
        .environmentObject(CatchManager())
}
