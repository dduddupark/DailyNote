import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void
    
    @StateObject private var authService = AuthService.shared
    @State private var isTimeFinished = false
    @State private var opacity = 0.5
    @State private var size = 0.8
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()
            
            VStack {
                VStack(spacing: 20) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("app_name")
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundColor(.primary.opacity(0.80))
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
        }
        .onAppear {
            // 1. 최소 1초 대기
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.isTimeFinished = true
                self.checkReadyToMove()
            }
            
            // 2. 익명 로그인 시도
            authService.signInAnonymously()
        }
        .onChange(of: authService.isAuthReady) { ready in
            if ready {
                self.checkReadyToMove()
            }
        }
    }
    
    private func checkReadyToMove() {
        if isTimeFinished && authService.isAuthReady {
            onFinished()
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
