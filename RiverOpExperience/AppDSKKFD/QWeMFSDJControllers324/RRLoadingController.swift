import SwiftUI
import Combine

final class RRLoadingController: ObservableObject {
    @Published var rrLoadingProgress: CGFloat = 0.0
    @Published var rrIsLoadingComplete: Bool = false
    @Published var rrShowLogo: Bool = false
    @Published var rrShowTitle: Bool = false
    @Published var rrShowSubtitle: Bool = false
    @Published var rrShowProgressBar: Bool = false
    @Published var rrPulseActive: Bool = false

    private var rrTimer: Timer?

    func rrStartLoadingSequence() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6, blendDuration: 0)) {
            rrShowLogo = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.6)) {
                self.rrShowTitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeOut(duration: 0.5)) {
                self.rrShowSubtitle = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeOut(duration: 0.4)) {
                self.rrShowProgressBar = true
            }
            self.rrBeginProgress()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.rrPulseActive = true
        }
    }

    private func rrBeginProgress() {
        rrTimer = Timer.scheduledTimer(withTimeInterval: 0.035, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }

            DispatchQueue.main.async {
                let rrIncrement: CGFloat
                if self.rrLoadingProgress < 0.3 {
                    rrIncrement = CGFloat.random(in: 0.015...0.035)
                } else if self.rrLoadingProgress < 0.7 {
                    rrIncrement = CGFloat.random(in: 0.008...0.025)
                } else if self.rrLoadingProgress < 0.9 {
                    rrIncrement = CGFloat.random(in: 0.005...0.015)
                } else {
                    rrIncrement = CGFloat.random(in: 0.01...0.03)
                }

                self.rrLoadingProgress = min(self.rrLoadingProgress + rrIncrement, 1.0)

                if self.rrLoadingProgress >= 1.0 {
                    timer.invalidate()
                    self.rrTimer = nil

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.rrIsLoadingComplete = true
                        }
                    }
                }
            }
        }
    }

    func rrCleanup() {
        rrTimer?.invalidate()
        rrTimer = nil
    }
}

final class RROnboardingController: ObservableObject {
    @Published var rrCurrentPage: Int = 0
    @Published var rrShowContent: Bool = false
    @Published var rrIsOnboardingComplete: Bool = false
    @Published var rrIconBounce: Bool = false
    @Published var rrDragOffset: CGFloat = 0

    let rrPages: [RROnboardingPage] = [
        RROnboardingPage(
            rrIcon: "runner_icon",
            rrTitle: "Run & Collect",
            rrSubtitle: "Beach Runner",
            rrDescription: "Sprint along the shore, dodge obstacles, and grab fruits, fire boosts, and golden stars to rack up your score.",
            rrAccentColor: RRColor.boltGold
        ),
        RROnboardingPage(
            rrIcon: "basket-preview",
            rrTitle: "Claim Fruits",
            rrSubtitle: "Fruit Frenzy",
            rrDescription: "Tap fast to catch falling fruits before they vanish. Apples, lemons, pineapples and watermelons — each worth different points!",
            rrAccentColor: RRColor.riverDeep
        ),
        RROnboardingPage(
            rrIcon: "roll",
            rrTitle: "Roll the Dice",
            rrSubtitle: "Lucky Roller",
            rrDescription: "Test your luck with the dice. Roll big numbers, chain combos, and climb the leaderboard with every toss.",
            rrAccentColor: RRColor.boltSunrise
        ),
        RROnboardingPage(
            rrIcon: "sand_game_image",
            rrTitle: "Draw the Way",
            rrSubtitle: "Path Maker",
            rrDescription: "Trace a safe route for your runner through obstacles on the sand. The smarter your path, the higher your reward.",
            rrAccentColor: RRColor.foamWhite
        ),
        RROnboardingPage(
            rrIcon: "3d-star-icon",
            rrTitle: "Earn Awards",
            rrSubtitle: "Your Journey",
            rrDescription: "Complete games, collect fruits, and hit milestones to unlock exclusive awards. Track everything on your personal map!",
            rrAccentColor: RRColor.boltGold
        ),
    ]

    var rrIsLastPage: Bool {
        rrCurrentPage == rrPages.count - 1
    }

