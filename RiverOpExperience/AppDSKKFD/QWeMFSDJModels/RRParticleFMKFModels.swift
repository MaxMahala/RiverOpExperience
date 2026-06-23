import SwiftUI
import CoreLocation

struct RRParticle: Identifiable {
    let id = UUID()
    let rrX: CGFloat
    let rrY: CGFloat
    let rrSize: CGFloat
    let rrOpacity: Double
    let rrBlur: CGFloat
    let rrColor: Color
}

struct RROnboardingPage: Identifiable {
    let id = UUID()
    let rrIcon: String
    let rrTitle: String
    let rrSubtitle: String
    let rrDescription: String
    let rrAccentColor: Color
}

struct RROnboardingParticle: Identifiable {
    let id = UUID()
    let rrX: CGFloat
    let rrY: CGFloat
    let rrSize: CGFloat
    let rrOpacity: Double
    let rrBlur: CGFloat
    let rrColor: Color
}

enum RRScreenDestination: String, Identifiable {
    case claimFruits
    case beachRunner
    case rollDice
    case drawTheWay
    case awards
    case activityMap
    case addActivity
    case storyActivity
    case settings

    var id: String { rawValue }
}

struct RRGameCard: Identifiable {
    let id = UUID()
    let rrTitle: String
    let rrSubtitle: String
    let rrIcon: String
    let rrDestination: RRScreenDestination
    let rrGradientColors: [Color]
}

struct RRClaimFruitItem: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let rewardType: RRClaimRewardType
    let xPosition: CGFloat
    var yPosition: CGFloat
    let size: CGFloat
    let speed: CGFloat
    let rotation: Double
}

enum RRClaimRewardType: Equatable {
    case fire(Int)
    case pineapple(Int)
    case star(Int)
    
    var points: Int {
        switch self {
        case .fire(let value): return value * 8
        case .pineapple(let value): return value * 12
        case .star(let value): return value * 20
        }
    }
}

struct RRClaimFruitConfig {
    let imageName: String
    let rewardType: RRClaimRewardType
    let spawnWeight: Int
}

struct RRBeachLaneItem: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let lane: Int
    var yPosition: CGFloat
    let size: CGFloat
    let isObstacle: Bool
    let fireReward: Int
    let pineappleReward: Int
    let starReward: Int
    let scoreReward: Int
}

enum RRBeachRunnerLane: Int, CaseIterable {
    case left = 0
    case center = 1
    case right = 2
}

enum RRAwardRarity: String {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legend = "Legend"

    var rrColor: Color {
        switch self {
        case .common: return RRColor.foamMist
        case .rare: return RRColor.seaGreen
        case .epic: return RRColor.boltGold
        case .legend: return Color(red: 1.0, green: 0.55, blue: 0.25)
        }
    }

    var rrGlow: Color {
        rrColor.opacity(0.28)
    }
}

struct RRAwardItem: Identifiable, Equatable {
    let id = UUID()
    let rrTitle: String
    let rrSubtitle: String
    let rrDescription: String
    let rrIcon: String
    let rrRarity: RRAwardRarity
    let rrProgressValue: Int
    let rrProgressTarget: Int
    let rrUnlocked: Bool
    let rrUnlockedText: String
}

struct RRMilestoneStep: Identifiable {
    let id = UUID()
    let rrTitle: String
    let rrValueText: String
    let rrReached: Bool
    let rrIcon: String
    let rrAccent: Color
}

enum RRActivityKind: String, Codable, CaseIterable {
    case run = "Run"
    case work = "Work"
    case read = "Read"
    case walk = "Walk"
    case relax = "Relax"
    case custom = "Custom"

    var rrTitle: String { rawValue }

    var rrSystemIcon: String {
        switch self {
        case .run: return "figure.run"
        case .work: return "briefcase.fill"
        case .read: return "book.fill"
        case .walk: return "figure.walk"
        case .relax: return "leaf.fill"
        case .custom: return "sparkles"
        }
    }

    var rrAccent: Color {
        switch self {
        case .run: return RRColor.boltGold
        case .work: return RRColor.seaGreen
        case .read: return RRColor.sandWarm
        case .walk: return RRColor.foamWhite
        case .relax: return Color(red: 0.45, green: 0.82, blue: 0.67)
        case .custom: return Color(red: 0.62, green: 0.52, blue: 0.95)
        }
    }
}

struct RRActivityPinModel: Identifiable, Codable, Equatable {
    let id: UUID
    let rrTitle: String
    let rrNote: String
    let rrPlaceName: String
    let rrKind: RRActivityKind
    let rrDate: Date
    let rrLatitude: Double
    let rrLongitude: Double
    let rrImageData: Data?

    var rrCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: rrLatitude, longitude: rrLongitude)
    }
}

enum RRStoryRewardType: Equatable {
    case fire(Int)
    case pineapple(Int)
    case stars(Int)
    case mixed(fire: Int, pineapple: Int, stars: Int)
}

struct RRStoryChoiceModel: Identifiable, Equatable {
    let id = UUID()
    let rrTitle: String
    let rrSubtitle: String
    let rrReward: RRStoryRewardType
    let rrTrustDelta: Int
    let rrCourageDelta: Int
    let rrWisdomDelta: Int
    let rrNextNodeID: String?
}

struct RRStoryNodeModel: Identifiable, Equatable {
    let id: String
    let rrTitle: String
    let rrSubtitle: String
    let rrBody: String
    let rrImage: String
    let rrThemeColor: Color
    let rrChoices: [RRStoryChoiceModel]
    let rrIsEnding: Bool
}

