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
        if lowerText.contains("산책") {
            tags.append("🌿 산책")
            textForTagging = textForTagging.replacingOccurrences(of: "산책", with: "")
        }

        // Keywords mapping
        let keywords: [String: String] = [
            "운동": "🏋️‍♀️ 운동",
            "헬스": "🏋️‍♀️ 운동",
            "러닝": "🏃 러닝",
            "독서": "📚 독서",
            "책": "📚 독서", // Now safe from "산책"
            "공부": "📝 공부",
            "스터디": "📝 공부",
            "영화": "🎬 영화",
            "친구": "👥 만남",
            "회식": "🍻 회식",
            "회의": "💼 업무",
            "업무": "💼 업무",
            "출장": "✈️ 출장",
            "여행": "✈️ 여행",
            "커피": "☕️ 카페",
            "카페": "☕️ 카페"
        ]
        
        for (keyword, tag) in keywords {
            if textForTagging.contains(keyword) {
                if !tags.contains(tag) {
                    tags.append(tag)
                }
            }
        }
        
        // Simple heuristic for future planning
        if lowerText.contains("내일") || lowerText.contains("계획") {
            tags.append("📅 계획")
        }
        
        return tags
    }
}
