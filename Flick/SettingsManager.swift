//
//  SettingsManager.swift
//  Flick
//

import Foundation
import Combine
import Carbon

struct CustomPrompt: Identifiable, Codable, Equatable {
    var id: UUID
    var icon: String
    var title: String
    var systemPrompt: String

    init(id: UUID = UUID(), icon: String, title: String, systemPrompt: String) {
        self.id = id
        self.icon = icon
        self.title = title
        self.systemPrompt = systemPrompt
    }

    static let defaults: [CustomPrompt] = [
        CustomPrompt(icon: "book", title: "解释", systemPrompt: "请清晰简洁地解释以下内容。如果是词语或短语，请给出定义和用法。\n\n{{text}}"),
        CustomPrompt(icon: "doc.text", title: "总结", systemPrompt: "请简洁地总结以下内容，提炼关键要点。\n\n{{text}}"),
        CustomPrompt(icon: "globe", title: "翻译为中文", systemPrompt: "请将以下内容翻译为中文。只输出翻译结果，不需要解释。\n\n{{text}}"),
        CustomPrompt(icon: "pencil.line", title: "润色", systemPrompt: "请润色和改进以下内容，保持原意不变，使其更流畅、更专业。\n\n{{text}}"),
        CustomPrompt(icon: "lightbulb", title: "续写", systemPrompt: "请根据以下内容继续写作，保持一致的风格和语气。\n\n{{text}}")
    ]
}

struct HotkeyConfig: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32
    var displayName: String

    static let `default` = HotkeyConfig(keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey), displayName: "⌥Space")
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private enum Keys {
        static let apiBaseURL = "apiBaseURL"
        static let modelName = "modelName"
        static let apiKey = "apiKey"
        static let customPrompts = "customPrompts"
        static let hotkeyConfig = "hotkeyConfig"
        static let enableReasoning = "enableReasoning"
    }

    @Published var apiBaseURL: String {
        didSet { UserDefaults.standard.set(apiBaseURL, forKey: Keys.apiBaseURL) }
    }

    @Published var modelName: String {
        didSet { UserDefaults.standard.set(modelName, forKey: Keys.modelName) }
    }

    @Published var apiKey: String {
        didSet { KeychainHelper.save(key: Keys.apiKey, value: apiKey) }
    }

    @Published var customPrompts: [CustomPrompt] {
        didSet {
            if let data = try? JSONEncoder().encode(customPrompts) {
                UserDefaults.standard.set(data, forKey: Keys.customPrompts)
            }
        }
    }

    @Published var enableReasoning: Bool {
        didSet { UserDefaults.standard.set(enableReasoning, forKey: Keys.enableReasoning) }
    }

    @Published var hotkeyConfig: HotkeyConfig {
        didSet {
            if let data = try? JSONEncoder().encode(hotkeyConfig) {
                UserDefaults.standard.set(data, forKey: Keys.hotkeyConfig)
            }
        }
    }

    private init() {
        self.apiBaseURL = UserDefaults.standard.string(forKey: Keys.apiBaseURL) ?? "https://api.openai.com/v1"
        self.modelName = UserDefaults.standard.string(forKey: Keys.modelName) ?? "gpt-4o"
        self.apiKey = KeychainHelper.read(key: Keys.apiKey) ?? ""
        self.enableReasoning = UserDefaults.standard.bool(forKey: Keys.enableReasoning)

        if let data = UserDefaults.standard.data(forKey: Keys.customPrompts),
           let prompts = try? JSONDecoder().decode([CustomPrompt].self, from: data) {
            self.customPrompts = prompts
        } else {
            self.customPrompts = CustomPrompt.defaults
        }

        if let data = UserDefaults.standard.data(forKey: Keys.hotkeyConfig),
           let config = try? JSONDecoder().decode(HotkeyConfig.self, from: data) {
            self.hotkeyConfig = config
        } else {
            self.hotkeyConfig = HotkeyConfig.default
        }
    }
}
