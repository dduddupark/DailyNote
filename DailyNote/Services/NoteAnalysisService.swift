import Foundation
import NaturalLanguage

class NoteAnalysisService {
    static let shared = NoteAnalysisService()
    
    private init() {}
    
    func analyze(text: String) -> (emotion: String, tags: [String]) {
        let emotion = analyzeEmotion(text: text)
        let tags = analyzeTags(text: text)
        return (emotion, tags)
    }
    
    private func analyzeEmotion(text: String) -> String {
        // 1. Keyword Overrides for better accuracy with short texts
        let positiveKeywords = ["행복", "기뻐", "좋아", "신나", "최고", "감사", "사랑", "즐거", "뿌듯", "성공", "좋았", "멋진", "훌륭"]
        let negativeKeywords = ["우울", "슬퍼", "화나", "짜증", "힘들", "실망", "걱정", "불안", "아파", "속상", "망했", "최악"]
        let neutralKeywords = ["그냥", "보통", "무난", "평범"]
        
        // Simple check
        var posCount = 0
        var negCount = 0
        
        for k in positiveKeywords { if text.contains(k) { posCount += 1 } }
        for k in negativeKeywords { if text.contains(k) { negCount += 1 } }
        
        if posCount > negCount { return "😊" }
        if negCount > posCount { return "😢" }
        
        // 2. Fallback to NLTagger
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        if let scoreStr = sentiment?.rawValue, let score = Double(scoreStr) {
            print("AI/DEBUG: Sentiment Score: \(score)")
            if score > 0.4 { return "😊" } // Adjusted threshold
            if score > 0.1 { return "🙂" }
            if score < -0.4 { return "😢" }
            if score < -0.1 { return "😟" }
        }
        
        return "😐" // Neutral
    }
    
    private func analyzeTags(text: String) -> [String] {
        var tags: [String] = []
        let lowerText = text.lowercased()
        
        // Simple keyword matching for now
        // Pre-process text to handle overlapping keywords
        // If "산책" is present, we temporarily remove it to avoid matching "책"
        var textForTagging = lowerText
        if lowerText.contains("산책") || lowerText.contains("walk") {
            tags.append("tag_walk")
            textForTagging = textForTagging.replacingOccurrences(of: "산책", with: "")
                           .replacingOccurrences(of: "walk", with: "")
        }

        // Keywords mapping
        let keywords: [String: String] = [
            "운동": "tag_exercise",
            "헬스": "tag_exercise",
            "러닝": "tag_running",
            "독서": "tag_reading",
            "책": "tag_reading", // Now safe from "산책"
            "공부": "tag_study",
            "스터디": "tag_study",
            "영화": "tag_movie",
            "친구": "tag_meeting",
            "회식": "tag_dining",
            "회의": "tag_work",
            "업무": "tag_work",
            "출장": "tag_businesstrip",
            "여행": "tag_travel",
            "커피": "tag_cafe",
            "카페": "tag_cafe",
            
            // English overrides (for tests / future scaling)
            "exercise": "tag_exercise",
            "health": "tag_exercise",
            "running": "tag_running",
            "reading": "tag_reading",
            "book": "tag_reading",
            "study": "tag_study",
            "movie": "tag_movie",
            "meeting": "tag_meeting",
            "work": "tag_work",
            "travel": "tag_travel",
            "cafe": "tag_cafe",
            "food": "tag_dining"
        ]
        
        for (keyword, tag) in keywords {
            if textForTagging.contains(keyword) {
                if !tags.contains(tag) {
                    tags.append(tag)
                }
            }
        }
        
        // Simple heuristic for future planning
        if lowerText.contains("내일") || lowerText.contains("계획") || lowerText.contains("tomorrow") || lowerText.contains("plan") {
            tags.append("tag_plan")
        }
        
        return tags
    }
}