    func rrAdvancePage(rrOnFinished: () -> ()) {
        if rrIsLastPage {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                rrIsOnboardingComplete = true
                rrOnFinished()
            }
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                rrCurrentPage += 1
            }
            rrAnimateContentIn()
        }
    }

    func rrGoBack() {
        guard rrCurrentPage > 0 else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
            rrCurrentPage -= 1
        }
        rrAnimateContentIn()
    }

    func rrAnimateContentIn() {
        rrShowContent = false
        rrIconBounce = false

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            rrShowContent = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.25)) {
            rrIconBounce = true
        }
    }

    func rrHandleDragEnd(rrOnFinished: () -> ()) {
        let rrThreshold: CGFloat = 60
        if rrDragOffset < -rrThreshold {
            rrAdvancePage(rrOnFinished: rrOnFinished)
        } else if rrDragOffset > rrThreshold {
            rrGoBack()
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            rrDragOffset = 0
        }
    }
}

final class RRStatsModel: ObservableObject {
    private let rrFireKey = "RR_fireStatsJ835"
    private let rrPineappleKey = "RR_pineappleStatsJ835"
    private let rrTotalScoreKey = "RR_totalScoreJ835"
    private let rrGamesPlayedKey = "RR_gamesPlayedJ835"
    private let rrStarsKey = "RR_starsJ835"
    private let rrBestRunKey = "RR_bestRunJ835"
    private let rrDidCreateDefaultsKey = "RR_didCreateDefaultStatsJ835"

    @Published var rrFireCount: Int {
        didSet { UserDefaults.standard.set(rrFireCount, forKey: rrFireKey) }
    }

    @Published var rrPineappleCount: Int {
        didSet { UserDefaults.standard.set(rrPineappleCount, forKey: rrPineappleKey) }
    }

    @Published var rrTotalScore: Int {
        didSet { UserDefaults.standard.set(rrTotalScore, forKey: rrTotalScoreKey) }
    }

    @Published var rrGamesPlayed: Int {
        didSet { UserDefaults.standard.set(rrGamesPlayed, forKey: rrGamesPlayedKey) }
    }

    @Published var rrStarsEarned: Int {
        didSet { UserDefaults.standard.set(rrStarsEarned, forKey: rrStarsKey) }
    }

    @Published var rrBestRun: Int {
        didSet { UserDefaults.standard.set(rrBestRun, forKey: rrBestRunKey) }
    }

    init() {
        let defaults = UserDefaults.standard

        if !defaults.bool(forKey: rrDidCreateDefaultsKey) {
            let defaultFireCount = 12
            let defaultPineappleCount = 6
            let defaultTotalScore = 120
            let defaultGamesPlayed = 3
            let defaultStarsEarned = 4
            let defaultBestRun = 55

            defaults.set(defaultFireCount, forKey: rrFireKey)
            defaults.set(defaultPineappleCount, forKey: rrPineappleKey)
            defaults.set(defaultTotalScore, forKey: rrTotalScoreKey)
            defaults.set(defaultGamesPlayed, forKey: rrGamesPlayedKey)
            defaults.set(defaultStarsEarned, forKey: rrStarsKey)
            defaults.set(defaultBestRun, forKey: rrBestRunKey)
            defaults.set(true, forKey: rrDidCreateDefaultsKey)

            self.rrFireCount = defaultFireCount
            self.rrPineappleCount = defaultPineappleCount
            self.rrTotalScore = defaultTotalScore
            self.rrGamesPlayed = defaultGamesPlayed
            self.rrStarsEarned = defaultStarsEarned
            self.rrBestRun = defaultBestRun
        } else {
            self.rrFireCount = defaults.integer(forKey: rrFireKey)
            self.rrPineappleCount = defaults.integer(forKey: rrPineappleKey)
            self.rrTotalScore = defaults.integer(forKey: rrTotalScoreKey)
            self.rrGamesPlayed = defaults.integer(forKey: rrGamesPlayedKey)
            self.rrStarsEarned = defaults.integer(forKey: rrStarsKey)
            self.rrBestRun = defaults.integer(forKey: rrBestRunKey)
        }
    }

    func rrAddFireReward(_ amount: Int) {
        rrFireCount += amount
    }

    func rrAddPineappleReward(_ amount: Int) {
        rrPineappleCount += amount
    }

