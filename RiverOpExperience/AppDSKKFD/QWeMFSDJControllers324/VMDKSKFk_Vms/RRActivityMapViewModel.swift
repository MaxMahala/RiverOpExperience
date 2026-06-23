import SwiftUI
import MapKit
import Combine
import PhotosUI

@MainActor
final class RRActivityMapViewModel: ObservableObject {
    private let rrActivitiesKey = "RR_activityMapItemsJ835"

    @Published var rrRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.8397, longitude: 24.0297),
        span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
    )

    @Published var rrActivities: [RRActivityPinModel] = []
    @Published var rrSelectedActivity: RRActivityPinModel? = nil

    @Published var rrShowCreateSheet: Bool = false
    @Published var rrShowImageSourceDialog: Bool = false
    @Published var rrShowCameraPicker: Bool = false
    @Published var rrShowGalleryPicker: Bool = false
    @Published var rrIs3DEnabled: Bool = false

    @Published var rrDraftTitle: String = ""
    @Published var rrDraftNote: String = ""
    @Published var rrDraftPlaceName: String = ""
    @Published var rrDraftKind: RRActivityKind = .run
    @Published var rrDraftImage: UIImage? = nil
    @Published var rrDraftPickerItem: PhotosPickerItem? = nil

    @Published var rrShowCameraDeniedOverlay: Bool = false

    init() {
        rrLoadActivities()
    }

    var rrCenterCoordinate: CLLocationCoordinate2D {
        rrRegion.center
    }

    var rrTotalActivitiesText: String {
        "\(rrActivities.count) saved"
    }

    var rrLatestActivityTitle: String {
        rrActivities.sorted(by: { $0.rrDate > $1.rrDate }).first?.rrTitle ?? "No activities yet"
    }

    func rrOpenCreate() {
        rrResetDraft()
        rrShowCreateSheet = true
    }

    func rrSaveDraftActivity() {
        let rrTrimmedTitle = rrDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let rrTrimmedPlace = rrDraftPlaceName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !rrTrimmedTitle.isEmpty else { return }

        let rrItem = RRActivityPinModel(
            id: UUID(),
            rrTitle: rrTrimmedTitle,
            rrNote: rrDraftNote.trimmingCharacters(in: .whitespacesAndNewlines),
            rrPlaceName: rrTrimmedPlace.isEmpty ? "Pinned Place" : rrTrimmedPlace,
            rrKind: rrDraftKind,
            rrDate: Date(),
            rrLatitude: rrCenterCoordinate.latitude,
            rrLongitude: rrCenterCoordinate.longitude,
            rrImageData: rrDraftImage?.jpegData(compressionQuality: 0.82)
        )

        rrActivities.insert(rrItem, at: 0)
        rrPersistActivities()
        rrShowCreateSheet = false
        rrSelectedActivity = rrItem
    }

    func rrDeleteActivity(_ activity: RRActivityPinModel) {
        rrActivities.removeAll { $0.id == activity.id }
        rrPersistActivities()
        if rrSelectedActivity?.id == activity.id {
            rrSelectedActivity = nil
        }
    }

    func rrApply3DIfNeeded(to mapView: MKMapView) {
        let rrCamera = MKMapCamera()
        rrCamera.centerCoordinate = rrRegion.center
        rrCamera.heading = 0
        rrCamera.pitch = rrIs3DEnabled ? 58 : 0
        rrCamera.altitude = rrIs3DEnabled ? 900 : 2200
        mapView.setCamera(rrCamera, animated: true)
    }

    func rrLoadPickedGalleryItem() {
        guard let rrDraftPickerItem else { return }

        Task {
            if let rrData = try? await rrDraftPickerItem.loadTransferable(type: Data.self),
               let rrImage = UIImage(data: rrData) {
                await MainActor.run {
                    self.rrDraftImage = rrImage
                }
            }
        }
    }

    func rrHandleCameraRequest() {
        let rrStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch rrStatus {
        case .authorized:
            rrShowCameraPicker = true

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.rrShowCameraPicker = true
                    } else {
                        self.rrShowCameraDeniedOverlay = true
                    }
                }
            }

        case .denied, .restricted:
            rrShowCameraDeniedOverlay = true

        @unknown default:
            rrShowCameraDeniedOverlay = true
        }
    }

    func rrOpenAppSettings() {
        guard let rrURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(rrURL) else { return }
        UIApplication.shared.open(rrURL)
    }

    private func rrResetDraft() {
        rrDraftTitle = ""
        rrDraftNote = ""
        rrDraftPlaceName = ""
        rrDraftKind = .run
        rrDraftImage = nil
        rrDraftPickerItem = nil
        rrShowCameraDeniedOverlay = false
    }

    private func rrPersistActivities() {
        guard let rrData = try? JSONEncoder().encode(rrActivities) else { return }
        UserDefaults.standard.set(rrData, forKey: rrActivitiesKey)
    }

    private func rrLoadActivities() {
        guard let rrData = UserDefaults.standard.data(forKey: rrActivitiesKey),
              let rrDecoded = try? JSONDecoder().decode([RRActivityPinModel].self, from: rrData) else {
            rrActivities = []
            return
        }
        rrActivities = rrDecoded
    }
}

