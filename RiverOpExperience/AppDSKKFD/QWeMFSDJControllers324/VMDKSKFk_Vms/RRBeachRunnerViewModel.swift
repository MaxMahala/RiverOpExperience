import SwiftUI
import Combine

@MainActor
final class RRBeachRunnerViewModel: ObservableObject {
    @Published var rrShowInstructions: Bool = true
    @Published var rrIsPlaying: Bool = false
    @Published var rrIsFinished: Bool = false
    @Published var rrDidCrash: Bool = false

    @Published var rrRunnerLane: RRBeachRunnerLane = .center
    @Published var rrItems: [RRBeachLaneItem] = []

    @Published var rrTimeLeft: Int = 40
    @Published var rrDistanceScore: Int = 0
    @Published var rrCollectedFire: Int = 0
    @Published var rrCollectedPineapple: Int = 0
    @Published var rrCollectedStars: Int = 0
    @Published var rrCoinsScore: Int = 0
    @Published var rrBestCombo: Int = 0
    @Published var rrCombo: Int = 0

    private var rrSpawnTask: Task<Void, Never>?
    private var rrMoveTask: Task<Void, Never>?
    private var rrTimerTask: Task<Void, Never>?

    private let rrRunnerYRatio: CGFloat = 0.82

    var rrFinalScore: Int {
        rrDistanceScore + rrCoinsScore
    }

    func rrStartGame() {
        rrResetGame()
        rrShowInstructions = false
        rrIsPlaying = true
        rrStartSpawnLoop()
        rrStartMoveLoop()
        rrStartTimerLoop()
    }

    func rrRestartGame() {
        rrStopAll()
        rrStartGame()
    }

    func rrMoveLeft() {
        guard rrIsPlaying else { return }
        switch rrRunnerLane {
        case .left: break
        case .center: rrRunnerLane = .left
        case .right: rrRunnerLane = .center
        }
    }

    func rrMoveRight() {
        guard rrIsPlaying else { return }
        switch rrRunnerLane {
        case .left: rrRunnerLane = .center
        case .center: rrRunnerLane = .right
        case .right: break
        }
    }

    func rrFinishAndSave(to stats: RRStatsModel) {
        guard rrIsFinished else { return }
        stats.rrRecordGameWin(
            fire: rrCollectedFire,
            pineapple: rrCollectedPineapple,
            score: rrFinalScore,
            stars: rrCollectedStars
        )
    }

    func rrStopAll() {
        rrSpawnTask?.cancel()
        rrMoveTask?.cancel()
        rrTimerTask?.cancel()
        rrSpawnTask = nil
        rrMoveTask = nil
        rrTimerTask = nil
        rrIsPlaying = false
    }

    private func rrResetGame() {
        rrRunnerLane = .center
        rrItems = []
        rrTimeLeft = 40
        rrDistanceScore = 0
        rrCollectedFire = 0
        rrCollectedPineapple = 0
        rrCollectedStars = 0
        rrCoinsScore = 0
        rrBestCombo = 0
        rrCombo = 0
        rrDidCrash = false
        rrIsFinished = false
    }