    func rrRecordGameWin(fire: Int, pineapple: Int, score: Int, stars: Int) {
        rrFireCount += fire
        rrPineappleCount += pineapple
        rrTotalScore += score
        rrGamesPlayed += 1
        rrStarsEarned += stars

        if score > rrBestRun {
            rrBestRun = score
        }
    }

    func rrResetAll() {
        rrFireCount = 0
        rrPineappleCount = 0
        rrTotalScore = 0
        rrGamesPlayed = 0
        rrStarsEarned = 0
        rrBestRun = 0
    }
}

final class RRHomeController: ObservableObject {
    @Published var rrActiveScreen: RRScreenDestination? = nil
    @Published var rrShowContent: Bool = false
    @Published var rrSelectedGameIndex: Int? = nil

    func rrNavigateTo(_ destination: RRScreenDestination) {
        rrActiveScreen = destination
    }

    func rrDismiss() {
        rrActiveScreen = nil
    }

    func rrAnimateIn() {
        rrShowContent = false
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) {
            rrShowContent = true
        }
    }
}

@MainActor
final class RRClaimFruitsViewModel: ObservableObject {
    @Published var rrShowInstructions: Bool = true
    @Published var rrIsPlaying: Bool = false
    @Published var rrIsFinished: Bool = false
    
    @Published var rrFruits: [RRClaimFruitItem] = []
    @Published var rrScore: Int = 0
    @Published var rrTimeLeft: Int = 45
    @Published var rrCaughtCount: Int = 0
    @Published var rrMissedCount: Int = 0
    @Published var rrCombo: Int = 0
    @Published var rrBestCombo: Int = 0
    
    @Published var rrEarnedFire: Int = 0
    @Published var rrEarnedPineapple: Int = 0
    @Published var rrEarnedStars: Int = 0
    
    @Published var rrBasketX: CGFloat = UIScreen.main.bounds.width * 0.5
    
    private var rrSpawnTask: Task<Void, Never>?
    private var rrFallTask: Task<Void, Never>?
    private var rrTimerTask: Task<Void, Never>?
    
    private let rrFruitPool: [RRClaimFruitConfig] = [
        RRClaimFruitConfig(imageName: "apple-3d-icon", rewardType: .fire(1), spawnWeight: 22),
        RRClaimFruitConfig(imageName: "raspberry-3d-icon", rewardType: .fire(1), spawnWeight: 20),
        RRClaimFruitConfig(imageName: "lemon-3d-icon", rewardType: .fire(2), spawnWeight: 15),
        RRClaimFruitConfig(imageName: "pineapple-3d-icon", rewardType: .pineapple(1), spawnWeight: 16),
        RRClaimFruitConfig(imageName: "watermelon-3d-icon", rewardType: .pineapple(2), spawnWeight: 10),
        RRClaimFruitConfig(imageName: "coconut-3d-icon", rewardType: .star(1), spawnWeight: 7)
    ]
    
    func rrStartGame(screenWidth: CGFloat) {
        rrStopGame()
        rrResetForNewGame(screenWidth: screenWidth)
        rrShowInstructions = false
        rrIsPlaying = true
        rrIsFinished = false
        
        rrStartSpawnLoop(screenWidth: screenWidth)
        rrStartFallLoop(screenWidth: screenWidth)
        rrStartTimer()
    }
    
    func rrRestartGame(screenWidth: CGFloat) {
        rrStopAllTasks()
        rrStartGame(screenWidth: screenWidth)
    }
    
    func rrEndGameAndSave(to stats: RRStatsModel) {
        guard rrIsFinished else { return }
        stats.rrRecordGameWin(
            fire: rrEarnedFire,
            pineapple: rrEarnedPineapple,
            score: rrScore,
            stars: rrEarnedStars
        )
    }
    
    func rrCloseInstructions() {
        rrShowInstructions = false
    }
    
    func rrStopGame() {
        rrStopAllTasks()
        rrIsPlaying = false
    }
    
    @MainActor
    deinit {
        rrStopAllTasks()
    }
    
    private func rrResetForNewGame(screenWidth: CGFloat) {
        rrFruits = []
        rrScore = 0
        rrTimeLeft = 45
        rrCaughtCount = 0
        rrMissedCount = 0
        rrCombo = 0
        rrBestCombo = 0
        rrEarnedFire = 0
        rrEarnedPineapple = 0
        rrEarnedStars = 0
        rrBasketX = screenWidth * 0.5
    }
    
