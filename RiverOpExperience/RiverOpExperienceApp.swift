import SwiftUI

@main
struct RiverOpExperienceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RRRootNavigationView()
        }
    }
}

struct RRRootNavigationView: View {
    @StateObject private var rrRootController = RRRootNavigationController()

    var body: some View {
        ZStack {
            Group {
                switch rrRootController.rrCurrentStage {
                case .loading:
                    LoadingView()

                case .onboarding:
                    OnboardingView {
                        rrRootController.rrCompleteOnboarding()
                    }

                case .main:
                    MainJ835KDI()
                }
            }
        }
        .onAppear {
            rrRootController.rrStartFlow()
        }
    }
}
