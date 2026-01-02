import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private var entriesCollection: CollectionReference? {
        guard let uid = AuthService.shared.userId else { return nil }
        return db.collection("users").document(uid).collection("entries")
    }
    
    func saveEntry(_ entry: NoteEntry, completion: @escaping (Error?) -> Void) {
        guard let collection = entriesCollection else {
            completion(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        collection.document(entry.id).setData(entry.dictionary, merge: true) { error in
            completion(error)
        }
    }
    
    func fetchEntries(completion: @escaping (Result<[NoteEntry], Error>) -> Void) {
        guard let collection = entriesCollection else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        collection.order(by: "id", descending: true).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let entries = snapshot?.documents.compactMap { doc -> NoteEntry? in
                let data = doc.data()
                guard let id = data["id"] as? String,
                      let content = data["content"] as? String,
                      let updatedAt = data["updatedAt"] as? String,
                      let editCount = data["editCount"] as? Int else {
                    return nil
                }
                return NoteEntry(id: id, content: content, updatedAt: updatedAt, editCount: editCount)
            } ?? []
            
            completion(.success(entries))
        }
    }
    
    func fetchTodayEntry(dateId: String, completion: @escaping (NoteEntry?) -> Void) {
        guard let collection = entriesCollection else {
            completion(nil)
            return
        }
        
        collection.document(dateId).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let id = data["id"] as? String,
                  let content = data["content"] as? String,
                  let updatedAt = data["updatedAt"] as? String,
                  let editCount = data["editCount"] as? Int else {
                completion(nil)
                return
            }
            completion(NoteEntry(id: id, content: content, updatedAt: updatedAt, editCount: editCount))
        }
    }
}
