//
//  SelectionReader.swift
//  Flick
//

import AppKit
import Carbon

enum SelectionReader {
    /// Gets the currently selected text by simulating Cmd+C and reading the pasteboard.
    static func getSelectedText(completion: @escaping (String?) -> Void) {
        // Save current pasteboard content
        let pasteboard = NSPasteboard.general
        let previousContents = pasteboard.string(forType: .string)
        let previousChangeCount = pasteboard.changeCount

        // Simulate Cmd+C
        simulateCopy()

        // Wait briefly for the copy to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let newChangeCount = pasteboard.changeCount
            if newChangeCount != previousChangeCount,
               let text = pasteboard.string(forType: .string) {
                // Restore previous pasteboard content
                pasteboard.clearContents()
                if let prev = previousContents {
                    pasteboard.setString(prev, forType: .string)
                }
                completion(text)
            } else {
                completion(nil)
            }
        }
    }

    private static func simulateCopy() {
        let source = CGEventSource(stateID: .hidSystemState)

        // Key down: Cmd+C
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_C), keyDown: true)
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)

        // Key up: Cmd+C
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_C), keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)
    }
}