    private func rrStartSpawnLoop(screenWidth: CGFloat) {
        rrSpawnTask = Task {
            while !Task.isCancelled && rrIsPlaying {
                let nextDelay = Double.random(in: 0.45...0.85)
                try? await Task.sleep(nanoseconds: UInt64(nextDelay * 1_000_000_000))
                if Task.isCancelled || !rrIsPlaying { break }
                rrSpawnFruit(screenWidth: screenWidth)
            }
        }
    }
    
    private func rrStartFallLoop(screenWidth: CGFloat) {
        rrFallTask = Task {
            while !Task.isCancelled && rrIsPlaying {
                try? await Task.sleep(nanoseconds: 16_000_000)
                if Task.isCancelled || !rrIsPlaying { break }
                rrUpdateFruits(screenWidth: screenWidth)
            }
        }
    }
    
    private func rrStartTimer() {
        rrTimerTask = Task {
            while !Task.isCancelled && rrIsPlaying && rrTimeLeft > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled || !rrIsPlaying { break }
                rrTimeLeft -= 1
                
                if rrTimeLeft <= 0 {
                    rrFinishGame()
                }
            }
        }
    }
    
    private func rrFinishGame() {
        rrStopAllTasks()
        rrIsPlaying = false
        rrIsFinished = true
    }
    
    private func rrStopAllTasks() {
        rrSpawnTask?.cancel()
        rrFallTask?.cancel()
        rrTimerTask?.cancel()
        rrSpawnTask = nil
        rrFallTask = nil
        rrTimerTask = nil
    }
    
    private func rrSpawnFruit(screenWidth: CGFloat) {
        guard let config = rrRandomFruitConfig() else { return }
        
        let size = CGFloat.random(in: 40...62)
        let minX = size / 2 + 10
        let maxX = screenWidth - size / 2 - 10
        
        let fruit = RRClaimFruitItem(
            imageName: config.imageName,
            rewardType: config.rewardType,
            xPosition: CGFloat.random(in: minX...maxX),
            yPosition: -70,
            size: size,
            speed: CGFloat.random(in: 2.2...4.8),
            rotation: Double.random(in: -25...25)
        )
        
        rrFruits.append(fruit)
    }
    
    private func rrRandomFruitConfig() -> RRClaimFruitConfig? {
        let totalWeight = rrFruitPool.reduce(0) { $0 + $1.spawnWeight }
        guard totalWeight > 0 else { return nil }
        
        let randomValue = Int.random(in: 1...totalWeight)
        var current = 0
        
        for item in rrFruitPool {
            current += item.spawnWeight
            if randomValue <= current {
                return item
            }
        }
        return rrFruitPool.last
    }
    
    private func rrUpdateFruits(screenWidth: CGFloat) {
        let screenHeight = UIScreen.main.bounds.height
        let basketWidth: CGFloat = 120
        let basketCatchY = screenHeight * 0.77
        
        var updated: [RRClaimFruitItem] = []
        
        for var fruit in rrFruits {
            fruit.yPosition += fruit.speed * 2.1
            
            let isCaught =
                abs(fruit.xPosition - rrBasketX) < basketWidth * 0.42 &&
                fruit.yPosition > basketCatchY - 28 &&
                fruit.yPosition < basketCatchY + 35
            
            if isCaught {
                rrHandleCaughtFruit(fruit)
                continue
            }
            
            if fruit.yPosition > screenHeight + 80 {
                rrMissedCount += 1
                rrCombo = 0
                continue
            }
            
            updated.append(fruit)
        }
        
        rrFruits = updated
    }
    
    private func rrHandleCaughtFruit(_ fruit: RRClaimFruitItem) {
        rrCaughtCount += 1
        rrCombo += 1
        rrBestCombo = max(rrBestCombo, rrCombo)
        rrScore += fruit.rewardType.points + (rrCombo >= 3 ? 5 : 0)
        
        switch fruit.rewardType {
        case .fire(let value):
            rrEarnedFire += value
        case .pineapple(let value):
            rrEarnedPineapple += value
        case .star(let value):
            rrEarnedStars += value
        }
    }
}

