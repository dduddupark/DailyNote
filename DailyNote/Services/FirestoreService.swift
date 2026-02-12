import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private var entriesCollection: CollectionReference? {
        guard let uid = AuthService.shared.userId else { return nil }
        return db.collection("users").document(uid).collection("entries")
    }
    
    // 1. 저장: 객체 통째로 전달
    func saveEntry(_ entry: NoteEntry) async throws {
        guard let collection = entriesCollection else { throw AuthError.notAuthenticated }
        try await collection.document(entry.id).setData(from: entry)
    }
    
    // 삭제
    func deleteEntry(dateId: String) async throws {
        guard let collection = entriesCollection else { throw AuthError.notAuthenticated }
        try await collection.document(dateId).delete()
    }

    // 단일 조회
    func fetchTodayEntry(dateId: String) async throws -> NoteEntry? {
        guard let collection = entriesCollection else { throw AuthError.notAuthenticated }
        let snapshot = try await collection.document(dateId).getDocument()
        if !snapshot.exists { return nil }
        return try snapshot.data(as: NoteEntry.self)
    }
    
    // 리스트 조회
    func fetchEntries() async throws -> [NoteEntry] {
        guard let collection = entriesCollection else { throw AuthError.notAuthenticated }
        let snapshot = try await collection.order(by: "id", descending: true).getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: NoteEntry.self)
        }
    }
}