@MainActor
final class RRActivityMapViewModel2: ObservableObject {
    private let rrActivitiesKey = "RR_activityMapItemsJ835"

    @Published var rrRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.8397, longitude: 24.0297),
        span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
    )

    @Published var rrActivities: [RRActivityPinModel] = []
    @Published var rrSelectedActivity: RRActivityPinModel? = nil

    @Published var rrShowCreateSheet: Bool = false
    @Published var rrShowImageSourceDialog: Bool = false
    @Published var rrShowCameraPicker: Bool = false
    @Published var rrShowGalleryPicker: Bool = false
    @Published var rrIs3DEnabled: Bool = false

    @Published var rrDraftTitle: String = ""
    @Published var rrDraftNote: String = ""
    @Published var rrDraftPlaceName: String = ""
    @Published var rrDraftKind: RRActivityKind = .run
    @Published var rrDraftImage: UIImage? = nil
    @Published var rrDraftPickerItem: PhotosPickerItem? = nil
    @Published var rrShowSettingsAlert = false
    @Published var rrDeniedKind: RRMediaKind = .camera

    var rrDeniedMessage: String {
        rrDeniedKind == .camera
            ? "Camera access is off. Enable it in Settings to take a photo."
            : "Photo access is off. Enable it in Settings to attach an image."
    }
    
    init() {
        rrLoadActivities()
    }

    var rrCenterCoordinate: CLLocationCoordinate2D {
        rrRegion.center
    }

    var rrCanSaveDraft: Bool {
        !rrDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func rrPrepareNewDraft() {
        rrDraftTitle = ""
        rrDraftNote = ""
        rrDraftPlaceName = ""
        rrDraftKind = .run
        rrDraftImage = nil
        rrDraftPickerItem = nil
    }

    func rrSaveDraftActivity() {
        let rrTrimmedTitle = rrDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let rrTrimmedPlace = rrDraftPlaceName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !rrTrimmedTitle.isEmpty else { return }

        let rrItem = RRActivityPinModel(
            id: UUID(),
            rrTitle: rrTrimmedTitle,
            rrNote: rrDraftNote.trimmingCharacters(in: .whitespacesAndNewlines),
            rrPlaceName: rrTrimmedPlace.isEmpty ? "Pinned Place" : rrTrimmedPlace,
            rrKind: rrDraftKind,
            rrDate: Date(),
            rrLatitude: rrCenterCoordinate.latitude,
            rrLongitude: rrCenterCoordinate.longitude,
            rrImageData: rrDraftImage?.jpegData(compressionQuality: 0.82)
        )

        rrActivities.insert(rrItem, at: 0)
        rrPersistActivities()
        rrSelectedActivity = rrItem
    }

    func rrLoadPickedGalleryItem() {
        guard let rrDraftPickerItem else { return }

        Task {
            if let rrData = try? await rrDraftPickerItem.loadTransferable(type: Data.self),
               let rrImage = UIImage(data: rrData) {
                await MainActor.run {
                    self.rrDraftImage = rrImage
                }
            }
        }
    }

    private func rrPersistActivities() {
        guard let rrData = try? JSONEncoder().encode(rrActivities) else { return }
        UserDefaults.standard.set(rrData, forKey: rrActivitiesKey)
    }

    private func rrLoadActivities() {
        guard let rrData = UserDefaults.standard.data(forKey: rrActivitiesKey),
              let rrDecoded = try? JSONDecoder().decode([RRActivityPinModel].self, from: rrData) else {
            rrActivities = []
            return
        }
        rrActivities = rrDecoded
    }
}

@MainActor
final class RRStoryGameViewModel: ObservableObject {
    private let rrCurrentNodeKey = "RR_story_currentNodeJ835"
    private let rrCompletedKey = "RR_story_completedJ835"

    @Published var rrCurrentNodeID: String = "shore"
    @Published var rrTrust: Int = 0
    @Published var rrCourage: Int = 0
    @Published var rrWisdom: Int = 0

    @Published var rrFireEarned: Int = 0
    @Published var rrPineappleEarned: Int = 0
    @Published var rrStarsEarned: Int = 0

    @Published var rrStoryLogs: [RRStoryLogEntry] = []
    @Published var rrShowEnding: Bool = false
    @Published var rrEndingTitle: String = ""
    @Published var rrEndingBody: String = ""
    @Published var rrCompletionProgress: Double = 0
    @Published var rrHasCompletedStory: Bool = false

    var rrCurrentNode: RRStoryNodeModel {
        RRStoryDataSource.rrNode(id: rrCurrentNodeID) ?? RRStoryDataSource.rrNodes[0]
    }

    init() {
        rrLoadProgress()
        rrUpdateProgress()
    }

