import SwiftUI

struct NoteRowView: View {
    let entry: NoteEntry
    var showActions: Bool = true
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showTooltip = false
    @State private var isExpanded = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.id)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let emotion = entry.emotion {
                        Button {
                            showTooltip.toggle()
                        } label: {
                            Text(verbatim: emotion)
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $showTooltip) {
                            Text("ai_emotion_tooltip")
                                .font(.caption)
                                .padding()
                                .presentationCompactAdaptation(.popover)
                        }
                    }
                }
                
                if !entry.title.isEmpty {
                    Text(entry.title)
                        .font(.headline)
                }
                
                // Content with "read more" logic
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.content)
                        .font(.body)
                        .foregroundColor(.primary.opacity(0.90))
                        .multilineTextAlignment(.leading) 
                        // If expanded, show all lines. If not, we limit the frame height.
                        // We use lineLimit(nil) to ensure Text renders fully for measurement if needed, 
                        // but here we rely on frame clipping for the "height > 100" effect.
                        .frame(maxWidth: .infinity, maxHeight: isExpanded ? nil : 100, alignment: .topLeading)
                        .clipped() 
                    
                    // Show button if content is long enough to likely exceed 100pt or has many lines.
                    // Since we implemented a 100-char limit for NEW notes, this mostly affects old notes 
                    // or notes with many newlines.
                    if entry.content.count > 100 || entry.content.components(separatedBy: .newlines).count > 4 { 
                         Button(action: { isExpanded.toggle() }) {
                             Text(isExpanded ? "접기" : "더보기")
                                 .font(.caption)
                                 .foregroundColor(.blue)
                         }
                         .padding(.top, 2)
                    }
                }
                
                if let tags = entry.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text(LocalizedStringKey(tag))
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            if showActions {
                HStack(spacing: 10) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .imageScale(.medium)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .imageScale(.medium)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .onAppear {
            print("emotion = \(entry.emotion ?? "nil")")
            print("tags = \(entry.tags ?? [])")
        }
    }
}