    private func rrStartSpawnLoop() {
        rrSpawnTask = Task {
            while !Task.isCancelled && rrIsPlaying {
                try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 0.42...0.72) * 1_000_000_000))
                if Task.isCancelled || !rrIsPlaying { break }
                rrSpawnItem()
            }
        }
    }

    private func rrStartMoveLoop() {
        rrMoveTask = Task {
            while !Task.isCancelled && rrIsPlaying {
                try? await Task.sleep(nanoseconds: 16_000_000)
                if Task.isCancelled || !rrIsPlaying { break }
                rrUpdateItems()
                rrDistanceScore += 1
            }
        }
    }

    private func rrStartTimerLoop() {
        rrTimerTask = Task {
            while !Task.isCancelled && rrIsPlaying && rrTimeLeft > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled || !rrIsPlaying { break }
                rrTimeLeft -= 1
                if rrTimeLeft <= 0 {
                    rrEndGame(crashed: false)
                }
            }
        }
    }

    private func rrEndGame(crashed: Bool) {
        rrStopAll()
        rrDidCrash = crashed
        rrIsFinished = true
    }

    private func rrSpawnItem() {
        let lane = Int.random(in: 0...2)
        let roll = Int.random(in: 1...100)

        let item: RRBeachLaneItem

        if roll <= 28 {
            item = RRBeachLaneItem(
                imageName: "stop",
                lane: lane,
                yPosition: -80,
                size: 52,
                isObstacle: true,
                fireReward: 0,
                pineappleReward: 0,
                starReward: 0,
                scoreReward: 0
            )
        } else if roll <= 53 {
            item = RRBeachLaneItem(
                imageName: "apple-3d-icon",
                lane: lane,
                yPosition: -80,
                size: 46,
                isObstacle: false,
                fireReward: 1,
                pineappleReward: 0,
                starReward: 0,
                scoreReward: 16
            )
        } else if roll <= 73 {
            item = RRBeachLaneItem(
                imageName: "lemon-3d-icon",
                lane: lane,
                yPosition: -80,
                size: 46,
                isObstacle: false,
                fireReward: 2,
                pineappleReward: 0,
                starReward: 0,
                scoreReward: 20
            )
        } else if roll <= 88 {
            item = RRBeachLaneItem(
                imageName: "pineapple-3d-icon",
                lane: lane,
                yPosition: -80,
                size: 52,
                isObstacle: false,
                fireReward: 0,
                pineappleReward: 1,
                starReward: 0,
                scoreReward: 28
            )
        } else {
            item = RRBeachLaneItem(
                imageName: "3d-star-icon",
                lane: lane,
                yPosition: -80,
                size: 42,
                isObstacle: false,
                fireReward: 0,
                pineappleReward: 0,
                starReward: 1,
                scoreReward: 40
            )
        }

        rrItems.append(item)
    }

    private func rrUpdateItems() {
        let screenHeight = UIScreen.main.bounds.height
        let runnerCollisionY = screenHeight * rrRunnerYRatio

        var updatedItems: [RRBeachLaneItem] = []

        for var item in rrItems {
            item.yPosition += 7.2

            let sameLane = item.lane == rrRunnerLane.rawValue
            let isNearRunner = item.yPosition > runnerCollisionY - 54 && item.yPosition < runnerCollisionY + 24

            if sameLane && isNearRunner {
                if item.isObstacle {
                    rrEndGame(crashed: true)
                    return
                } else {
                    rrCollectedFire += item.fireReward
                    rrCollectedPineapple += item.pineappleReward
                    rrCollectedStars += item.starReward
                    rrCoinsScore += item.scoreReward
                    rrCombo += 1
                    rrBestCombo = max(rrBestCombo, rrCombo)
                    continue
                }
            }

            if item.yPosition > screenHeight + 100 {
                if !item.isObstacle {
                    rrCombo = 0
                }
                continue
            }

            updatedItems.append(item)
        }

        rrItems = updatedItems
    }
}

@MainActor
final class RRRollDiceViewModel: ObservableObject {
    @Published var rrShowInstructions: Bool = true
    @Published var rrIsRolling: Bool = false
    @Published var rrRoundFinished: Bool = false

    @Published var rrDiceValues: [Int] = [1, 1, 1]
    @Published var rrTargetValue: Int = Int.random(in: 8...16)
    @Published var rrRollsLeft: Int = 5
    @Published var rrRoundScore: Int = 0

    @Published var rrEarnedFire: Int = 0
    @Published var rrEarnedPineapple: Int = 0
    @Published var rrEarnedStars: Int = 0

    @Published var rrLastMessage: String = "Roll the dice and hit the target"

    private var rrAnimationTask: Task<Void, Never>?

    var rrCurrentSum: Int {
        rrDiceValues.reduce(0, +)
    }

    var rrCanRoll: Bool {
        !rrIsRolling && rrRollsLeft > 0 && !rrRoundFinished
    }

    func rrStartGame() {
        rrResetGame()
        rrShowInstructions = false
    }

    func rrRestartGame() {
        rrResetGame()
    }

    func rrRollDice() {
        guard rrCanRoll else { return }

        rrIsRolling = true
        rrLastMessage = "Rolling..."
        rrRollsLeft -= 1

        rrAnimationTask?.cancel()
        rrAnimationTask = Task {
            for _ in 0..<10 {
                try? await Task.sleep(nanoseconds: 80_000_000)
                if Task.isCancelled { return }

                await MainActor.run {
                    self.rrDiceValues = [
                        Int.random(in: 1...6),
                        Int.random(in: 1...6),
                        Int.random(in: 1...6)
                    ]
                }
            }

            await MainActor.run {
                self.rrFinishRoll()
            }
        }
    }

