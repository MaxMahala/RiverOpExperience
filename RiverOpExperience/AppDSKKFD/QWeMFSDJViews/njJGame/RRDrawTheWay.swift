import SwiftUI

struct RRDrawTheWayGameView: View {
    @Environment(\.dismiss) private var rrDismiss
    @ObservedObject var rrStats: RRStatsModel

    @StateObject private var rrVm = RRDrawTheWayViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                rrBackgroundViewMain324()
                    .ignoresSafeArea()

                rrSandGlow

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        rrTopBar
                        rrHud
                        Spacer(minLength: 12)
                        rrBoard(size: geometry.size)
                        Spacer(minLength: 14)
                        rrActionButtons(size: geometry.size)
                    }
                }

                if rrVm.rrShowInstructions {
                    Rectangle()
                        .fill(RRColor.riverDeep)
                        .ignoresSafeArea()
                    rrInstructionOverlay(size: geometry.size)
                }

                if rrVm.rrIsFinished {
                    Rectangle()
                        .fill(RRColor.riverDeep)
                        .ignoresSafeArea()
                    rrResultOverlay(size: geometry.size)
                }
            }
            .onAppear {
                rrVm.rrBuildLevel(in: CGSize(width: geometry.size.width - 40, height: geometry.size.height * 0.55))
            }
            .onDisappear {
                rrVm.rrStop()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var rrSandGlow: some View {
        VStack {
            Spacer()
            Circle()
                .fill(RRColor.sandWarm.opacity(0.22))
                .frame(width: 260, height: 260)
                .blur(radius: 55)
                .offset(y: 60)
        }
        .ignoresSafeArea()
    }

    private var rrTopBar: some View {
        HStack {
            Button {
                RRHapticsManager.rrLight()
                RRSoundManager.rrTap()
                rrVm.rrStop()
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
                Text("Draw the Way")
                    .font(.custom(RRFont.black, size: 22))
                    .foregroundStyle(RRColor.foamWhite)

                Text("Trace the path")
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

    private var rrHud: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                rrMiniReward(icon: "fireStats", value: "\(rrVm.rrEarnedFire)")
                rrMiniReward(icon: "pineappleStats", value: "\(rrVm.rrEarnedPineapple)")
                rrMiniReward(icon: "3d-star-icon", value: "\(rrVm.rrEarnedStars)")
            }

            HStack(spacing: 12) {
                rrInfoCard(title: "Time", value: "\(rrVm.rrTimeLeft)s", accent: RRColor.boltGold)
                rrInfoCard(title: "Score", value: "\(rrVm.rrScore)", accent: RRColor.sandWarm)
                rrInfoCard(title: "Path", value: "\(rrVm.rrPlayerPath.count)", accent: RRColor.seaGreen)
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

    private func rrBoard(size: CGSize) -> some View {
        let boardHeight = size.height * 0.55

        return ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            RRColor.sandWarm.opacity(0.42),
                            RRColor.foamWhite.opacity(0.08),
                            RRColor.sandWarm.opacity(0.28)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                )

            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            RRColor.riverDeep.opacity(0.22),
                            Color.clear,
                            RRColor.riverMid.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RRTargetPathShape(points: rrVm.rrTargetPoints)
                .stroke(
                    RRColor.boltGold.opacity(0.95),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round, dash: [10, 10])
                )
                .shadow(color: RRColor.boltGold.opacity(0.25), radius: 10, x: 0, y: 0)

            RRTargetPathShape(points: rrVm.rrPlayerPath)
                .stroke(
                    RRColor.riverDeep,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                )

            if let start = rrVm.rrTargetPoints.first {
                Circle()
                    .fill(RRColor.seaGreen)
                    .frame(width: 24, height: 24)
                    .position(start)
                    .overlay(
                        Circle()
                            .stroke(RRColor.foamWhite, lineWidth: 3)
                            .frame(width: 24, height: 24)
                            .position(start)
                    )
            }

            if let end = rrVm.rrTargetPoints.last {
                Circle()
                    .fill(RRColor.boltGold)
                    .frame(width: 28, height: 28)
                    .position(end)
                    .overlay(
                        Circle()
                            .stroke(RRColor.foamWhite, lineWidth: 3)
                            .frame(width: 28, height: 28)
                            .position(end)
                    )
            }

            VStack {
                HStack {
                    Text("Start")
                        .font(.custom(RRFont.semiBold, size: 12))
                        .foregroundStyle(RRColor.foamWhite.opacity(0.8))
                    Spacer()
                    Text("Finish")
                        .font(.custom(RRFont.semiBold, size: 12))
                        .foregroundStyle(RRColor.foamWhite.opacity(0.8))
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                Spacer()
            }
        }
        .frame(height: boardHeight)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    rrVm.rrAppendPoint(value.location)
                }
                .onEnded { _ in
                    rrVm.rrFinishDrawing()
                }
        )
    }

    private func rrActionButtons(size: CGSize) -> some View {
        VStack(spacing: 14) {
            Button {
                RRHapticsManager.rrLight()
                RRSoundManager.rrTap()
                rrVm.rrPlayerPath = []
                rrVm.rrMessage = "Try a cleaner path"
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Clear Path")
                        .font(.custom(RRFont.semiBold, size: 16))
                }
                .foregroundStyle(RRColor.foamWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
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
            .padding(.horizontal, 20)

            Text(rrVm.rrMessage)
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
                .padding(.bottom, 24)
        }
    }

    private func rrInstructionOverlay(size: CGSize) -> some View {
        ZStack {
            Color.black.opacity(0.52)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image("sand_game_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 96, height: 96)

                Text("How to Play")
                    .font(.custom(RRFont.black, size: 28))
                    .foregroundStyle(RRColor.foamWhite)

                VStack(spacing: 12) {
                    rrInstructionRow(icon: "sand_game_image", text: "Trace the glowing route in the sand")
                    rrInstructionRow(icon: "game-key", text: "Start from the green point")
                    rrInstructionRow(icon: "3d-star-icon", text: "Finish near the golden point")
                    rrInstructionRow(icon: "fireStats", text: "More accuracy gives better rewards")
                }

                Button {
                    RRHapticsManager.rrLight()
                    RRSoundManager.rrTap()
                    rrVm.rrStartGame(
                        in: CGSize(width: size.width - 40, height: size.height * 0.55)
                    )
                } label: {
                    HStack(spacing: 10) {
                        Image("sand_game_image")
                            .resizable()
                            .frame(width: 22, height: 22)

                        Text("Start Drawing")
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

    private func rrResultOverlay(size: CGSize) -> some View {
        ZStack {
            Color.black.opacity(0.52)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(rrVm.rrDidWin ? "3d-star-icon" : "sand_game_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 78, height: 78)

                Text(rrVm.rrDidWin ? "Path Complete" : "Round Complete")
                    .font(.custom(RRFont.black, size: 27))
                    .foregroundStyle(RRColor.foamWhite)

                Text(rrVm.rrMessage)
                    .font(.custom(RRFont.regular, size: 13))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))

                HStack(spacing: 10) {
                    rrResultPill(icon: "fireStats", value: "+\(rrVm.rrEarnedFire)")
                    rrResultPill(icon: "pineappleStats", value: "+\(rrVm.rrEarnedPineapple)")
                    rrResultPill(icon: "3d-star-icon", value: "+\(rrVm.rrEarnedStars)")
                }

                VStack(spacing: 10) {
                    rrSummaryRow(title: "Score", value: "\(rrVm.rrScore)")
                    rrSummaryRow(title: "Time Left", value: "\(rrVm.rrTimeLeft)s")
                    rrSummaryRow(title: "Path Points", value: "\(rrVm.rrPlayerPath.count)")
                    rrSummaryRow(title: "Status", value: rrVm.rrDidWin ? "Success" : "Need Practice")
                }

                HStack(spacing: 12) {
                    Button {
                        RRHapticsManager.rrLight()
                        RRSoundManager.rrTap()
                        rrVm.rrSaveResult(to: rrStats)
                        rrVm.rrRestartGame(
                            in: CGSize(width: size.width - 40, height: size.height * 0.55)
                        )
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
                        rrVm.rrSaveResult(to: rrStats)
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

struct RRTargetPathShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        guard let first = points.first else { return path }
        path.move(to: first)

        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        return path
    }
}

#Preview {
    RRDrawTheWayGameView(rrStats: RRStatsModel())
        .preferredColorScheme(.dark)
}
