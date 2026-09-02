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
                    imageName: "hookitlogo",
                    section: .home
                )
            }

            if selectedSection != .species {
                navigationButton(
                    title: "Species",
                    imageName: "speciesguide",
                    section: .species
                )
            }

            if selectedSection != .catches {
                navigationButton(
                    title: "Catches",
                    imageName: "mycatches",
                    section: .catches
                )
            }

            if selectedSection != .regulations {
                navigationButton(
                    title: "Regulations",
                    imageName: "regulations",
                    section: .regulations
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func navigationButton(
        title: String,
        imageName: String,
        section: AppSection
    ) -> some View {
        Button {
            selectedSection = section
        } label: {
            VStack(spacing: 4) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: section == .home ? 56 : 76,
                        height: section == .home ? 56 : 52
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: section == .home ? 13 : 12,
                            style: .continuous
                        )
                    )
                    .clipped()

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
