import SwiftUI
import AppKit

/// 包装 NSVisualEffectView，提供真正能透出桌面的毛玻璃背景。
/// SwiftUI 原生的 .ultraThinMaterial 在无边框 NSPanel 里只采样窗口内部，
/// 必须用 .behindWindow 混合模式才能糊到后面的桌面。
struct VisualEffectBackground: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = .behindWindow
        view.state = .active
        view.isEmphasized = true
        // 面板内文字颜色是写死的浅色，强制暗色外观，
        // 这样系统切到浅色模式时面板也不会变成白底白字。
        view.appearance = NSAppearance(named: .vibrantDark)
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
    }
}
