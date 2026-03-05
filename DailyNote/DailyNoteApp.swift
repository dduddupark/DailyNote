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
    // Application 클래스처럼 초기화(Firebase 등) 역할
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate 
    //// 전역 싱글톤 객체
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
