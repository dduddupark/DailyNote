import Foundation
import FirebaseAuth

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthReady: Bool = false
    
    static let shared = AuthService()
    
    private init() {
        self.currentUser = Auth.auth().currentUser
        if self.currentUser != nil {
            print("userId = \(String(describing: self.currentUser?.uid))")
            self.isAuthReady = true
        }
    }
    
    func signInAnonymously(completion: ((Bool) -> Void)? = nil) {
        if let _ = Auth.auth().currentUser {
            self.isAuthReady = true
            completion?(true)
            return
        }
        
        Auth.auth().signInAnonymously { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error signing in anonymously: \(error.localizedDescription)")
                    completion?(false)
                    return
                }
                self.currentUser = authResult?.user
                print("userId2 = \(String(describing: self.currentUser?.uid))")
                self.isAuthReady = true
                completion?(true)
            }
        }
    }
    
    var userId: String? {
        return currentUser?.uid
    }
}