@MainActor
final class RRAwardsViewModel: ObservableObject {
    @Published var rrSelectedAward: RRAwardItem?
    @Published var rrAnimateHero: Bool = false
    @Published var rrPulseSelection: Bool = false

    func rrStartAnimations() {
        rrAnimateHero = false
        rrPulseSelection = false
        
        rrAnimateHero = true
        
        rrPulseSelection = true
    }

    func rrPlayerTitle(from stats: RRStatsModel) -> String {
        let power = stats.rrTotalScore + stats.rrStarsEarned * 20 + stats.rrGamesPlayed * 15

        switch power {
        case 0..<120:
            return "Shore Beginner"
        case 120..<260:
            return "Treasure Seeker"
        case 260..<420:
            return "Wave Chaser"
        case 420..<700:
            return "Island Champion"
        default:
            return "Golden Tide Master"
        }
    }

    func rrCompletionText(from awards: [RRAwardItem]) -> String {
        let unlocked = awards.filter { $0.rrUnlocked }.count
        return "\(unlocked) / \(awards.count) unlocked"
    }

    func rrAwards(from stats: RRStatsModel) -> [RRAwardItem] {
        [
            RRAwardItem(
                rrTitle: "Spark Collector",
                rrSubtitle: "Fire stash milestone",
                rrDescription: "You learned how to keep your energy burning. This badge marks players who collect enough fire to stay active across the island challenge loop.",
                rrIcon: "fireStats",
                rrRarity: stats.rrFireCount >= 30 ? .epic : .common,
                rrProgressValue: stats.rrFireCount,
                rrProgressTarget: 30,
                rrUnlocked: stats.rrFireCount >= 30,
                rrUnlockedText: stats.rrFireCount >= 30 ? "Fire reserve completed" : "Collect more fire"
            ),
            RRAwardItem(
                rrTitle: "Pineapple Vault",
                rrSubtitle: "Treasure fruit reserve",
                rrDescription: "A player with a strong pineapple reserve usually finishes rounds with control and rhythm. This award celebrates consistent reward gathering.",
                rrIcon: "pineappleStats",
                rrRarity: stats.rrPineappleCount >= 20 ? .epic : .rare,
                rrProgressValue: stats.rrPineappleCount,
                rrProgressTarget: 20,
                rrUnlocked: stats.rrPineappleCount >= 20,
                rrUnlockedText: stats.rrPineappleCount >= 20 ? "Vault opened" : "Need more pineapples"
            ),
            RRAwardItem(
                rrTitle: "Star Keeper",
                rrSubtitle: "Shine above the track",
                rrDescription: "Stars are the cleanest proof of good rounds. This title belongs to players who keep their performance bright and steady.",
                rrIcon: "3d-star-icon",
                rrRarity: stats.rrStarsEarned >= 10 ? .legend : .rare,
                rrProgressValue: stats.rrStarsEarned,
                rrProgressTarget: 10,
                rrUnlocked: stats.rrStarsEarned >= 10,
                rrUnlockedText: stats.rrStarsEarned >= 10 ? "Sky mastered" : "Chase more stars"
            ),
            RRAwardItem(
                rrTitle: "Endless Runner",
                rrSubtitle: "Games played milestone",
                rrDescription: "This award is for players who keep returning to the beach. It is less about a single victory and more about momentum over time.",
                rrIcon: "runner_tab_image",
                rrRarity: stats.rrGamesPlayed >= 12 ? .legend : .common,
                rrProgressValue: stats.rrGamesPlayed,
                rrProgressTarget: 12,
                rrUnlocked: stats.rrGamesPlayed >= 12,
                rrUnlockedText: stats.rrGamesPlayed >= 12 ? "Run streak proven" : "Play more rounds"
            ),
            RRAwardItem(
                rrTitle: "High Tide Score",
                rrSubtitle: "Best run badge",
                rrDescription: "Your best run shows the strongest single performance in your profile. Reach a powerful result to prove you can peak under pressure.",
                rrIcon: "dice_game_tab_image",
                rrRarity: stats.rrBestRun >= 120 ? .legend : (stats.rrBestRun >= 70 ? .epic : .rare),
                rrProgressValue: stats.rrBestRun,
                rrProgressTarget: 120,
                rrUnlocked: stats.rrBestRun >= 120,
                rrUnlockedText: stats.rrBestRun >= 120 ? "Peak score reached" : "Push best run higher"
            ),
            RRAwardItem(
                rrTitle: "Treasure Engine",
                rrSubtitle: "Lifetime total score",
                rrDescription: "This is the big one. It tracks your entire journey and unlocks only when your total score starts to feel legendary.",
                rrIcon: "basket-preview",
                rrRarity: stats.rrTotalScore >= 500 ? .legend : (stats.rrTotalScore >= 260 ? .epic : .rare),
                rrProgressValue: stats.rrTotalScore,
                rrProgressTarget: 500,
                rrUnlocked: stats.rrTotalScore >= 500,
                rrUnlockedText: stats.rrTotalScore >= 500 ? "Treasure engine online" : "Build total score"
            )
        ]
    }

