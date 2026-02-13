import SwiftUI

struct NoteRowView: View {
    let entry: NoteEntry
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showTooltip = false
    
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
                            Text(emotion)
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
                
                Text(entry.content)
                    .font(.body)
                    .foregroundColor(.primary.opacity(0.90))
                
                if let tags = entry.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
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
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
