import Foundation
import FirebaseFirestore

struct NoteEntry: Identifiable, Codable {
    var id: String // 날짜 문자열 (YYYY-MM-DD)
    var content: String
    var updatedAt: String // "YYYY-MM-DD" 기반 문자열
    var editCount: Int
    
    // Firestore conversion
    var dictionary: [String: Any] {
        return [
            "id": id,
            "content": content,
            "updatedAt": updatedAt,
            "editCount": editCount
        ]
    }
}