    func rrRefreshSelection(using awards: [RRAwardItem]) {
        if let selected = rrSelectedAward,
           let refreshed = awards.first(where: { $0.rrTitle == selected.rrTitle }) {
            rrSelectedAward = refreshed
        } else {
            rrSelectedAward = awards.first(where: { $0.rrUnlocked }) ?? awards.first
        }
    }

    func rrMilestones(from stats: RRStatsModel) -> [RRMilestoneStep] {
        [
            RRMilestoneStep(
                rrTitle: "100 Total Score",
                rrValueText: "\(stats.rrTotalScore)",
                rrReached: stats.rrTotalScore >= 100,
                rrIcon: "basket-preview",
                rrAccent: RRColor.boltGold
            ),
            RRMilestoneStep(
                rrTitle: "5 Stars",
                rrValueText: "\(stats.rrStarsEarned)",
                rrReached: stats.rrStarsEarned >= 5,
                rrIcon: "3d-star-icon",
                rrAccent: RRColor.boltSunrise
            ),
            RRMilestoneStep(
                rrTitle: "10 Games",
                rrValueText: "\(stats.rrGamesPlayed)",
                rrReached: stats.rrGamesPlayed >= 10,
                rrIcon: "runner_icon",
                rrAccent: RRColor.seaGreen
            ),
            RRMilestoneStep(
                rrTitle: "25 Fire",
                rrValueText: "\(stats.rrFireCount)",
                rrReached: stats.rrFireCount >= 25,
                rrIcon: "fireStats",
                rrAccent: Color(red: 1.0, green: 0.45, blue: 0.2)
            )
        ]
    }

    func rrPressureLabel(from stats: RRStatsModel) -> String {
        if stats.rrBestRun >= 120 { return "Elite" }
        if stats.rrBestRun >= 80 { return "Strong" }
        if stats.rrBestRun >= 45 { return "Growing" }
        return "Early"
    }

    func rrResourceBalance(from stats: RRStatsModel) -> String {
        if stats.rrFireCount > stats.rrPineappleCount * 2 { return "Fire Heavy" }
        if stats.rrPineappleCount > stats.rrFireCount { return "Treasure Heavy" }
        return "Balanced"
    }
}

@MainActor
final class RRRootNavigationController: ObservableObject {
    private let rrDidFinishOnboardingKey = "RR_didFinishOnboardingJ835"

    @Published var rrCurrentStage: RRRootStage = .loading
    @Published var rrShowStage: Bool = false

    var rrDidFinishOnboarding: Bool {
        UserDefaults.standard.bool(forKey: rrDidFinishOnboardingKey)
    }

    init() {
        rrCurrentStage = .loading
    }

    func rrStartFlow() {
        rrShowStage = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) { [weak self] in
            guard let self else { return }

            withAnimation(.easeInOut(duration: 0.45)) {
                if self.rrDidFinishOnboarding {
                    self.rrCurrentStage = .main
                } else {
                    self.rrCurrentStage = .onboarding
                }
            }
        }
    }

    func rrCompleteOnboarding() {
        UserDefaults.standard.set(true, forKey: rrDidFinishOnboardingKey)

        withAnimation(.easeInOut(duration: 0.45)) {
            rrCurrentStage = .main
        }
    }

    func rrResetOnboardingForTesting() {
        UserDefaults.standard.set(false, forKey: rrDidFinishOnboardingKey)

        withAnimation(.easeInOut(duration: 0.45)) {
            rrCurrentStage = .onboarding
        }
    }
}
