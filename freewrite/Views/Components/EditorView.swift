import SwiftUI

struct EditorView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    
    @Binding var text: String
    @Binding var selectedFont: String
    @Binding var fontSize: CGFloat
    @Binding var colorSchemeString: String
    var editorFocus: FocusState<Bool>.Binding

    // Calculate line height for spacing
    private var lineHeight: CGFloat {
        #if os(macOS)
        let font = NSFont(name: selectedFont, size: fontSize) ?? .systemFont(ofSize: fontSize)
        return font.pointSize * 0.5
        #elseif os(iOS)
        let font = UIFont(name: selectedFont, size: fontSize) ?? .systemFont(ofSize: fontSize)
        return font.lineHeight * 0.5
        #endif
    }

    // Use fontSize for body text
    private var bodyFontSize: CGFloat { fontSize }

    // Padding inside the TextEditor
    private let textEditorHPadding: CGFloat = 15
    private let textEditorVPadding: CGFloat = 10

    // Determine light themes for shadow contrast
    private var isLightBasedTheme: Bool {
        colorSchemeString == "light" || colorSchemeString == "sepia" || colorSchemeString == "dracula_lite"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder when empty
            if text.isEmpty {
                Text("What’s on your mind today?")
                    .font(.system(size: bodyFontSize, weight: .light))
                    .foregroundColor(.gray)
                    .padding(.horizontal, textEditorHPadding + 4)
                    .padding(.vertical, textEditorVPadding + 8)
            }

            // Main editor
            TextEditor(text: $text)
                #if os(iOS)
                .background(Color.clear)
                #endif
                .focused(editorFocus)
                .font(.system(size: bodyFontSize, weight: .light))
                .foregroundColor(BrandColors.primaryText(for: colorSchemeString))
                .modifier(ScrollCleanupModifier())
                .lineSpacing(lineHeight)
                .id("Editor-\(selectedFont)-\(fontSize)-\(colorSchemeString)")
                .padding(.horizontal, textEditorHPadding)
                .padding(.vertical, textEditorVPadding)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(BrandColors.secondaryBackground(for: colorSchemeString))
                .shadow(color: Color.black.opacity(isLightBasedTheme ? 0.08 : 0.2), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
        .padding(.top, 30)
        .padding(.bottom, 10)
    }
}

// Need ScrollCleanupModifier definition accessible if not already global
// REMOVING the definition below as it's likely declared elsewhere.
/*
struct ScrollCleanupModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
                .scrollIndicators(.never)
        } else {
            // Fallback for older iOS versions if needed
             content
                .onAppear {
                    UITextView.appearance().backgroundColor = .clear
                }
                .onDisappear {
                    UITextView.appearance().backgroundColor = nil
                }
        }
    }
}
*/ 
