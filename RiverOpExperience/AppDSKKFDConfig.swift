import SwiftUI
import Combine
import AudioToolbox
import StoreKit

struct AppDSKKFDConfig {
    static let GradientTextRiver9945 = "Rivers"
    static let GradientTextRUNNER9945 = "Experience"
    static let GradientImageRImg9945 = "BoltLogo"
    
    static let GradientImageRprivacy = "https://www.freeprivacypolicy.com/live/95b014b1-4bc2-405b-bc59-3b29d68ab158"
}

enum RRHapticsManager {
    private static let rrHapticsKey = "RR_settings_hapticsJ835"

    private static var rrIsEnabled: Bool {
        UserDefaults.standard.object(forKey: rrHapticsKey) == nil
        ? true
        : UserDefaults.standard.bool(forKey: rrHapticsKey)
    }

    static func rrLight() {
        guard rrIsEnabled else { return }
        let rrGenerator = UIImpactFeedbackGenerator(style: .light)
        rrGenerator.prepare()
        rrGenerator.impactOccurred()
    }

    static func rrMedium() {
        guard rrIsEnabled else { return }
        let rrGenerator = UIImpactFeedbackGenerator(style: .medium)
        rrGenerator.prepare()
        rrGenerator.impactOccurred()
    }

    static func rrHeavy() {
        guard rrIsEnabled else { return }
        let rrGenerator = UIImpactFeedbackGenerator(style: .heavy)
        rrGenerator.prepare()
        rrGenerator.impactOccurred()
    }

    static func rrSoft() {
        guard rrIsEnabled else { return }
        let rrGenerator = UIImpactFeedbackGenerator(style: .soft)
        rrGenerator.prepare()
        rrGenerator.impactOccurred()
    }

    static func rrRigid() {
        guard rrIsEnabled else { return }
        let rrGenerator = UIImpactFeedbackGenerator(style: .rigid)
        rrGenerator.prepare()
        rrGenerator.impactOccurred()
    }

    static func rrSuccess() {
        guard rrIsEnabled else { return }
        let rrGenerator = UINotificationFeedbackGenerator()
        rrGenerator.prepare()
        rrGenerator.notificationOccurred(.success)
    }

    static func rrWarning() {
        guard rrIsEnabled else { return }
        let rrGenerator = UINotificationFeedbackGenerator()
        rrGenerator.prepare()
        rrGenerator.notificationOccurred(.warning)
    }

    static func rrError() {
        guard rrIsEnabled else { return }
        let rrGenerator = UINotificationFeedbackGenerator()
        rrGenerator.prepare()
        rrGenerator.notificationOccurred(.error)
    }

    static func rrSelection() {
        guard rrIsEnabled else { return }
        let rrGenerator = UISelectionFeedbackGenerator()
        rrGenerator.prepare()
        rrGenerator.selectionChanged()
    }
}

enum RRSoundManager {
    private static let rrSoundKey = "RR_settings_soundJ835"

    private static var rrIsEnabled: Bool {
        UserDefaults.standard.object(forKey: rrSoundKey) == nil
        ? true
        : UserDefaults.standard.bool(forKey: rrSoundKey)
    }

    static func rrTap() {
        guard rrIsEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }

    static func rrSuccess() {
        guard rrIsEnabled else { return }
        AudioServicesPlaySystemSound(1025)
    }

    static func rrWarning() {
        guard rrIsEnabled else { return }
        AudioServicesPlaySystemSound(1053)
    }

    static func rrUnlock() {
        guard rrIsEnabled else { return }
        AudioServicesPlaySystemSound(1111)
    }

    static func rrReward() {
        guard rrIsEnabled else { return }
        AudioServicesPlaySystemSound(1020)
    }

    static func rrGameOver() {
        guard rrIsEnabled else { return }
        AudioServicesPlaySystemSound(1006)
    }
}

@MainActor
final class RRHintsManager: ObservableObject {
    private let rrHintsKey = "RR_settings_hintsJ835"
    private let rrShownHintsKey = "RR_shownHintsJ835"

    @Published var rrIsHintsEnabled: Bool
    @Published var rrActiveHintText: String? = nil
    @Published var rrShowHintOverlay: Bool = false

    init() {
        if UserDefaults.standard.object(forKey: rrHintsKey) == nil {
            UserDefaults.standard.set(true, forKey: rrHintsKey)
        }

        self.rrIsHintsEnabled = UserDefaults.standard.bool(forKey: rrHintsKey)
    }

    func rrRefreshEnabledState() {
        rrIsHintsEnabled = UserDefaults.standard.bool(forKey: rrHintsKey)
    }

    func rrShowHintIfNeeded(rrID: String, rrText: String) {
        rrRefreshEnabledState()
        guard rrIsHintsEnabled else { return }

        var rrShownHints = UserDefaults.standard.stringArray(forKey: rrShownHintsKey) ?? []
        guard !rrShownHints.contains(rrID) else { return }

        rrActiveHintText = rrText
        rrShowHintOverlay = true

        rrShownHints.append(rrID)
        UserDefaults.standard.set(rrShownHints, forKey: rrShownHintsKey)
    }

    func rrShowTemporaryHint(rrText: String) {
        rrRefreshEnabledState()
        guard rrIsHintsEnabled else { return }

        rrActiveHintText = rrText
        rrShowHintOverlay = true
    }

    func rrHideHint() {
        rrShowHintOverlay = false
        rrActiveHintText = nil
    }

    func rrResetShownHints() {
        UserDefaults.standard.removeObject(forKey: rrShownHintsKey)
    }
}

enum RRRateAppManager {
    static func rrRequestReview() {
        if let rrScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: rrScene)
        }
    }
}