    private func rrFinishRoll() {
        rrIsRolling = false

        let sum = rrCurrentSum
        let difference = abs(sum - rrTargetValue)

        switch difference {
        case 0:
            rrRoundScore += 120
            rrEarnedFire += 3
            rrEarnedPineapple += 2
            rrEarnedStars += 2
            rrLastMessage = "Perfect hit"
            rrRoundFinished = true

        case 1:
            rrRoundScore += 80
            rrEarnedFire += 2
            rrEarnedPineapple += 1
            rrEarnedStars += 1
            rrLastMessage = "Very close"
            rrRoundFinished = true

        case 2:
            rrRoundScore += 55
            rrEarnedFire += 2
            rrEarnedPineapple += 1
            rrLastMessage = "Nice roll"
            rrRoundFinished = true

        case 3:
            rrRoundScore += 30
            rrEarnedFire += 1
            rrLastMessage = "Good try"
            if rrRollsLeft == 0 {
                rrRoundFinished = true
            }

        default:
            rrRoundScore += 10
            rrLastMessage = "Try again"
            if rrRollsLeft == 0 {
                rrRoundFinished = true
            }
        }

        if rrRoundFinished && rrCurrentSum != rrTargetValue && rrLastMessage == "Try again" {
            rrLastMessage = "Round finished"
        }
    }

    func rrSaveResult(to stats: RRStatsModel) {
        stats.rrRecordGameWin(
            fire: rrEarnedFire,
            pineapple: rrEarnedPineapple,
            score: rrRoundScore,
            stars: rrEarnedStars
        )
    }

    private func rrResetGame() {
        rrAnimationTask?.cancel()
        rrIsRolling = false
        rrRoundFinished = false
        rrDiceValues = [1, 1, 1]
        rrTargetValue = Int.random(in: 8...16)
        rrRollsLeft = 5
        rrRoundScore = 0
        rrEarnedFire = 0
        rrEarnedPineapple = 0
        rrEarnedStars = 0
        rrLastMessage = "Roll the dice and hit the target"
    }
}

@MainActor
final class RRDrawTheWayViewModel: ObservableObject {
    @Published var rrShowInstructions: Bool = true
    @Published var rrIsPlaying: Bool = false
    @Published var rrIsFinished: Bool = false
    @Published var rrDidWin: Bool = false

    @Published var rrTimeLeft: Int = 25
    @Published var rrScore: Int = 0

    @Published var rrEarnedFire: Int = 0
    @Published var rrEarnedPineapple: Int = 0
    @Published var rrEarnedStars: Int = 0

    @Published var rrPlayerPath: [CGPoint] = []
    @Published var rrTargetPoints: [CGPoint] = []

    @Published var rrMessage: String = "Trace the glowing path"

    private var rrTimerTask: Task<Void, Never>?
    private var rrHasSaved: Bool = false

    func rrStartGame(in size: CGSize) {
        rrResetGame(in: size)
        rrShowInstructions = false
        rrIsPlaying = true
        rrStartTimer()
    }

    func rrRestartGame(in size: CGSize) {
        rrStop()
        rrResetGame(in: size)
        rrIsPlaying = true
        rrShowInstructions = false
        rrStartTimer()
    }

    func rrStop() {
        rrTimerTask?.cancel()
        rrTimerTask = nil
        rrIsPlaying = false
    }

    func rrBuildLevel(in size: CGSize) {
        let width = size.width - 40
        let height = size.height

        let x0 = width * 0.18
        let x1 = width * 0.35
        let x2 = width * 0.58
        let x3 = width * 0.76

        let y0 = height * 0.18
        let y1 = height * 0.32
        let y2 = height * 0.47
        let y3 = height * 0.62
        let y4 = height * 0.78

        rrTargetPoints = [
            CGPoint(x: x0, y: y4),
            CGPoint(x: x1, y: y3),
            CGPoint(x: x1, y: y2),
            CGPoint(x: x2, y: y1),
            CGPoint(x: x3, y: y1),
            CGPoint(x: x3, y: y0)
        ]
    }

    func rrAppendPoint(_ point: CGPoint) {
        guard rrIsPlaying, !rrIsFinished else { return }
        rrPlayerPath.append(point)
    }

    func rrFinishDrawing() {
        guard rrIsPlaying, !rrIsFinished else { return }

        let score = rrEvaluatePath()
        rrScore = score

        if score >= 78 {
            rrDidWin = true
            rrMessage = "Great path"
            rrEarnedFire = 3
            rrEarnedPineapple = 2
            rrEarnedStars = 1
        } else if score >= 58 {
            rrDidWin = true
            rrMessage = "Nice tracing"
            rrEarnedFire = 2
            rrEarnedPineapple = 1
            rrEarnedStars = 0
        } else if score >= 35 {
            rrDidWin = false
            rrMessage = "Almost there"
            rrEarnedFire = 1
            rrEarnedPineapple = 0
            rrEarnedStars = 0
        } else {
            rrDidWin = false
            rrMessage = "Path missed"
            rrEarnedFire = 0
            rrEarnedPineapple = 0
            rrEarnedStars = 0
        }

        rrFinishGame()
    }

