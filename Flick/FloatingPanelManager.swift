//
//  FloatingPanelManager.swift
//  Flick
//

import AppKit

/// Creates and retains independent floating-panel controllers.
final class FloatingPanelManager {
    private var controllers: [UUID: FloatingPanelController] = [:]

    var activeSessionCount: Int {
        controllers.count
    }

    @discardableResult
    func show(at point: NSPoint, with selectedText: String) -> UUID {
        let session = PanelSession(selectedText: selectedText)
        let controller = FloatingPanelController(
            session: session,
            onClose: { [weak self] id in
                self?.removeClosedSession(id: id)
            }
        )

        controllers[session.id] = controller
        controller.show(at: point)
        return session.id
    }

    func session(id: UUID) -> PanelSession? {
        controllers[id]?.session
    }

    func close(id: UUID) {
        controllers[id]?.close()
    }

    func closeAll() {
        let activeControllers = Array(controllers.values)
        activeControllers.forEach { $0.close() }
    }

    private func removeClosedSession(id: UUID) {
        controllers[id] = nil
    }
}
