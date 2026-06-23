import SwiftUI

struct MainJ835KDI: View {
    @StateObject private var rrController = RRHomeController()
    @StateObject private var rrStats = RRStatsModel()
    @State private var rrWaveOffset: CGFloat = 0
    @State private var rrPulseStats: Bool = false
    @StateObject private var rrHintsManager = RRHintsManager()

    private let rrGameCards: [RRGameCard] = [
        RRGameCard(
            rrTitle: "Claim Fruits",
            rrSubtitle: "Catch & collect",
            rrIcon: "basket-preview",
            rrDestination: .claimFruits,
            rrGradientColors: [Color(red: 0.30, green: 0.80, blue: 0.77), Color(red: 0.20, green: 0.60, blue: 0.65)]
        ),
        RRGameCard(
            rrTitle: "Beach Runner",
            rrSubtitle: "Run & dodge",
            rrIcon: "runner_icon",
            rrDestination: .beachRunner,
            rrGradientColors: [RRColor.boltGold, Color(red: 0.90, green: 0.65, blue: 0.15)]
        ),
        RRGameCard(
            rrTitle: "Roll Dice",
            rrSubtitle: "Test your luck",
            rrIcon: "dice_game_tab_image",
            rrDestination: .rollDice,
            rrGradientColors: [Color(red: 1.0, green: 0.85, blue: 0.40), Color(red: 0.95, green: 0.70, blue: 0.25)]
        ),
        RRGameCard(
            rrTitle: "Draw the Way",
            rrSubtitle: "Trace the path",
            rrIcon: "sand_game_image",
            rrDestination: .drawTheWay,
            rrGradientColors: [Color(red: 0.96, green: 0.90, blue: 0.78), Color(red: 0.82, green: 0.72, blue: 0.55)]
        ),
    ]

    var body: some View {
        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            rrWaveDecoration

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    rrHeaderSection
                    rrStatsBoard
                    rrGameGridSection
                    
                    kDSboardStory
                    
                    rrBottomActions
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
            
            if rrHintsManager.rrShowHintOverlay,
               let rrHintText = rrHintsManager.rrActiveHintText {
                RRHintOverlayView(rrText: rrHintText) {
                    rrHintsManager.rrHideHint()
                }
            }
        }
        .onAppear {
            rrController.rrAnimateIn()
            rrStartWaves()
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                rrPulseStats = true
            }
            
