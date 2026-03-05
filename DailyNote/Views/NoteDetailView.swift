import SwiftUI

struct NoteDetailView: View {

    let entry: NoteEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // 1. 헤더 (날짜 및 감정) - Android의 Row { Text(date); Spacer(); Text(emotion) } 와 동일
                HStack(alignment: .center) {
                    Text(entry.id)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let emotion = entry.emotion {
                        Text(verbatim: emotion)
                            .font(.title2)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                
                // 2. 제목
                if !entry.title.isEmpty {
                    Text(entry.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // 3. 태그 렌더링 (LazyRow 역할)
                if let tags = entry.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                Text(LocalizedStringKey(tag))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // 4. 본문
                Text(entry.content)
                    .font(.body)
                    .lineSpacing(8)
                    .foregroundColor(.primary.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(24)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(NSLocalizedString("note_detail_title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}
