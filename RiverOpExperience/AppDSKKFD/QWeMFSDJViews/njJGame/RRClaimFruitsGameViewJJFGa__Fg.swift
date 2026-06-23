import SwiftUI

struct RRClaimFruitsGameView: View {
    @Environment(\.dismiss) private var rrDismiss
    @ObservedObject var rrStats: RRStatsModel
    
    @StateObject private var rrVm = RRClaimFruitsViewModel()
    @State private var rrDidSaveResult = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                rrBackgroundViewMain324()
                    .ignoresSafeArea()
                
                rrDecorativeGlow
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        rrTopBar(width: geometry.size.width)
                        rrHud
                        
                        Spacer(minLength: 0)
                        
                        rrGameArena(size: geometry.size)
                        
                        Spacer(minLength: 0)
                        
                        rrBasket(size: geometry.size)
                            .padding(.bottom, 24)
                    }
                }
                
                if rrVm.rrShowInstructions {
                    Rectangle()
                        .fill(RRColor.riverDeep)
                        .ignoresSafeArea()
                    
                    rrInstructionOverlay(screenWidth: geometry.size.width)
                }
                
                if rrVm.rrIsFinished {
                    Rectangle()
                        .fill(RRColor.riverDeep)
                        .ignoresSafeArea()
                    
                    rrResultOverlay(screenWidth: geometry.size.width, screenSize: geometry.size)
                }
            }
            .onDisappear {
                rrVm.rrStopGame()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var rrDecorativeGlow: some View {
        VStack {
            Circle()
                .fill(RRColor.boltGold.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 50)
                .offset(x: 110, y: -50)
            Spacer()
        }
        .ignoresSafeArea()
    }
    
    private func rrTopBar(width: CGFloat) -> some View {
        HStack {
            Button {
                rrVm.rrStopGame()
                rrDismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                    Image("back-3d")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                }
                .foregroundStyle(RRColor.foamWhite)
                .padding(10)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule().stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                        )
                )
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Claim Fruits")
                    .font(.custom(RRFont.black, size: 20))
                    .foregroundStyle(RRColor.foamWhite)
                
                Text("Catch & collect")
                    .font(.custom(RRFont.regular, size: 11))
                    .foregroundStyle(RRColor.foamMist.opacity(0.5))
                    .tracking(1)
            }
            
            Spacer()
            
            Button {
                rrVm.rrShowInstructions = true
            } label: {
                Image("game-key")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26, height: 26)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle().stroke(RRColor.boltGold.opacity(0.16), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, UIScreen.main.bounds.height * 0.07)
        .padding(.bottom, 16)
    }
    
    private var rrHud: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                rrMiniStat(icon: "fireStats", value: "\(rrVm.rrEarnedFire)")
                rrMiniStat(icon: "pineappleStats", value: "\(rrVm.rrEarnedPineapple)")
                rrMiniStat(icon: "3d-star-icon", value: "\(rrVm.rrEarnedStars)")
            }
            
            HStack(spacing: 12) {
                rrInfoCard(title: "Score", value: "\(rrVm.rrScore)", accent: RRColor.boltGold)
                rrInfoCard(title: "Time", value: "\(rrVm.rrTimeLeft)s", accent: RRColor.seaGreen)
                rrInfoCard(title: "Combo", value: "x\(max(rrVm.rrCombo, 1))", accent: Color(red: 1.0, green: 0.45, blue: 0.2))
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func rrMiniStat(icon: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(icon)
                .resizable()
                .frame(width: 20, height: 20)
            
            Text(value)
                .font(.custom(RRFont.semiBold, size: 13))
                .foregroundStyle(RRColor.foamWhite)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(RRColor.foamWhite.opacity(0.06), lineWidth: 1)
                )
        )
    }
    
    private func rrInfoCard(title: String, value: String, accent: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
                .tracking(1)
            
            Text(value)
                .font(.custom(RRFont.black, size: 19))
                .foregroundStyle(RRColor.foamWhite)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(accent.opacity(0.20), lineWidth: 1)
                )
        )
    }
    
    private func rrGameArena(size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial.opacity(0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(RRColor.foamWhite.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            
            ForEach(rrVm.rrFruits) { fruit in
                Image(fruit.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: fruit.size, height: fruit.size)
                    .rotationEffect(.degrees(fruit.rotation))
                    .position(x: fruit.xPosition, y: fruit.yPosition)
                    .shadow(color: RRColor.boltGold.opacity(0.15), radius: 10, x: 0, y: 6)
            }
        }
        .frame(height: size.height * 0.58)
    }
    
    private func rrBasket(size: CGSize) -> some View {
        VStack(spacing: 12) {
            Image("basket-preview")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 116, height: 116)
                .shadow(color: RRColor.riverDeep.opacity(0.35), radius: 16, x: 0, y: 10)
                .position(x: rrVm.rrBasketX, y: 56)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newValue = min(max(value.location.x, 68), size.width - 68)
                            rrVm.rrBasketX = newValue
                        }
                )
            
            Text(rrVm.rrIsPlaying ? "Drag basket to catch fruits" : "Tap start to begin")
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
        }
        .frame(height: 140)
    }
    
    private func rrInstructionOverlay(screenWidth: CGFloat) -> some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
            
            VStack(spacing: 18) {
                Image("basket-preview")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 94, height: 94)
                
                Text("How to Play")
                    .font(.custom(RRFont.black, size: 26))
                    .foregroundStyle(RRColor.foamWhite)
                
                VStack(spacing: 12) {
                    rrInstructionRow(icon: "apple-3d-icon", text: "Catch falling fruits with the basket")
                    rrInstructionRow(icon: "pineapple-3d-icon", text: "Pineapples give bigger rewards")
                    rrInstructionRow(icon: "coconut-3d-icon", text: "Coconuts can reward stars")
                    rrInstructionRow(icon: "3d-star-icon", text: "Build combo for more score")
                }
                
                HStack(spacing: 10) {
                    rrRewardPreview(icon: "fireStats", text: "Fire")
                    rrRewardPreview(icon: "pineappleStats", text: "Pineapple")
                    rrRewardPreview(icon: "3d-star-icon", text: "Stars")
                }
                
                Button {
                    RRHapticsManager.rrLight()
                    RRSoundManager.rrTap()
                    rrVm.rrStartGame(screenWidth: screenWidth)
                } label: {
                    HStack(spacing: 10) {
                        Image("runner_icon")
                            .resizable()
                            .frame(width: 22, height: 22)
                        
                        Text("Start Game")
                            .font(.custom(RRFont.semiBold, size: 16))
                    }
                    .foregroundStyle(RRColor.riverDeep)
                    .frame(width: 220, height: 54)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [RRColor.boltGold, RRColor.boltSunrise],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(RRGameCardButtonStyle())
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(RRColor.boltGold.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
    }
    
    private func rrInstructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
            
            Text(text)
                .font(.custom(RRFont.regular, size: 13))
                .foregroundStyle(RRColor.foamWhite.opacity(0.9))
            
            Spacer()
        }
    }
    
    private func rrRewardPreview(icon: String, text: String) -> some View {
        VStack(spacing: 6) {
            Image(icon)
                .resizable()
                .frame(width: 28, height: 28)
            Text(text)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RRColor.foamWhite.opacity(0.05))
        )
    }
    
    private func rrResultOverlay(screenWidth: CGFloat, screenSize: CGSize) -> some View {
        ZStack {
            Color.black.opacity(0.48)
                .ignoresSafeArea()
            
            VStack(spacing: 18) {
                Image("3d-star-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 76, height: 76)
                
                Text("Round Complete")
                    .font(.custom(RRFont.black, size: 26))
                    .foregroundStyle(RRColor.foamWhite)
                
                Text("Great catch on the tropical trail")
                    .font(.custom(RRFont.regular, size: 13))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
                
                HStack(spacing: 10) {
                    rrResultPill(icon: "fireStats", value: "+\(rrVm.rrEarnedFire)")
                    rrResultPill(icon: "pineappleStats", value: "+\(rrVm.rrEarnedPineapple)")
                    rrResultPill(icon: "3d-star-icon", value: "+\(rrVm.rrEarnedStars)")
                }
                
                VStack(spacing: 10) {
                    rrSummaryRow(title: "Score", value: "\(rrVm.rrScore)")
                    rrSummaryRow(title: "Caught", value: "\(rrVm.rrCaughtCount)")
                    rrSummaryRow(title: "Missed", value: "\(rrVm.rrMissedCount)")
                    rrSummaryRow(title: "Best Combo", value: "x\(rrVm.rrBestCombo)")
                }
                
                HStack(spacing: 12) {
                    Button {
                        RRHapticsManager.rrLight()
                        RRSoundManager.rrTap()
                        if !rrDidSaveResult {
                            rrVm.rrEndGameAndSave(to: rrStats)
                            rrDidSaveResult = true
                        }
                        rrVm.rrRestartGame(screenWidth: screenWidth)
                        rrDidSaveResult = false
                    } label: {
                        Text("Play Again")
                            .font(.custom(RRFont.semiBold, size: 15))
                            .foregroundStyle(RRColor.riverDeep)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [RRColor.boltGold, RRColor.boltSunrise],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .buttonStyle(RRGameCardButtonStyle())
                    
                    Button {
                        RRHapticsManager.rrLight()
                        RRSoundManager.rrTap()
                        if !rrDidSaveResult {
                            rrVm.rrEndGameAndSave(to: rrStats)
                            rrDidSaveResult = true
                        }
                        rrDismiss()
                    } label: {
                        Text("Finish")
                            .font(.custom(RRFont.semiBold, size: 15))
                            .foregroundStyle(RRColor.foamWhite)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                Capsule()
                                    .fill(RRColor.foamWhite.opacity(0.08))
                                    .overlay(
                                        Capsule()
                                            .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(RRGameCardButtonStyle())
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(RRColor.boltGold.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
    }
    
    private func rrResultPill(icon: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(icon)
                .resizable()
                .frame(width: 22, height: 22)
            Text(value)
                .font(.custom(RRFont.black, size: 16))
                .foregroundStyle(RRColor.foamWhite)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(RRColor.foamWhite.opacity(0.06))
        )
    }
    
    private func rrSummaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.custom(RRFont.regular, size: 13))
                .foregroundStyle(RRColor.foamMist.opacity(0.5))
            Spacer()
            Text(value)
                .font(.custom(RRFont.semiBold, size: 14))
                .foregroundStyle(RRColor.foamWhite)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    RRClaimFruitsGameView(rrStats: RRStatsModel())
        .preferredColorScheme(.dark)
}

struct RRBeachRunnerGameView: View {
    @Environment(\.dismiss) private var rrDismiss
    @ObservedObject var rrStats: RRStatsModel

    @StateObject private var rrVm = RRBeachRunnerViewModel()
    @State private var rrDidSaveResult = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                rrBackgroundViewMain324()
                    .ignoresSafeArea()

                rrBeachDecor

                VStack {
                    rrTopPanel
                    rrControls
                }
                rrTrackView(size: geometry.size)

                rrRunnerView(size: geometry.size)

                if rrVm.rrShowInstructions {
                    Rectangle()
                        .fill(RRColor.riverDeep)
                        .ignoresSafeArea()
                    
                    rrInstructionOverlay
                }

                if rrVm.rrIsFinished {
                    Rectangle()
                        .fill(RRColor.riverDeep)
                        .ignoresSafeArea()
                    
                    rrResultOverlay
                }
            }
            .onDisappear {
                rrVm.rrStopAll()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var rrBeachDecor: some View {
        VStack {
            Spacer()
            LinearGradient(
                colors: [
                    RRColor.sandWarm.opacity(0.42),
                    RRColor.boltGold.opacity(0.18),
                    Color.clear
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 260)
        }
        .ignoresSafeArea()
    }

    private var rrTopPanel: some View {
        VStack(spacing: 14) {
            HStack {
                Button {
                    RRHapticsManager.rrLight()
                    RRSoundManager.rrTap()
                    rrVm.rrStopAll()
                    rrDismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                        Image("back-3d")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    }
                    .foregroundStyle(RRColor.foamWhite)
                    .padding(10)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                            )
                    )
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("Beach Runner")
                        .font(.custom(RRFont.black, size: 21))
                        .foregroundStyle(RRColor.foamWhite)

                    Text("Run & dodge")
                        .font(.custom(RRFont.regular, size: 11))
                        .foregroundStyle(RRColor.foamMist.opacity(0.45))
                        .tracking(1)
                }

                Spacer()

                Button {
                    RRHapticsManager.rrLight()
                    RRSoundManager.rrTap()
                    rrVm.rrShowInstructions = true
                } label: {
                    Image("game-key")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(RRColor.boltGold.opacity(0.18), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, UIScreen.main.bounds.height * 0.07)

            HStack(spacing: 10) {
                rrMiniHud(icon: "fireStats", value: "\(rrVm.rrCollectedFire)")
                rrMiniHud(icon: "pineappleStats", value: "\(rrVm.rrCollectedPineapple)")
                rrMiniHud(icon: "3d-star-icon", value: "\(rrVm.rrCollectedStars)")
            }

            HStack(spacing: 12) {
                rrInfoCard(title: "Time", value: "\(rrVm.rrTimeLeft)s", accent: RRColor.boltGold)
                rrInfoCard(title: "Score", value: "\(rrVm.rrFinalScore)", accent: RRColor.seaGreen)
                rrInfoCard(title: "Combo", value: "x\(max(rrVm.rrCombo, 1))", accent: Color.orange)
            }
            .padding(.horizontal, 20)
        }
    }

    private func rrMiniHud(icon: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(icon)
                .resizable()
                .frame(width: 20, height: 20)

            Text(value)
                .font(.custom(RRFont.semiBold, size: 13))
                .foregroundStyle(RRColor.foamWhite)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(RRColor.foamWhite.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func rrInfoCard(title: String, value: String, accent: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
                .tracking(1)

            Text(value)
                .font(.custom(RRFont.black, size: 18))
                .foregroundStyle(RRColor.foamWhite)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(accent.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private func rrTrackView(size: CGSize) -> some View {
        let laneWidth = size.width / 3

        return ZStack {
            RoundedRectangle(cornerRadius: 34)
                .fill(
                    LinearGradient(
                        colors: [
                            RRColor.riverDeep.opacity(0.34),
                            RRColor.riverSurface.opacity(0.18),
                            RRColor.riverDeep.opacity(0.34)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34)
                        .stroke(RRColor.foamWhite.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 170)
                .padding(.bottom, 120)

            VStack {
                Spacer(minLength: 190)

                HStack(spacing: 0) {
                    Rectangle()
                        .fill(RRColor.foamWhite.opacity(0.0))
                        .frame(width: 1)

                    Rectangle()
                        .fill(RRColor.foamWhite.opacity(0.12))
                        .frame(width: 2)
                        .padding(.vertical, 40)

                    Spacer()

                    Rectangle()
                        .fill(RRColor.foamWhite.opacity(0.12))
                        .frame(width: 2)
                        .padding(.vertical, 40)

                    Rectangle()
                        .fill(RRColor.foamWhite.opacity(0.0))
                        .frame(width: 1)
                }
                .padding(.horizontal, laneWidth / 2)

                Spacer(minLength: 120)
            }

            ForEach(rrVm.rrItems) { item in
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: item.size, height: item.size)
                    .position(
                        x: rrLaneX(for: item.lane, totalWidth: size.width),
                        y: item.yPosition
                    )
                    .shadow(color: RRColor.boltGold.opacity(0.12), radius: 12, x: 0, y: 8)
            }
        }
    }

    private func rrRunnerView(size: CGSize) -> some View {
        Image("runner_icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 96, height: 96)
            .position(
                x: rrLaneX(for: rrVm.rrRunnerLane.rawValue, totalWidth: size.width),
                y: size.height * 0.82
            )
            .animation(.spring(response: 0.22, dampingFraction: 0.82), value: rrVm.rrRunnerLane)
    }

    private var rrControls: some View {
        VStack {
            Spacer()

            HStack(spacing: 20) {
                Button {
                    rrVm.rrMoveLeft()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(RRColor.riverDeep)
                        .frame(width: 64, height: 64)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [RRColor.boltGold, RRColor.boltSunrise],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }

                Button {
                    if rrVm.rrIsPlaying == false && rrVm.rrIsFinished == false {
                        rrVm.rrStartGame()
                    } else {
                        rrVm.rrRestartGame()
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image("runner_tab_image")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)

                        Text(rrVm.rrIsPlaying ? "RUN" : "START")
                            .font(.custom(RRFont.semiBold, size: 11))
                            .foregroundStyle(RRColor.riverDeep)
                    }
                    .frame(width: 84, height: 84)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [RRColor.foamWhite, RRColor.boltSunrise],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                }

                Button {
                    rrVm.rrMoveRight()
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(RRColor.riverDeep)
                        .frame(width: 64, height: 64)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [RRColor.boltGold, RRColor.boltSunrise],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
            }
            .padding(.bottom, 24)
        }
    }

    private var rrInstructionOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image("runner_tab_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 94, height: 94)

                Text("Beach Runner")
                    .font(.custom(RRFont.black, size: 28))
                    .foregroundStyle(RRColor.foamWhite)

                VStack(spacing: 12) {
                    rrInstructionRow(icon: "runner_icon", text: "Move between 3 lanes")
                    rrInstructionRow(icon: "stop", text: "Avoid stop signs and obstacles")
                    rrInstructionRow(icon: "apple-3d-icon", text: "Collect fruits for rewards")
                    rrInstructionRow(icon: "3d-star-icon", text: "Grab stars for bonus points")
                }

                HStack(spacing: 10) {
                    rrRewardCard(icon: "fireStats", title: "Fire")
                    rrRewardCard(icon: "pineappleStats", title: "Pineapple")
                    rrRewardCard(icon: "3d-star-icon", title: "Stars")
                }

                Button {
                    rrVm.rrStartGame()
                } label: {
                    HStack(spacing: 10) {
                        Image("runner_icon")
                            .resizable()
                            .frame(width: 24, height: 24)

                        Text("Start Run")
                            .font(.custom(RRFont.semiBold, size: 16))
                    }
                    .foregroundStyle(RRColor.riverDeep)
                    .frame(width: 220, height: 54)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [RRColor.boltGold, RRColor.boltSunrise],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(RRGameCardButtonStyle())
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(RRColor.boltGold.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
    }

    private func rrInstructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)

            Text(text)
                .font(.custom(RRFont.regular, size: 13))
                .foregroundStyle(RRColor.foamWhite.opacity(0.9))

            Spacer()
        }
    }

    private func rrRewardCard(icon: String, title: String) -> some View {
        VStack(spacing: 6) {
            Image(icon)
                .resizable()
                .frame(width: 28, height: 28)

            Text(title)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RRColor.foamWhite.opacity(0.05))
        )
    }

    private var rrResultOverlay: some View {
        ZStack {
            Color.black.opacity(0.52)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(rrVm.rrDidCrash ? "stop" : "3d-star-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 78, height: 78)

                Text(rrVm.rrDidCrash ? "Run Over" : "Great Run")
                    .font(.custom(RRFont.black, size: 27))
                    .foregroundStyle(RRColor.foamWhite)

                Text(rrVm.rrDidCrash ? "You hit an obstacle" : "You finished the beach run")
                    .font(.custom(RRFont.regular, size: 13))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))

                HStack(spacing: 10) {
                    rrResultPill(icon: "fireStats", value: "+\(rrVm.rrCollectedFire)")
                    rrResultPill(icon: "pineappleStats", value: "+\(rrVm.rrCollectedPineapple)")
                    rrResultPill(icon: "3d-star-icon", value: "+\(rrVm.rrCollectedStars)")
                }

                VStack(spacing: 10) {
                    rrSummaryRow(title: "Final Score", value: "\(rrVm.rrFinalScore)")
                    rrSummaryRow(title: "Distance", value: "\(rrVm.rrDistanceScore)")
                    rrSummaryRow(title: "Reward Score", value: "\(rrVm.rrCoinsScore)")
                    rrSummaryRow(title: "Best Combo", value: "x\(rrVm.rrBestCombo)")
                }

                HStack(spacing: 12) {
                    Button {
                        RRHapticsManager.rrLight()
                        RRSoundManager.rrTap()
                        if !rrDidSaveResult {
                            rrVm.rrFinishAndSave(to: rrStats)
                            rrDidSaveResult = true
                        }
                        rrVm.rrRestartGame()
                        rrDidSaveResult = false
                    } label: {
                        Text("Play Again")
                            .font(.custom(RRFont.semiBold, size: 15))
                            .foregroundStyle(RRColor.riverDeep)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [RRColor.boltGold, RRColor.boltSunrise],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .buttonStyle(RRGameCardButtonStyle())

                    Button {
                        RRHapticsManager.rrLight()
                        RRSoundManager.rrTap()
                        if !rrDidSaveResult {
                            rrVm.rrFinishAndSave(to: rrStats)
                            rrDidSaveResult = true
                        }
                        rrDismiss()
                    } label: {
                        Text("Finish")
                            .font(.custom(RRFont.semiBold, size: 15))
                            .foregroundStyle(RRColor.foamWhite)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                Capsule()
                                    .fill(RRColor.foamWhite.opacity(0.08))
                                    .overlay(
                                        Capsule()
                                            .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(RRGameCardButtonStyle())
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(RRColor.boltGold.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
    }

    private func rrResultPill(icon: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(icon)
                .resizable()
                .frame(width: 22, height: 22)

            Text(value)
                .font(.custom(RRFont.black, size: 16))
                .foregroundStyle(RRColor.foamWhite)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(RRColor.foamWhite.opacity(0.06))
        )
    }

    private func rrSummaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.custom(RRFont.regular, size: 13))
                .foregroundStyle(RRColor.foamMist.opacity(0.5))

            Spacer()

            Text(value)
                .font(.custom(RRFont.semiBold, size: 14))
                .foregroundStyle(RRColor.foamWhite)
        }
        .padding(.vertical, 2)
    }

    private func rrLaneX(for lane: Int, totalWidth: CGFloat) -> CGFloat {
        let sidePadding: CGFloat = 40
        let trackWidth = totalWidth - sidePadding * 2
        let laneWidth = trackWidth / 3
        return sidePadding + laneWidth * CGFloat(lane) + laneWidth / 2
    }
}

#Preview {
    RRBeachRunnerGameView(rrStats: RRStatsModel())
        .preferredColorScheme(.dark)
}

struct RRRollDiceGameView: View {
    @Environment(\.dismiss) private var rrDismiss
    @ObservedObject var rrStats: RRStatsModel

    @StateObject private var rrVm = RRRollDiceViewModel()
    @State private var rrDidSaveResult = false

    var body: some View {
        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            rrGlowLayer

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    rrTopBar
                    rrStatsPanel
                    Spacer(minLength: 12)
                    rrDiceBoard
                    Spacer(minLength: 12)
                    rrBottomPanel
                }
            }

            if rrVm.rrShowInstructions {
                Rectangle()
                    .fill(RRColor.riverDeep)
                    .ignoresSafeArea()
                rrInstructionOverlay
            }

            if rrVm.rrRoundFinished {
                Rectangle()
                    .fill(RRColor.riverDeep)
                    .ignoresSafeArea()
                rrResultOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            rrVm.rrIsRolling = false
        }
    }

    private var rrGlowLayer: some View {
        VStack {
            Circle()
                .fill(RRColor.boltGold.opacity(0.10))
                .frame(width: 240, height: 240)
                .blur(radius: 50)
                .offset(x: 120, y: -10)
            Spacer()
        }
        .ignoresSafeArea()
    }

    private var rrTopBar: some View {
        HStack {
            Button {
                RRHapticsManager.rrLight()
                RRSoundManager.rrTap()
                rrDismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                    Image("back-3d")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                }
                .foregroundStyle(RRColor.foamWhite)
                .padding(10)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                        )
                )
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Roll Dice")
                    .font(.custom(RRFont.black, size: 22))
                    .foregroundStyle(RRColor.foamWhite)

                Text("Test your luck")
                    .font(.custom(RRFont.regular, size: 11))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
                    .tracking(1)
            }

            Spacer()

            Button {
                RRHapticsManager.rrLight()
                RRSoundManager.rrTap()
                rrVm.rrShowInstructions = true
            } label: {
                Image("game-key")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(RRColor.boltGold.opacity(0.18), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, UIScreen.main.bounds.height * 0.07)
    }

    private var rrStatsPanel: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                rrMiniReward(icon: "fireStats", value: "\(rrVm.rrEarnedFire)")
                rrMiniReward(icon: "pineappleStats", value: "\(rrVm.rrEarnedPineapple)")
                rrMiniReward(icon: "3d-star-icon", value: "\(rrVm.rrEarnedStars)")
            }

            HStack(spacing: 12) {
                rrInfoCard(title: "Target", value: "\(rrVm.rrTargetValue)", accent: RRColor.boltGold)
                rrInfoCard(title: "Sum", value: "\(rrVm.rrCurrentSum)", accent: RRColor.seaGreen)
                rrInfoCard(title: "Rolls", value: "\(rrVm.rrRollsLeft)", accent: RRColor.boltSunrise)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 16)
    }

    private func rrMiniReward(icon: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(icon)
                .resizable()
                .frame(width: 20, height: 20)

            Text(value)
                .font(.custom(RRFont.semiBold, size: 13))
                .foregroundStyle(RRColor.foamWhite)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(RRColor.foamWhite.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func rrInfoCard(title: String, value: String, accent: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
                .tracking(1)

            Text(value)
                .font(.custom(RRFont.black, size: 20))
                .foregroundStyle(RRColor.foamWhite)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(accent.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private var rrDiceBoard: some View {
        VStack(spacing: 22) {
            Image("dice_game_tab_image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 88, height: 88)
                .shadow(color: RRColor.boltGold.opacity(0.22), radius: 20, x: 0, y: 8)

            Text(rrVm.rrLastMessage)
                .font(.custom(RRFont.semiBold, size: 16))
                .foregroundStyle(RRColor.foamWhite)

            HStack(spacing: 14) {
                rrDiceFace(value: rrVm.rrDiceValues[0])
                rrDiceFace(value: rrVm.rrDiceValues[1])
                rrDiceFace(value: rrVm.rrDiceValues[2])
            }

            HStack(spacing: 10) {
                Text("Round Score")
                    .font(.custom(RRFont.regular, size: 13))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))

                Text("\(rrVm.rrRoundScore)")
                    .font(.custom(RRFont.black, size: 26))
                    .foregroundStyle(RRColor.boltGold)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(RRColor.foamWhite.opacity(0.06), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }

    private func rrDiceFace(value: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            RRColor.foamWhite.opacity(0.96),
                            RRColor.foamMist.opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 88, height: 88)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(RRColor.boltGold.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: RRColor.riverDeep.opacity(0.25), radius: 12, x: 0, y: 8)

            rrPips(for: value)
        }
        .rotationEffect(.degrees(rrVm.rrIsRolling ? Double.random(in: -8...8) : 0))
        .animation(.easeInOut(duration: 0.12), value: rrVm.rrDiceValues)
    }

    @ViewBuilder
    private func rrPips(for value: Int) -> some View {
        let pip = Circle()
            .fill(RRColor.riverDeep)
            .frame(width: 10, height: 10)

        switch value {
        case 1:
            pip
        case 2:
            VStack {
                HStack { pip; Spacer() }
                Spacer()
                HStack { Spacer(); pip }
            }
            .padding(18)
        case 3:
            VStack {
                HStack { pip; Spacer() }
                Spacer()
                pip
                Spacer()
                HStack { Spacer(); pip }
            }
            .padding(18)
        case 4:
            VStack {
                HStack { pip; Spacer(); pip }
                Spacer()
                HStack { pip; Spacer(); pip }
            }
            .padding(18)
        case 5:
            VStack {
                HStack { pip; Spacer(); pip }
                Spacer()
                pip
                Spacer()
                HStack { pip; Spacer(); pip }
            }
            .padding(18)
        default:
            VStack {
                HStack { pip; Spacer(); pip }
                Spacer()
                HStack { pip; Spacer(); pip }
                Spacer()
                HStack { pip; Spacer(); pip }
            }
            .padding(18)
        }
    }

    private var rrBottomPanel: some View {
        VStack(spacing: 14) {
            Button {
                RRHapticsManager.rrLight()
                RRSoundManager.rrTap()
                rrVm.rrRollDice()
            } label: {
                HStack(spacing: 10) {
                    Image("roll")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)

                    Text(rrVm.rrIsRolling ? "Rolling..." : "Roll Dice")
                        .font(.custom(RRFont.semiBold, size: 17))
                }
                .foregroundStyle(RRColor.riverDeep)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [RRColor.boltGold, RRColor.boltSunrise],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: RRColor.boltGold.opacity(0.35), radius: 14, x: 0, y: 6)
            }
            .buttonStyle(RRGameCardButtonStyle())
            .disabled(!rrVm.rrCanRoll)
            .opacity(rrVm.rrCanRoll ? 1 : 0.7)

            Text("Hit the target number for the best reward")
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
    }

    private var rrInstructionOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image("dice_game_tab_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 94, height: 94)

                Text("How to Play")
                    .font(.custom(RRFont.black, size: 28))
                    .foregroundStyle(RRColor.foamWhite)

                VStack(spacing: 12) {
                    rrInstructionRow(icon: "roll", text: "Roll 3 dice each turn")
                    rrInstructionRow(icon: "3d-star-icon", text: "Hit the target for bonus rewards")
                    rrInstructionRow(icon: "fireStats", text: "Near target still gives rewards")
                    rrInstructionRow(icon: "pineappleStats", text: "You have 5 rolls per round")
                }

                Button {
                    rrVm.rrStartGame()
                } label: {
                    HStack(spacing: 10) {
                        Image("roll")
                            .resizable()
                            .frame(width: 22, height: 22)

                        Text("Start Round")
                            .font(.custom(RRFont.semiBold, size: 16))
                    }
                    .foregroundStyle(RRColor.riverDeep)
                    .frame(width: 220, height: 54)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [RRColor.boltGold, RRColor.boltSunrise],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(RRGameCardButtonStyle())
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(RRColor.boltGold.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
    }

    private func rrInstructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)

            Text(text)
                .font(.custom(RRFont.regular, size: 13))
                .foregroundStyle(RRColor.foamWhite.opacity(0.9))

            Spacer()
        }
    }

    private var rrResultOverlay: some View {
        ZStack {
            Color.black.opacity(0.52)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image("3d-star-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 78, height: 78)

                Text("Round Complete")
                    .font(.custom(RRFont.black, size: 27))
                    .foregroundStyle(RRColor.foamWhite)

                Text(rrVm.rrLastMessage)
                    .font(.custom(RRFont.regular, size: 13))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))

                HStack(spacing: 10) {
                    rrResultPill(icon: "fireStats", value: "+\(rrVm.rrEarnedFire)")
                    rrResultPill(icon: "pineappleStats", value: "+\(rrVm.rrEarnedPineapple)")
                    rrResultPill(icon: "3d-star-icon", value: "+\(rrVm.rrEarnedStars)")
                }

                VStack(spacing: 10) {
                    rrSummaryRow(title: "Target", value: "\(rrVm.rrTargetValue)")
                    rrSummaryRow(title: "Final Sum", value: "\(rrVm.rrCurrentSum)")
                    rrSummaryRow(title: "Roll Score", value: "\(rrVm.rrRoundScore)")
                    rrSummaryRow(title: "Rolls Used", value: "\(5 - rrVm.rrRollsLeft)")
                }

                HStack(spacing: 12) {
                    Button {
                        RRHapticsManager.rrLight()
                        RRSoundManager.rrTap()
                        if !rrDidSaveResult {
                            rrVm.rrSaveResult(to: rrStats)
                            rrDidSaveResult = true
                        }
                        rrVm.rrRestartGame()
                        rrDidSaveResult = false
                    } label: {
                        Text("Play Again")
                            .font(.custom(RRFont.semiBold, size: 15))
                            .foregroundStyle(RRColor.riverDeep)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [RRColor.boltGold, RRColor.boltSunrise],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .buttonStyle(RRGameCardButtonStyle())

                    Button {
                        RRHapticsManager.rrLight()
                        RRSoundManager.rrTap()
                        if !rrDidSaveResult {
                            rrVm.rrSaveResult(to: rrStats)
                            rrDidSaveResult = true
                        }
                        rrDismiss()
                    } label: {
                        Text("Finish")
                            .font(.custom(RRFont.semiBold, size: 15))
                            .foregroundStyle(RRColor.foamWhite)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                Capsule()
                                    .fill(RRColor.foamWhite.opacity(0.08))
                                    .overlay(
                                        Capsule()
                                            .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(RRGameCardButtonStyle())
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(RRColor.boltGold.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
    }

    private func rrResultPill(icon: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(icon)
                .resizable()
                .frame(width: 22, height: 22)

            Text(value)
                .font(.custom(RRFont.black, size: 16))
                .foregroundStyle(RRColor.foamWhite)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(RRColor.foamWhite.opacity(0.06))
        )
    }

    private func rrSummaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.custom(RRFont.regular, size: 13))
                .foregroundStyle(RRColor.foamMist.opacity(0.5))

            Spacer()

            Text(value)
                .font(.custom(RRFont.semiBold, size: 14))
                .foregroundStyle(RRColor.foamWhite)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    RRRollDiceGameView(rrStats: RRStatsModel())
        .preferredColorScheme(.dark)
}
