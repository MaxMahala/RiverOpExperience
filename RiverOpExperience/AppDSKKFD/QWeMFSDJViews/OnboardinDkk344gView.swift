import SwiftUI

struct OnboardingView: View {
    @StateObject private var rrController = RROnboardingController()
    @State private var rrWaveOffset: CGFloat = 0
    @State private var rrParticles: [RROnboardingParticle] = []

    let rrOnFinished: () -> Void

    var body: some View {
        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            rrWaveLayer

            rrFloatingParticles

            VStack(spacing: 0) {
                rrSkipButton

                rrIconCard

                rrTextContent
                
                Spacer()

                rrPageIndicator

                Spacer()
                
                rrActionButton
                
                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    rrController.rrDragOffset = value.translation.width
                }
                .onEnded { _ in
                    rrController.rrHandleDragEnd(rrOnFinished: rrOnFinished)
                }
        )
        .onAppear {
            rrController.rrAnimateContentIn()
            rrStartWaves()
            rrMakeParticles()
        }
    }

    private var rrWaveLayer: some View {
        VStack {
            Spacer()
            RRWaveShape(rrOffset: rrWaveOffset, rrAmplitude: 14, rrFrequency: 1.8)
                .fill(
                    LinearGradient(
                        colors: [
                            rrController.rrPages[rrController.rrCurrentPage].rrAccentColor.opacity(0.12),
                            RRColor.riverSurface.opacity(0.06)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 100)
                .animation(.easeInOut(duration: 0.8), value: rrController.rrCurrentPage)

            RRWaveShape(rrOffset: rrWaveOffset + 50, rrAmplitude: 10, rrFrequency: 2.2)
                .fill(RRColor.foamWhite.opacity(0.03))
                .frame(height: 60)
                .offset(y: -40)
        }
        .ignoresSafeArea()
    }

    private var rrFloatingParticles: some View {
        ForEach(rrParticles) { p in
            Circle()
                .fill(p.rrColor)
                .frame(width: p.rrSize, height: p.rrSize)
                .position(x: p.rrX, y: p.rrY)
                .opacity(p.rrOpacity)
                .blur(radius: p.rrBlur)
        }
    }

    private var rrSkipButton: some View {
        HStack {
            Spacer()
            Button {
                RRHapticsManager.rrLight()
                RRSoundManager.rrTap()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    rrController.rrIsOnboardingComplete = true
                    rrOnFinished()
                }
            } label: {
                Text("Skip")
                    .font(.custom(RRFont.semiBold, size: 15))
                    .foregroundColor(RRColor.foamMist.opacity(0.5))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(RRColor.foamWhite.opacity(0.06))
                            .overlay(
                                Capsule()
                                    .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.top, 16)
        .opacity(rrController.rrIsLastPage ? 0 : 1)
        .animation(.easeOut(duration: 0.3), value: rrController.rrIsLastPage)
    }

    private var rrIconCard: some View {
        let currentPage = rrController.rrPages[rrController.rrCurrentPage]

        return ZStack {
            Circle()
                .stroke(currentPage.rrAccentColor.opacity(0.15), lineWidth: 1.5)
                .frame(width: 210, height: 210)
                .scaleEffect(rrController.rrIconBounce ? 1.05 : 0.9)
                .opacity(rrController.rrIconBounce ? 0.6 : 0)

            RoundedRectangle(cornerRadius: 40)
                .fill(.ultraThinMaterial)
                .frame(width: 180, height: 180)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    currentPage.rrAccentColor.opacity(0.4),
                                    currentPage.rrAccentColor.opacity(0.1),
                                    RRColor.foamWhite.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: currentPage.rrAccentColor.opacity(0.2), radius: 30, x: 0, y: 12)
                .shadow(color: RRColor.riverDeep.opacity(0.4), radius: 20, x: 0, y: 8)

            Image(currentPage.rrIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .scaleEffect(rrController.rrIconBounce ? 1.0 : 0.6)
                .opacity(rrController.rrIconBounce ? 1.0 : 0)
        }
        .offset(x: rrController.rrDragOffset * 0.3)
        .scaleEffect(rrController.rrShowContent ? 1.0 : 0.85)
        .opacity(rrController.rrShowContent ? 1.0 : 0)
        .animation(.easeInOut(duration: 0.6), value: rrController.rrCurrentPage)
    }

    private var rrTextContent: some View {
        let currentPage = rrController.rrPages[rrController.rrCurrentPage]

        return VStack(spacing: 12) {
            Text(currentPage.rrSubtitle.uppercased())
                .font(.custom(RRFont.semiBold, size: 12))
                .foregroundColor(currentPage.rrAccentColor)
                .tracking(3)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(currentPage.rrAccentColor.opacity(0.12))
                        .overlay(
                            Capsule()
                                .stroke(currentPage.rrAccentColor.opacity(0.2), lineWidth: 1)
                        )
                )

            Text(currentPage.rrTitle)
                .font(.custom(RRFont.black, size: 30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [RRColor.foamWhite, RRColor.foamMist.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .multilineTextAlignment(.center)
                .padding(.top, 4)

            Text(currentPage.rrDescription)
                .font(.custom(RRFont.regular, size: 15))
                .foregroundColor(RRColor.foamMist.opacity(0.55))
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .frame(height: 180)
                .padding(.top, 4)
        }
        .offset(x: rrController.rrDragOffset * 0.15, y: rrController.rrShowContent ? 0 : 16)
        .opacity(rrController.rrShowContent ? 1.0 : 0)
    }

    private var rrPageIndicator: some View {
        HStack(spacing: 10) {
            ForEach(0..<rrController.rrPages.count, id: \.self) { i in
                Capsule()
                    .fill(
                        i == rrController.rrCurrentPage
                        ? rrController.rrPages[rrController.rrCurrentPage].rrAccentColor
                        : RRColor.foamWhite.opacity(0.15)
                    )
                    .frame(
                        width: i == rrController.rrCurrentPage ? 28 : 8,
                        height: 8
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: rrController.rrCurrentPage)
            }
        }
    }

    private var rrActionButton: some View {
        Button {
            RRHapticsManager.rrLight()
            RRSoundManager.rrTap()
            rrController.rrAdvancePage(rrOnFinished: rrOnFinished)
        } label: {
            HStack(spacing: 10) {
                Text(rrController.rrIsLastPage ? "Let's Go!" : "Continue")
                    .font(.custom(RRFont.semiBold, size: 17))

                Image(systemName: rrController.rrIsLastPage ? "bolt.fill" : "arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                    .rotationEffect(.degrees(rrController.rrIsLastPage ? 0 : 0))
            }
            .foregroundColor(RRColor.riverDeep)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    RRColor.boltGold,
                                    RRColor.boltSunrise
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    RRColor.foamWhite.opacity(0.25),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .shadow(color: RRColor.boltGold.opacity(0.35), radius: 16, x: 0, y: 8)
            .shadow(color: RRColor.boltGold.opacity(0.15), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(rrController.rrShowContent ? 1.0 : 0.92)
        .opacity(rrController.rrShowContent ? 1.0 : 0)
        .overlay(alignment: .top) {
            if rrController.rrCurrentPage > 0 {
                Button {
                    rrController.rrGoBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Back")
                            .font(.custom(RRFont.regular, size: 14))
                    }
                    .foregroundColor(RRColor.foamMist.opacity(0.4))
                }
                .offset(y: 68)
                .transition(.opacity)
            }
        }
    }

    private func rrStartWaves() {
        withAnimation(
            .linear(duration: 5.0)
            .repeatForever(autoreverses: false)
        ) {
            rrWaveOffset = 360
        }
    }

    private func rrMakeParticles() {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        rrParticles = (0..<15).map { _ in
            RROnboardingParticle(
                rrX: CGFloat.random(in: 0...w),
                rrY: CGFloat.random(in: 0...h),
                rrSize: CGFloat.random(in: 2...5),
                rrOpacity: Double.random(in: 0.04...0.15),
                rrBlur: CGFloat.random(in: 0...2),
                rrColor: [RRColor.boltGold, RRColor.boltSunrise, RRColor.foamWhite].randomElement()!.opacity(0.35)
            )
        }
    }
}

#Preview {
    OnboardingView(rrOnFinished: {})
        .preferredColorScheme(.dark)
}

struct RRAwardsScreen: View {
    @Environment(\.dismiss) private var rrDismiss
    @ObservedObject var rrStats: RRStatsModel
    @StateObject private var rrVm = RRAwardsViewModel()

    var body: some View {
        let awards = rrVm.rrAwards(from: rrStats)
        let milestones = rrVm.rrMilestones(from: rrStats)

        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            rrAmbientDecor

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    rrTopBar
                    rrHeroCard(awards: awards)
                    rrInsightStrip
                    rrAwardConstellation(awards: awards)
                    rrSelectedAwardPanel
                    rrMilestonesBoard(milestones: milestones)
                    rrFooterSummary(awards: awards)
                    Spacer().frame(height: 36)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            rrVm.rrStartAnimations()
            rrVm.rrRefreshSelection(using: awards)
        }
        .onChange(of: rrStats.rrFireCount) { _ in
            rrVm.rrRefreshSelection(using: rrVm.rrAwards(from: rrStats))
        }
        .onChange(of: rrStats.rrPineappleCount) { _ in
            rrVm.rrRefreshSelection(using: rrVm.rrAwards(from: rrStats))
        }
        .onChange(of: rrStats.rrStarsEarned) { _ in
            rrVm.rrRefreshSelection(using: rrVm.rrAwards(from: rrStats))
        }
        .onChange(of: rrStats.rrGamesPlayed) { _ in
            rrVm.rrRefreshSelection(using: rrVm.rrAwards(from: rrStats))
        }
        .onChange(of: rrStats.rrBestRun) { _ in
            rrVm.rrRefreshSelection(using: rrVm.rrAwards(from: rrStats))
        }
        .onChange(of: rrStats.rrTotalScore) { _ in
            rrVm.rrRefreshSelection(using: rrVm.rrAwards(from: rrStats))
        }
        .navigationBarHidden(true)
    }

    private var rrAmbientDecor: some View {
        ZStack {
            VStack {
                Circle()
                    .fill(RRColor.boltGold.opacity(0.14))
                    .frame(width: 230, height: 230)
                    .blur(radius: 55)
                    .offset(x: 120, y: -40)
                Spacer()
            }

            VStack {
                Spacer()
                Circle()
                    .fill(RRColor.seaGreen.opacity(0.14))
                    .frame(width: 210, height: 210)
                    .blur(radius: 50)
                    .offset(x: -110, y: 80)
            }
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
                Text("Awards")
                    .font(.custom(RRFont.black, size: 24))
                    .foregroundStyle(RRColor.foamWhite)

                Text("Achievements & details")
                    .font(.custom(RRFont.regular, size: 11))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
                    .tracking(1.2)
            }

            Spacer()

            Image("3d-star-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 42, height: 42)
                .scaleEffect(rrVm.rrPulseSelection ? 1.06 : 1.0)
        }
        .padding(.top, UIScreen.main.bounds.height * 0.07)
    }

    private func rrHeroCard(awards: [RRAwardItem]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(rrVm.rrPlayerTitle(from: rrStats))
                        .font(.custom(RRFont.black, size: 26))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [RRColor.foamWhite, RRColor.boltSunrise],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text(rrVm.rrCompletionText(from: awards))
                        .font(.custom(RRFont.regular, size: 12))
                        .foregroundStyle(RRColor.foamMist.opacity(0.55))
                        .tracking(1.2)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(RRColor.boltGold.opacity(0.12))
                        .frame(width: 76, height: 76)
                        .scaleEffect(rrVm.rrPulseSelection ? 1.08 : 1.0)

                    Image("3d-star-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                }
            }

            HStack(spacing: 10) {
                rrHeroMetric(icon: "basket-preview", title: "Total", value: "\(rrStats.rrTotalScore)")
                rrHeroMetric(icon: "runner_icon", title: "Played", value: "\(rrStats.rrGamesPlayed)")
                rrHeroMetric(icon: "dice_game_tab_image", title: "Best", value: "\(rrStats.rrBestRun)")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    RRColor.boltGold.opacity(0.22),
                                    RRColor.foamWhite.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: RRColor.riverDeep.opacity(0.35), radius: 18, x: 0, y: 10)
        .offset(y: rrVm.rrAnimateHero ? 0 : -18)
        .opacity(rrVm.rrAnimateHero ? 1 : 0)
    }

    private func rrHeroMetric(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)

            Text(value)
                .font(.custom(RRFont.black, size: 18))
                .foregroundStyle(RRColor.foamWhite)
                .monospacedDigit()

            Text(title)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(RRColor.foamWhite.opacity(0.05))
        )
    }

    private var rrInsightStrip: some View {
        HStack(spacing: 12) {
            rrInsightCard(
                title: "Pressure Rank",
                value: rrVm.rrPressureLabel(from: rrStats),
                subtitle: "Based on best run",
                accent: RRColor.boltGold
            )

            rrInsightCard(
                title: "Resource Mode",
                value: rrVm.rrResourceBalance(from: rrStats),
                subtitle: "Fire vs pineapple",
                accent: RRColor.seaGreen
            )
        }
    }

    private func rrInsightCard(title: String, value: String, subtitle: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom(RRFont.regular, size: 11))
                .foregroundStyle(RRColor.foamMist.opacity(0.5))

            Text(value)
                .font(.custom(RRFont.semiBold, size: 16))
                .foregroundStyle(RRColor.foamWhite)

            Text(subtitle)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundStyle(accent.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(accent.opacity(0.16), lineWidth: 1)
                )
        )
    }

    private func rrAwardConstellation(awards: [RRAwardItem]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Award Constellation")
                    .font(.custom(RRFont.semiBold, size: 18))
                    .foregroundStyle(RRColor.foamWhite)

                Spacer()

                Text("Tap a badge")
                    .font(.custom(RRFont.regular, size: 11))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(awards) { award in
                    Button {
                        RRHapticsManager.rrLight()
                        RRSoundManager.rrTap()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            rrVm.rrSelectedAward = award
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(award.rrRarity.rrGlow)
                                        .frame(width: 54, height: 54)
                                        .scaleEffect(rrVm.rrSelectedAward?.id == award.id && rrVm.rrPulseSelection ? 1.08 : 1.0)

                                    Image(award.rrIcon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .saturation(award.rrUnlocked ? 1.0 : 0.0)
                                }

                                Spacer()

                                Text(award.rrRarity.rawValue)
                                    .font(.custom(RRFont.semiBold, size: 10))
                                    .foregroundStyle(award.rrRarity.rrColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(award.rrRarity.rrColor.opacity(0.10))
                                    )
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(award.rrTitle)
                                    .font(.custom(RRFont.semiBold, size: 15))
                                    .foregroundStyle(RRColor.foamWhite)

                                Text(award.rrSubtitle)
                                    .font(.custom(RRFont.regular, size: 11))
                                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
                            }

                            rrAwardProgress(value: award.rrProgressValue, target: award.rrProgressTarget, accent: award.rrRarity.rrColor)

                            Text(award.rrUnlocked ? "Unlocked" : "Locked")
                                .font(.custom(RRFont.regular, size: 11))
                                .foregroundStyle(award.rrUnlocked ? award.rrRarity.rrColor : RRColor.foamMist.opacity(0.4))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            rrVm.rrSelectedAward?.id == award.id
                                            ? award.rrRarity.rrColor.opacity(0.38)
                                            : RRColor.foamWhite.opacity(0.08),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(RRGameCardButtonStyle())
                }
            }
        }
    }

    private func rrAwardProgress(value: Int, target: Int, accent: Color) -> some View {
        let progress = min(max(Double(value) / Double(max(target, 1)), 0), 1)

        return VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(RRColor.foamWhite.opacity(0.08))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [accent.opacity(0.8), accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(value)")
                Spacer()
                Text("\(target)")
            }
            .font(.custom(RRFont.regular, size: 10))
            .foregroundStyle(RRColor.foamMist.opacity(0.45))
        }
    }

    private var rrSelectedAwardPanel: some View {
        Group {
            if let award = rrVm.rrSelectedAward {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .center) {
                        ZStack {
                            Circle()
                                .fill(award.rrRarity.rrGlow)
                                .frame(width: 70, height: 70)

                            Image(award.rrIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 38, height: 38)
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            Text(award.rrTitle)
                                .font(.custom(RRFont.black, size: 22))
                                .foregroundStyle(RRColor.foamWhite)

                            Text(award.rrUnlockedText)
                                .font(.custom(RRFont.regular, size: 12))
                                .foregroundStyle(award.rrRarity.rrColor)
                        }

                        Spacer()
                    }

                    Text(award.rrDescription)
                        .font(.custom(RRFont.regular, size: 13))
                        .foregroundStyle(RRColor.foamMist.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 12) {
                        rrDetailBadge(title: "Progress", value: "\(award.rrProgressValue)/\(award.rrProgressTarget)")
                        rrDetailBadge(title: "Tier", value: award.rrRarity.rawValue)
                        rrDetailBadge(title: "State", value: award.rrUnlocked ? "Open" : "Locked")
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 26)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(award.rrRarity.rrColor.opacity(0.22), lineWidth: 1)
                        )
                )
            }
        }
    }

    private func rrDetailBadge(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))

            Text(value)
                .font(.custom(RRFont.semiBold, size: 13))
                .foregroundStyle(RRColor.foamWhite)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RRColor.foamWhite.opacity(0.05))
        )
    }

    private func rrMilestonesBoard(milestones: [RRMilestoneStep]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Milestone Route")
                .font(.custom(RRFont.semiBold, size: 18))
                .foregroundStyle(RRColor.foamWhite)

            VStack(spacing: 12) {
                ForEach(milestones) { step in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(step.rrReached ? step.rrAccent.opacity(0.18) : RRColor.foamWhite.opacity(0.06))
                                .frame(width: 52, height: 52)

                            Image(step.rrIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 28, height: 28)
                                .saturation(step.rrReached ? 1.0 : 0.0)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(step.rrTitle)
                                .font(.custom(RRFont.semiBold, size: 15))
                                .foregroundStyle(RRColor.foamWhite)

                            Text("Current value: \(step.rrValueText)")
                                .font(.custom(RRFont.regular, size: 11))
                                .foregroundStyle(RRColor.foamMist.opacity(0.45))
                        }

                        Spacer()

                        Image(systemName: step.rrReached ? "checkmark.seal.fill" : "lock.fill")
                            .foregroundStyle(step.rrReached ? step.rrAccent : RRColor.foamMist.opacity(0.35))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(step.rrReached ? step.rrAccent.opacity(0.18) : RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }

    private func rrFooterSummary(awards: [RRAwardItem]) -> some View {
        let unlockedCount = awards.filter { $0.rrUnlocked }.count
        let lockedCount = awards.count - unlockedCount

        return VStack(alignment: .leading, spacing: 14) {
            Text("Treasure Summary")
                .font(.custom(RRFont.semiBold, size: 18))
                .foregroundStyle(RRColor.foamWhite)

            HStack(spacing: 12) {
                rrSummaryCard(title: "Unlocked", value: "\(unlockedCount)", accent: RRColor.seaGreen)
                rrSummaryCard(title: "Locked", value: "\(lockedCount)", accent: RRColor.boltGold)
                rrSummaryCard(title: "Best Run", value: "\(rrStats.rrBestRun)", accent: Color(red: 1.0, green: 0.45, blue: 0.2))
            }
        }
    }

    private func rrSummaryCard(title: String, value: String, accent: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.custom(RRFont.black, size: 22))
                .foregroundStyle(RRColor.foamWhite)

            Text(title)
                .font(.custom(RRFont.regular, size: 11))
                .foregroundStyle(accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(accent.opacity(0.16), lineWidth: 1)
                )
        )
    }
}

#Preview {
    RRAwardsScreen(rrStats: RRStatsModel())
        .preferredColorScheme(.dark)
}
