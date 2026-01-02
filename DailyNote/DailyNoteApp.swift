//
//  DailyNoteApp.swift
//  DailyNote
//
//  Created by yanadoo on 1/2/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

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
    @State private var showHome: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if showHome {
                    HomeView()
                } else {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.6)) {
                            showHome = true
                        }
                    }
                    .toolbar(.hidden, for: .navigationBar)
                }
            }
        }
    }
}