            rrHintsManager.rrShowHintIfNeeded(
                rrID: "RRExampleScreenFirstHint",
                rrText: "This screen reacts to your settings. If hints are enabled, you will see helper tips like this."
            )
        }
        .navigationBarHidden(true)
        .fullScreenCover(item: $rrController.rrActiveScreen) { destination in
            rrDestinationView(for: destination)
        }
    }

    private var rrWaveDecoration: some View {
        VStack {
            Spacer()
            RRWaveShape(rrOffset: rrWaveOffset, rrAmplitude: 12, rrFrequency: 1.6)
                .fill(RRColor.boltGold.opacity(0.08))
                .frame(height: 80)
            RRWaveShape(rrOffset: rrWaveOffset + 30, rrAmplitude: 8, rrFrequency: 2.0)
                .fill(RRColor.foamWhite.opacity(0.03))
                .frame(height: 50)
                .offset(y: -30)
        }
        .ignoresSafeArea()
    }

    private var rrHeaderSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 6) {
                    GradientText(text: "Hi!")
                    GradientText(text: "Runner")
                }

                Text("Mini Games Adventure")
                    .font(.custom(RRFont.regular, size: 12))
                    .foregroundColor(RRColor.foamMist.opacity(0.45))
                    .tracking(2)
            }

            Spacer()

            Button {
                RRHapticsManager.rrLight()
                RRSoundManager.rrTap()
                rrController.rrNavigateTo(.settings)
            } label: {
                Image("game-setting-3d")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.top, UIScreen.main.bounds.height * 0.08)
        .padding(.bottom, 20)
        .offset(y: rrController.rrShowContent ? 0 : -20)
        .opacity(rrController.rrShowContent ? 1 : 0)
    }
    
    private var kDSboardStory: some View {
        Button {
            RRHapticsManager.rrLight()
            RRSoundManager.rrTap()
            rrController.rrNavigateTo(.storyActivity)
        } label: {
            VStack {
                ZStack(alignment: .topTrailing) {
                    Image("closed-golden-padlock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    
                    Image("fireStats")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 63, height: 63)
                        .offset(x: 30)
                }
                
                Text("Story and check my progress!")
                    .foregroundStyle(RRColor.foamWhite)
                    .font(.custom(RRFont.black, size: 22))
                
                Text("if you want to get awards or special items, you have to complete the story!")
                    .foregroundStyle(RRColor.sandWarm)
                    .font(.custom(RRFont.regular, size: 15))
                    .padding(.top, 30)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(RRColor.riverDeep)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    RRColor.boltGold.opacity(0.6),
                                    RRColor.foamWhite.opacity(0.95),
                                    RRColor.boltGold.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: RRColor.riverDeep, radius: 16, x: 0, y: 8)
        )
        .padding(.bottom, 24)
        .scaleEffect(rrController.rrShowContent ? 1.0 : 0.9)
        .opacity(rrController.rrShowContent ? 1 : 0)
    }

    private var rrStatsBoard: some View {
        HStack(spacing: 12) {
            rrStatPill(
                icon: "fireStats",
                value: rrStats.rrFireCount,
                label: "Fire",
                accentColor: Color(red: 1.0, green: 0.45, blue: 0.2)
            )

            rrStatPill(
                icon: "pineappleStats",
                value: rrStats.rrPineappleCount,
                label: "Pineapple",
                accentColor: RRColor.boltGold
            )

            rrStatPill(
                icon: "3d-star-icon",
                value: rrStats.rrStarsEarned,
                label: "Stars",
                accentColor: RRColor.boltSunrise
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    RRColor.boltGold.opacity(0.2),
                                    RRColor.foamWhite.opacity(0.05),
                                    RRColor.boltGold.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: RRColor.riverDeep.opacity(0.4), radius: 16, x: 0, y: 8)
        )
        .padding(.bottom, 24)
        .scaleEffect(rrController.rrShowContent ? 1.0 : 0.9)
        .opacity(rrController.rrShowContent ? 1 : 0)
    }

    private func rrStatPill(icon: String, value: Int, label: String, accentColor: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .scaleEffect(rrPulseStats ? 1.08 : 1.0)

                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }

            Text("\(value)")
                .font(.custom(RRFont.black, size: 20))
                .foregroundColor(RRColor.foamWhite)
                .monospacedDigit()

            Text(label)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundColor(RRColor.foamMist.opacity(0.45))
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var rrGameGridSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                rrGameCardView(card: rrGameCards[0], delay: 0.15)
                rrGameCardView(card: rrGameCards[1], delay: 0.25)
            }

            HStack(spacing: 14) {
                rrGameCardView(card: rrGameCards[2], delay: 0.35)
                rrGameCardView(card: rrGameCards[3], delay: 0.45)
            }
        }
        .padding(.bottom, 20)
    }

    private func rrGameCardView(card: RRGameCard, delay: Double) -> some View {
        Button {
            RRHapticsManager.rrLight()
            RRSoundManager.rrTap()
            rrController.rrNavigateTo(card.rrDestination)
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: card.rrGradientColors.map { $0.opacity(0.15) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)

                    Image(card.rrIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                }

                Text(card.rrTitle)
                    .font(.custom(RRFont.semiBold, size: 14))
                    .foregroundColor(RRColor.foamWhite)

                Text(card.rrSubtitle)
                    .font(.custom(RRFont.regular, size: 11))
                    .foregroundColor(RRColor.foamMist.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        card.rrGradientColors[0].opacity(0.25),
                                        card.rrGradientColors[1].opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: card.rrGradientColors[0].opacity(0.52), radius: 12, x: 0, y: 6)
            )
        }
        .buttonStyle(RRGameCardButtonStyle())
        .offset(y: rrController.rrShowContent ? 0 : 30)
        .opacity(rrController.rrShowContent ? 1 : 0)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.75).delay(delay),
            value: rrController.rrShowContent
        )
    }

    private var rrBottomActions: some View {
        VStack(spacing: 12) {
            rrBottomActionRow(
                icon: "3d-star-icon",
                title: "Awards & Achievements",
                subtitle: "\(rrStats.rrGamesPlayed) games played",
                destination: .awards,
                delay: 0.5
            )

            rrBottomActionRow(
                icon: "runner_tab_image",
                title: "Activity Map",
                subtitle: "View your activities",
                destination: .activityMap,
                delay: 0.6
            )

            rrBottomActionRow(
                icon: "game-key",
                title: "Add Activity",
                subtitle: "Log a new session",
                destination: .addActivity,
                delay: 0.7
            )
        }
    }

    private func rrBottomActionRow(icon: String, title: String, subtitle: String, destination: RRScreenDestination, delay: Double) -> some View {
        Button {
            RRHapticsManager.rrLight()
            RRSoundManager.rrTap()
            rrController.rrNavigateTo(destination)
        } label: {
            HStack(spacing: 14) {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom(RRFont.semiBold, size: 15))
                        .foregroundColor(RRColor.foamWhite)

                    Text(subtitle)
                        .font(.custom(RRFont.regular, size: 12))
                        .foregroundColor(RRColor.foamMist.opacity(0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(RRColor.boltGold.opacity(0.6))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(RRColor.foamWhite.opacity(0.36), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(RRGameCardButtonStyle())
        .offset(y: rrController.rrShowContent ? 0 : 20)
        .opacity(rrController.rrShowContent ? 1 : 0)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.75).delay(delay),
            value: rrController.rrShowContent
        )
    }

    @ViewBuilder
    private func rrDestinationView(for destination: RRScreenDestination) -> some View {
        switch destination {
        case .claimFruits:
            RRClaimFruitsGameView(rrStats: rrStats)
        case .beachRunner:
            RRBeachRunnerGameView(rrStats: rrStats)
        case .rollDice:
            RRRollDiceGameView(rrStats: rrStats)
        case .drawTheWay:
            RRDrawTheWayGameView(rrStats: rrStats)
        case .awards:
            RRAwardsScreen(rrStats: rrStats)
        case .activityMap:
            RRActivityMapView()
        case .addActivity:
            RRCreateActivityScreen()
        case .storyActivity:
            RRStoryGameView(rrStats: rrStats)
        case .settings:
            RRSettingsScreen(rrStats: rrStats)
        }
    }

    private func rrStartWaves() {
        withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) {
            rrWaveOffset = 360
        }
    }
}

struct RRGameCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    MainJ835KDI()
        .preferredColorScheme(.dark)
}

struct RRHintOverlayView: View {
    let rrText: String
    let rrDismiss: () -> Void

    var body: some View {
        VStack {
            Spacer()

            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(RRColor.boltGold.opacity(0.16))
                        .frame(width: 42, height: 42)

                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(RRColor.boltGold)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Hint")
                        .font(.custom(RRFont.semiBold, size: 14))
                        .foregroundStyle(RRColor.foamWhite)

                    Text(rrText)
                        .font(.custom(RRFont.regular, size: 12))
                        .foregroundStyle(RRColor.foamMist.opacity(0.88))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Button {
                    RRHapticsManager.rrLight()
                    rrDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(RRColor.foamWhite.opacity(0.8))
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(RRColor.foamWhite.opacity(0.08))
                        )
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(RRColor.boltGold.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
