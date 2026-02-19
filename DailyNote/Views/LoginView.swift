import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct LoginView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo/Title
                VStack(spacing: 16) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("app_name")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("app_subtitle")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Buttons Section
                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        // Google Sign In Button
                        Button(action: {
                            isLoading = true
                            errorMessage = nil
                            authService.signInWithGoogle { success in
                                isLoading = false
                                if success {
                                    AuthService.shared.shouldShowLoginToast = true
                                } else {
                                    errorMessage = NSLocalizedString("login_fail_google", comment: "")
                                    showAlert = true
                                }
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.system(size: 20))
                                
                                Text("login_google")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                        }
                        
                        // Guest Login Button
                        Button(action: {
                            isLoading = true
                            errorMessage = nil
                            authService.signInAnonymously { success in
                                isLoading = false
                                if success {
                                    AuthService.shared.shouldShowLoginToast = true
                                } else {
                                    errorMessage = NSLocalizedString("login_fail_guest", comment: "")
                                    showAlert = true
                                }
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 20))
                                
                                Text("login_guest")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                if let errorMessage = errorMessage {
                     // Just empty placeholder if needed, or remove completely if handled by Alert
                     EmptyView()
                }
                
                Spacer()
                    .frame(height: 50)
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("error"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("confirm")))
        }
    }
}

#Preview {
    LoginView()
}