    func rrSelectChoice(_ choice: RRStoryChoiceModel, rrStats: RRStatsModel) {
        rrTrust += choice.rrTrustDelta
        rrCourage += choice.rrCourageDelta
        rrWisdom += choice.rrWisdomDelta

        var rrFireReward = 0
        var rrPineappleReward = 0
        var rrStarsReward = 0

        switch choice.rrReward {
        case .fire(let value):
            rrFireReward = value
        case .pineapple(let value):
            rrPineappleReward = value
        case .stars(let value):
            rrStarsReward = value
        case .mixed(let fire, let pineapple, let stars):
            rrFireReward = fire
            rrPineappleReward = pineapple
            rrStarsReward = stars
        }

        rrFireEarned += rrFireReward
        rrPineappleEarned += rrPineappleReward
        rrStarsEarned += rrStarsReward

        rrStats.rrRecordGameWin(
            fire: rrFireReward,
            pineapple: rrPineappleReward,
            score: rrStoryScoreForChoice(choice),
            stars: rrStarsReward
        )

        let rrEffectText = "+\(rrFireReward) fire  +\(rrPineappleReward) pineapple  +\(rrStarsReward) stars"
        rrStoryLogs.insert(
            RRStoryLogEntry(
                rrTitle: choice.rrTitle,
                rrEffectText: rrEffectText
            ),
            at: 0
        )

        if choice.rrNextNodeID == "ending" {
            rrResolveEnding()
        } else if let rrNextNodeID = choice.rrNextNodeID {
            rrCurrentNodeID = rrNextNodeID
            rrPersistProgress()
            rrUpdateProgress()
        }
    }

    func rrRestartStory() {
        rrCurrentNodeID = "shore"
        rrTrust = 0
        rrCourage = 0
        rrWisdom = 0
        rrFireEarned = 0
        rrPineappleEarned = 0
        rrStarsEarned = 0
        rrStoryLogs = []
        rrShowEnding = false
        rrEndingTitle = ""
        rrEndingBody = ""
        rrHasCompletedStory = false
        UserDefaults.standard.set(false, forKey: rrCompletedKey)
        rrPersistProgress()
        rrUpdateProgress()
    }

    private func rrStoryScoreForChoice(_ choice: RRStoryChoiceModel) -> Int {
        let rrRewardScore: Int
        switch choice.rrReward {
        case .fire(let value):
            rrRewardScore = value * 10
        case .pineapple(let value):
            rrRewardScore = value * 14
        case .stars(let value):
            rrRewardScore = value * 22
        case .mixed(let fire, let pineapple, let stars):
            rrRewardScore = fire * 10 + pineapple * 14 + stars * 22
        }

        return rrRewardScore + max(0, choice.rrTrustDelta + choice.rrCourageDelta + choice.rrWisdomDelta) * 4
    }

    private func rrResolveEnding() {
        let rrBalanceGap = max(abs(rrTrust - rrCourage), abs(rrCourage - rrWisdom))

        if rrBalanceGap <= 1 && rrTrust >= 2 && rrWisdom >= 2 && rrCourage >= 2 {
            rrEndingTitle = "Golden Tide Ending"
            rrEndingBody = "You opened the chamber with balance. The island accepted your courage, wisdom, and calm. This is the rarest route."
            rrStarsEarned += 3
        } else if rrCourage > rrWisdom && rrCourage > rrTrust {
            rrEndingTitle = "Flame Runner Ending"
            rrEndingBody = "You broke through the final gate with pure force. The island answered with fire and speed."
            rrFireEarned += 4
        } else if rrWisdom >= rrCourage && rrWisdom >= rrTrust {
            rrEndingTitle = "Oracle Path Ending"
            rrEndingBody = "You solved the island through insight. The treasure opened to the player who watched, learned, and waited."
            rrStarsEarned += 2
        } else {
            rrEndingTitle = "Treasure Keeper Ending"
            rrEndingBody = "You earned the trust of the island and carried its reserves home. A stable ending with strong treasure rewards."
            rrPineappleEarned += 3
        }

        rrHasCompletedStory = true
        rrShowEnding = true
        UserDefaults.standard.set(true, forKey: rrCompletedKey)
        rrCurrentNodeID = "shore"
        rrUpdateProgress()
        rrPersistProgress()
    }

    private func rrUpdateProgress() {
        let rrIndex = RRStoryDataSource.rrNodes.firstIndex(where: { $0.id == rrCurrentNodeID }) ?? 0
        rrCompletionProgress = Double(rrIndex) / Double(max(RRStoryDataSource.rrNodes.count, 1))
        rrHasCompletedStory = UserDefaults.standard.bool(forKey: rrCompletedKey)
    }

    private func rrPersistProgress() {
        UserDefaults.standard.set(rrCurrentNodeID, forKey: rrCurrentNodeKey)
    }

    private func rrLoadProgress() {
        rrCurrentNodeID = UserDefaults.standard.string(forKey: rrCurrentNodeKey) ?? "shore"
        rrHasCompletedStory = UserDefaults.standard.bool(forKey: rrCompletedKey)
    }
}
