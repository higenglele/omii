//
//  PanelPinButton.swift
//  Flick
//

import SwiftUI

struct PanelPinButton: View {
    @Binding var pinState: PinState

    var body: some View {
        Button(action: togglePin) {
            Image(systemName: pinState == .pinned ? "pin.fill" : "pin")
                .font(.caption)
                .foregroundStyle(
                    pinState == .pinned
                        ? Color.accentColor
                        : Color.secondary
                )
        }
        .buttonStyle(.plain)
        .help(pinState == .pinned ? "取消固定浮窗" : "固定浮窗")
        .accessibilityLabel(
            pinState == .pinned ? "取消固定浮窗" : "固定浮窗"
        )
        .accessibilityValue(pinState == .pinned ? "已固定" : "未固定")
    }

    private func togglePin() {
        pinState.toggle()
    }
}
