import Foundation
import FirebaseFirestore

struct NoteEntry: Identifiable, Codable {
    var id: String // 날짜 문자열 (YYYY-MM-DD)
    var title: String
    var content: String
    var updatedAt: String // "YYYY-MM-DD" 기반 문자열
    var editCount: Int
    var emotion: String? = nil // 감정 아이콘 (예: 😊, 😐, 😢)
    var tags: [String]? = nil // 스마트 태그 (예: #운동, #독서)
}
