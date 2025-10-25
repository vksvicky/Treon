import SwiftUI
import AppKit

// Custom scroll view that allows proper cursor handling for window resizing
class CursorAwareScrollView: NSScrollView {
    override func resetCursorRects() {
        super.resetCursorRects()
        // Allow the window to handle cursor changes for resizing
        discardCursorRects()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        // Let the window handle cursor changes
        window?.invalidateCursorRects(for: self)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        // Let the window handle cursor changes
        window?.invalidateCursorRects(for: self)
    }
}

struct JSONTextView: NSViewRepresentable {
    @Binding var text: String
    var isWordWrapEnabled: Bool
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = CursorAwareScrollView()
        let textView = NSTextView()
        
        // Configure scroll view
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = !isWordWrapEnabled
        scrollView.autohidesScrollers = true
        
        // Configure text view
        textView.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.delegate = context.coordinator
        
        // Ensure proper cursor handling for window resizing
        scrollView.wantsLayer = true
        scrollView.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Set initial text
        textView.string = text
        
        // Configure word wrap
        configureWordWrap(textView: textView, scrollView: scrollView, isEnabled: isWordWrapEnabled)
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else {
            return
        }
        
        // Only update if text changed from outside
        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            // Restore selection if possible
            if !selectedRanges.isEmpty {
                textView.selectedRanges = selectedRanges
            }
        }
        
        // Always reconfigure word wrap to ensure proper state
        configureWordWrap(textView: textView, scrollView: scrollView, isEnabled: isWordWrapEnabled)
    }
    
    private func configureWordWrap(textView: NSTextView, scrollView: NSScrollView, isEnabled: Bool) {
        guard let textContainer = textView.textContainer else { return }
        
        // Always show vertical scroller
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        
        if isEnabled {
            // Enable word wrap - text wraps to visible width
            scrollView.hasHorizontalScroller = false
            textView.isHorizontallyResizable = false
            textView.autoresizingMask = [.width]
            
            textContainer.widthTracksTextView = true
            textContainer.heightTracksTextView = false
            textContainer.containerSize = NSSize(
                width: scrollView.contentSize.width,
                height: CGFloat.greatestFiniteMagnitude
            )
            
            // Set text view frame to match scroll view
            let clipView = scrollView.contentView
            textView.frame = NSRect(
                x: 0, y: 0,
                width: clipView.bounds.width,
                height: textView.frame.height
            )
        } else {
            // Disable word wrap - allow horizontal scrolling
            scrollView.hasHorizontalScroller = true
            textView.isHorizontallyResizable = true
            textView.autoresizingMask = []
            
            textContainer.widthTracksTextView = false
            textContainer.heightTracksTextView = false
            textContainer.containerSize = NSSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            )
            
            // Set a minimum width for the text view
            textView.minSize = NSSize(width: 0, height: 0)
            textView.maxSize = NSSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            )
        }
        
        // Configure line fragment padding
        textContainer.lineFragmentPadding = 5
        
        // Force layout and display update
        textView.layoutManager?.ensureLayout(for: textContainer)
        textView.sizeToFit()
        textView.setNeedsDisplay(textView.bounds)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: JSONTextView
        
        init(_ parent: JSONTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}
