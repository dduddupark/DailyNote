import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore // For FirebaseApp

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthReady: Bool = false
    @Published var shouldShowLoginToast: Bool = false
    
    static let shared = AuthService()
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    private init() {
        // Listen for authentication state changes
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            print("Auth state changed. User: \(user?.uid ?? "nil")")
            self?.currentUser = user
            self?.isAuthReady = true
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signInAnonymously(completion: ((Bool) -> Void)? = nil) {
        // ... (Keep existing if you want, but listener handles state update)
        // Optimistic check might still be useful for callbacks
        Auth.auth().signInAnonymously { authResult, error in
             DispatchQueue.main.async {
                 if let error = error {
                     print("Error signing in anonymously: \(error.localizedDescription)")
                     completion?(false)
                     return
                 }
                 // Listener will update currentUser
                 completion?(true)
             }
         }
    }
    
    func signInWithGoogle(completion: ((Bool) -> Void)? = nil) {
        // ... (Keep existing GIDSignIn logic)
        // Just ensure completion is called.
        // I'll keep the function body mostly same but rely on listener for state update.
        // However, replace_file_content should replace the whole file or carefully targeted chunks.
        // Let's rewrite the methods to correspond to the plan.
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error {
                print("Error signing in with Google: \(error.localizedDescription)")
                completion?(false)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion?(false)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error signing in to Firebase with Google credential: \(error.localizedDescription)")
                    completion?(false)
                    return
                }
                // Listener handles state
                completion?(true)
            }
        }
    }
    
    func signOut() {
        do {
            GIDSignIn.sharedInstance.signOut() // Sign out from Google
            try Auth.auth().signOut() // Sign out from Firebase
            // Listener should handle the rest (currentUser = nil)
            // But we can force it for immediate UI feedback if needed, 
            // though listener is fast enough.
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    var userId: String? {
        return currentUser?.uid
    }
    
    var isAnonymous: Bool {
        return currentUser?.isAnonymous ?? false
    }
}
