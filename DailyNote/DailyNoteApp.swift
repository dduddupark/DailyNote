import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct DailyNoteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthService.shared
    @State private var isSplashFinished: Bool = false
    @Environment(\.scenePhase) private var scenePhase // Monitor app state
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if !isSplashFinished {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.6)) {
                            isSplashFinished = true
                        }
                    }
                    .toolbar(.hidden, for: .navigationBar)
                } else {
                    // Check authentication status
                    if authService.isAuthReady && authService.currentUser != nil {
                        HomeView()
                    } else {
                        LoginView()
                    }
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    NotificationService.shared.requestPermission()
                }
            }
        }
    }
}