struct RRStoryLogEntry: Identifiable, Equatable {
    let id = UUID()
    let rrTitle: String
    let rrEffectText: String
}

enum RRStoryDataSource {
    static let rrNodes: [RRStoryNodeModel] = [
        RRStoryNodeModel(
            id: "shore",
            rrTitle: "The Locked Shore",
            rrSubtitle: "Chapter 1",
            rrBody: "A golden padlock rises from the sand. The tide whispers that only a clever runner may open the island path.",
            rrImage: "closed-golden-padlock",
            rrThemeColor: RRColor.boltGold,
            rrChoices: [
                RRStoryChoiceModel(
                    rrTitle: "Touch the lock carefully",
                    rrSubtitle: "Slow, safe, observant",
                    rrReward: .stars(1),
                    rrTrustDelta: 2,
                    rrCourageDelta: 0,
                    rrWisdomDelta: 2,
                    rrNextNodeID: "embers"
                ),
                RRStoryChoiceModel(
                    rrTitle: "Break through the seal",
                    rrSubtitle: "Fast, risky, bold",
                    rrReward: .fire(2),
                    rrTrustDelta: 0,
                    rrCourageDelta: 3,
                    rrWisdomDelta: -1,
                    rrNextNodeID: "embers"
                )
            ],
            rrIsEnding: false
        ),

        RRStoryNodeModel(
            id: "embers",
            rrTitle: "Trail of Embers",
            rrSubtitle: "Chapter 2",
            rrBody: "Small fire spirits race over the rocks. One path gives speed. The other gives clues about the island treasure.",
            rrImage: "fireStats",
            rrThemeColor: Color(red: 1.0, green: 0.45, blue: 0.2),
            rrChoices: [
                RRStoryChoiceModel(
                    rrTitle: "Follow the fast sparks",
                    rrSubtitle: "Gain speed and pressure",
                    rrReward: .fire(3),
                    rrTrustDelta: 0,
                    rrCourageDelta: 2,
                    rrWisdomDelta: 0,
                    rrNextNodeID: "orchard"
                ),
                RRStoryChoiceModel(
                    rrTitle: "Study the glowing marks",
                    rrSubtitle: "Gain knowledge and pattern hints",
                    rrReward: .mixed(fire: 1, pineapple: 0, stars: 1),
                    rrTrustDelta: 1,
                    rrCourageDelta: 0,
                    rrWisdomDelta: 3,
                    rrNextNodeID: "orchard"
                )
            ],
            rrIsEnding: false
        ),

        RRStoryNodeModel(
            id: "orchard",
            rrTitle: "Pineapple Vault",
            rrSubtitle: "Chapter 3",
            rrBody: "A hidden orchard opens under moonlight. One vault is full of fruit. Another hides an old route map carved into stone.",
            rrImage: "pineappleStats",
            rrThemeColor: RRColor.sandWarm,
            rrChoices: [
                RRStoryChoiceModel(
                    rrTitle: "Take the fruit reserve",
                    rrSubtitle: "More treasure, less mystery",
                    rrReward: .pineapple(3),
                    rrTrustDelta: 2,
                    rrCourageDelta: 0,
                    rrWisdomDelta: 0,
                    rrNextNodeID: "gate"
                ),
                RRStoryChoiceModel(
                    rrTitle: "Read the stone route",
                    rrSubtitle: "Less treasure, better final path",
                    rrReward: .mixed(fire: 0, pineapple: 1, stars: 1),
                    rrTrustDelta: 0,
                    rrCourageDelta: 0,
                    rrWisdomDelta: 2,
                    rrNextNodeID: "gate"
                )
            ],
            rrIsEnding: false
        ),

        RRStoryNodeModel(
            id: "gate",
            rrTitle: "Gate of the Three Signs",
            rrSubtitle: "Final Choice",
            rrBody: "The last gate reacts to who you became on the island. Courage opens force. Wisdom opens truth. Balance opens the treasure chamber.",
            rrImage: "3d-star-icon",
            rrThemeColor: RRColor.boltSunrise,
            rrChoices: [
                RRStoryChoiceModel(
                    rrTitle: "Open with courage",
                    rrSubtitle: "For bold players",
                    rrReward: .stars(1),
                    rrTrustDelta: 0,
                    rrCourageDelta: 1,
                    rrWisdomDelta: 0,
                    rrNextNodeID: "ending"
                ),
                RRStoryChoiceModel(
                    rrTitle: "Open with wisdom",
                    rrSubtitle: "For careful players",
                    rrReward: .stars(1),
                    rrTrustDelta: 0,
                    rrCourageDelta: 0,
                    rrWisdomDelta: 1,
                    rrNextNodeID: "ending"
                ),
                RRStoryChoiceModel(
                    rrTitle: "Open with balance",
                    rrSubtitle: "For adaptive players",
                    rrReward: .mixed(fire: 1, pineapple: 1, stars: 1),
                    rrTrustDelta: 1,
                    rrCourageDelta: 1,
                    rrWisdomDelta: 1,
                    rrNextNodeID: "ending"
                )
            ],
            rrIsEnding: false
        )
    ]

    static func rrNode(id: String) -> RRStoryNodeModel? {
        rrNodes.first(where: { $0.id == id })
    }
}

enum RRRootStage {
    case loading
    case onboarding
    case main
}