    func rrSaveResult(to stats: RRStatsModel) {
        guard !rrHasSaved else { return }
        rrHasSaved = true

        stats.rrRecordGameWin(
            fire: rrEarnedFire,
            pineapple: rrEarnedPineapple,
            score: rrScore,
            stars: rrEarnedStars
        )
    }

    private func rrResetGame(in size: CGSize) {
        rrTimeLeft = 25
        rrScore = 0
        rrEarnedFire = 0
        rrEarnedPineapple = 0
        rrEarnedStars = 0
        rrPlayerPath = []
        rrTargetPoints = []
        rrIsFinished = false
        rrDidWin = false
        rrMessage = "Trace the glowing path"
        rrHasSaved = false
        rrBuildLevel(in: size)
    }

    private func rrStartTimer() {
        rrTimerTask = Task {
            while !Task.isCancelled && rrIsPlaying && rrTimeLeft > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled || !rrIsPlaying { break }
                rrTimeLeft -= 1

                if rrTimeLeft <= 0 {
                    rrMessage = "Time is over"
                    rrDidWin = false
                    rrFinishGame()
                }
            }
        }
    }

    private func rrFinishGame() {
        rrStop()
        rrIsFinished = true
    }

    private func rrEvaluatePath() -> Int {
        guard rrPlayerPath.count > 8, rrTargetPoints.count > 1 else { return 0 }

        let samples = rrSamplePoints(from: rrPlayerPath, count: rrTargetPoints.count)
        guard samples.count == rrTargetPoints.count else { return 0 }

        var totalDistance: CGFloat = 0

        for index in 0..<rrTargetPoints.count {
            totalDistance += rrDistance(from: samples[index], to: rrTargetPoints[index])
        }

        let averageDistance = totalDistance / CGFloat(rrTargetPoints.count)

        switch averageDistance {
        case 0..<18: return 100
        case 18..<28: return 88
        case 28..<38: return 76
        case 38..<50: return 64
        case 50..<65: return 52
        case 65..<82: return 40
        default: return 20
        }
    }

    private func rrSamplePoints(from path: [CGPoint], count: Int) -> [CGPoint] {
        guard path.count >= count, count > 1 else { return path }

        var result: [CGPoint] = []

        for index in 0..<count {
            let progress = CGFloat(index) / CGFloat(count - 1)
            let pathIndex = Int(progress * CGFloat(path.count - 1))
            result.append(path[pathIndex])
        }

        return result
    }

    private func rrDistance(from a: CGPoint, to b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }
}

@MainActor
final class RRSettingsManager: ObservableObject {
    private let rrHapticsKey = "RR_settings_hapticsJ835"
    private let rrSoundKey = "RR_settings_soundJ835"
    private let rrHintsKey = "RR_settings_hintsJ835"
    private let rrMap3DKey = "RR_settings_map3dJ835"

    @Published var rrHapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(rrHapticsEnabled, forKey: rrHapticsKey) }
    }

    @Published var rrSoundEnabled: Bool {
        didSet { UserDefaults.standard.set(rrSoundEnabled, forKey: rrSoundKey) }
    }

    @Published var rrHintsEnabled: Bool {
        didSet { UserDefaults.standard.set(rrHintsEnabled, forKey: rrHintsKey) }
    }

    @Published var rrMap3DEnabled: Bool {
        didSet { UserDefaults.standard.set(rrMap3DEnabled, forKey: rrMap3DKey) }
    }

    init() {
        let rrDefaults = UserDefaults.standard

        if rrDefaults.object(forKey: rrHapticsKey) == nil {
            rrDefaults.set(true, forKey: rrHapticsKey)
        }

        if rrDefaults.object(forKey: rrSoundKey) == nil {
            rrDefaults.set(true, forKey: rrSoundKey)
        }

        if rrDefaults.object(forKey: rrHintsKey) == nil {
            rrDefaults.set(true, forKey: rrHintsKey)
        }

        if rrDefaults.object(forKey: rrMap3DKey) == nil {
            rrDefaults.set(false, forKey: rrMap3DKey)
        }

        self.rrHapticsEnabled = rrDefaults.bool(forKey: rrHapticsKey)
        self.rrSoundEnabled = rrDefaults.bool(forKey: rrSoundKey)
        self.rrHintsEnabled = rrDefaults.bool(forKey: rrHintsKey)
        self.rrMap3DEnabled = rrDefaults.bool(forKey: rrMap3DKey)
    }

    func rrResetSettings() {
        rrHapticsEnabled = true
        rrSoundEnabled = true
        rrHintsEnabled = true
        rrMap3DEnabled = false
    }

    func rrResetStoryProgress() {
        UserDefaults.standard.removeObject(forKey: "RR_story_currentNodeJ835")
        UserDefaults.standard.set(false, forKey: "RR_story_completedJ835")
    }
}
