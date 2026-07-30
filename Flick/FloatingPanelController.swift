//
//  FloatingPanelController.swift
//  Flick
//

import AppKit
import SwiftUI

/// Custom NSPanel that can become key window to receive keyboard events
class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

class FloatingPanelController {
    private var panel: NSPanel?
    private var monitor: Any?
    private let preferencesStore: PanelPreferencesStore
    private let geometryService: PanelGeometryService

    init(
        preferencesStore: PanelPreferencesStore = PanelPreferencesStore(),
        geometryService: PanelGeometryService = PanelGeometryService()
    ) {
        self.preferencesStore = preferencesStore
        self.geometryService = geometryService
    }

    func show(at point: NSPoint, with selectedText: String) {
        close()

        let listSize = promptListSize()

        let aiService = AIService()
        let view = PresetPromptView(
            selectedText: selectedText,
            aiService: aiService,
            onClose: { [weak self] in self?.close() },
            onPhaseChange: { [weak self] phase in
                self?.applyPhase(phase)
            }
        )

        let hostingView = NSHostingView(rootView: view)

        let panel = KeyablePanel(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: listSize.width,
                height: listSize.height
            ),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.contentView = hostingView
        panel.isMovableByWindowBackground = true
        configure(panel, for: .promptList)

        // Position near mouse cursor
        let panelOrigin = NSPoint(
            x: point.x - listSize.width / 2,
            y: point.y - listSize.height - 10
        )
        panel.setFrameOrigin(panelOrigin)

        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.panel = panel

        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.close()
        }
    }

    func close() {
        panel?.orderOut(nil)
        panel = nil
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }

    func promptListSize() -> NSSize {
        let promptCount = SettingsManager.shared.customPrompts.count
        let listHeight = CGFloat(32 + promptCount * 30 + 8 + 54)
        return NSSize(width: 280, height: min(listHeight, 300))
    }

    func configure(_ panel: NSPanel, for phase: PanelPhase) {
        switch phase {
        case .promptList:
            let listSize = promptListSize()
            PanelResizeCapability.apply(
                isResizable: false,
                minimumSize: listSize,
                maximumSize: listSize,
                to: panel
            )
        case .response:
            guard let visibleFrame = targetVisibleFrame(for: panel) else {
                return
            }
            let savedSize = preferencesStore.loadResponsePanelSize()
            let constrainedSize = geometryService.constrainedSize(
                savedSize,
                visibleFrame: visibleFrame
            )
            let maximumSize = geometryService.constrainedSize(
                PanelGeometryService.theoreticalMaximumSize,
                visibleFrame: visibleFrame
            )
            let minimumSize = geometryService.constrainedSize(
                PanelGeometryService.minimumSize,
                visibleFrame: visibleFrame
            )

            PanelResizeCapability.apply(
                isResizable: true,
                minimumSize: NSSize(
                    width: minimumSize.width,
                    height: minimumSize.height
                ),
                maximumSize: NSSize(
                    width: maximumSize.width,
                    height: maximumSize.height
                ),
                to: panel
            )
            resizePanel(
                panel,
                to: NSSize(
                    width: constrainedSize.width,
                    height: constrainedSize.height
                )
            )
        }
    }

    private func applyPhase(_ phase: PanelPhase) {
        guard let panel else { return }
        configure(panel, for: phase)

        if phase == .promptList {
            resizePanel(panel, to: promptListSize())
        }
    }

    private func resizePanel(_ panel: NSPanel, to size: NSSize) {
        let frame = panel.frame
        let requestedFrame = NSRect(
            x: frame.origin.x,
            y: frame.origin.y + frame.height - size.height,
            width: size.width,
            height: size.height
        )
        let visibleFrame = targetVisibleFrame(for: panel) ?? requestedFrame
        let newFrame = geometryService.constrainedFrame(
            requestedFrame,
            to: visibleFrame
        )
        panel.setFrame(newFrame, display: true, animate: true)
    }

    private func targetVisibleFrame(for panel: NSPanel) -> NSRect? {
        geometryService.primaryScreen(for: panel.frame)?.visibleFrame
            ?? panel.screen?.visibleFrame
            ?? NSScreen.main?.visibleFrame
    }
}
