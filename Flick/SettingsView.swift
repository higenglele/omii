//
//  SettingsView.swift
//  Flick
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @State private var availableModels: [String] = []
    @State private var isFetchingModels = false
    @State private var fetchError: String?
    @State private var editingPrompt: CustomPrompt?
    @State private var fetchDebounceTask: Task<Void, Never>?

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("通用", systemImage: "gear") }
            promptsTab
                .tabItem { Label("提示词", systemImage: "text.bubble") }
        }
        .frame(width: 520, height: 460)
        .sheet(item: $editingPrompt) { prompt in
            PromptEditorSheet(
                prompt: prompt,
                onSave: { updated in
                    if let idx = settings.customPrompts.firstIndex(where: { $0.id == updated.id }) {
                        settings.customPrompts[idx] = updated
                    } else {
                        settings.customPrompts.append(updated)
                    }
                    editingPrompt = nil
                },
                onCancel: {
                    editingPrompt = nil
                }
            )
        }
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section("API 配置") {
                SecureField("API 密钥", text: $settings.apiKey)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: settings.apiKey) { debouncedFetchModels() }

                TextField("API 基础地址", text: $settings.apiBaseURL)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { fetchModels() }
                    .onChange(of: settings.apiBaseURL) { debouncedFetchModels() }
            }

            Section("模型") {
                if !availableModels.isEmpty {
                    Picker("模型", selection: $settings.modelName) {
                        ForEach(availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                } else {
                    HStack {
                        TextField("模型名称", text: $settings.modelName)
                            .textFieldStyle(.roundedBorder)

                        Button(action: fetchModels) {
                            if isFetchingModels {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .disabled(settings.apiKey.isEmpty || isFetchingModels)
                    }
                }

                if let error = fetchError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }

                Toggle("启用推理模式", isOn: $settings.enableReasoning)
                Text("开启后模型会进行深度思考，响应时间更长但结果更精准。需模型本身支持推理能力。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("快捷键") {
                HStack {
                    Text("全局快捷键：")
                    Spacer()
                    Text("⌘E")
                        .frame(minWidth: 100)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                }
            }

            Section("权限") {
                HStack {
                    Text("需要辅助功能权限才能读取选中的文本。")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("打开系统设置") {
                        NSWorkspace.shared.open(
                            URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                        )
                    }
                    .controlSize(.small)
                }
            }
        }
        .formStyle(.grouped)
        .task {
            if !settings.apiKey.isEmpty && !settings.apiBaseURL.isEmpty && availableModels.isEmpty {
                fetchModels()
            }
        }
    }

    // MARK: - Prompts Tab

    @State private var draggingPrompt: CustomPrompt?

    private var promptsTab: some View {
        VStack(spacing: 0) {
            List {
                ForEach(settings.customPrompts) { prompt in
                    HStack(spacing: 10) {
                        Image(systemName: "line.3.horizontal")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Image(systemName: prompt.icon)
                            .frame(width: 20)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(prompt.title)
                                .font(.body)
                            Text(prompt.systemPrompt)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button(action: {
                            editingPrompt = prompt
                        }) {
                            Image(systemName: "pencil")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            settings.customPrompts.removeAll { $0.id == prompt.id }
                        }) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 2)
                }
                .onMove { source, destination in
                    settings.customPrompts.move(fromOffsets: source, toOffset: destination)
                }
            }

            Divider()

            HStack {
                Button(action: {
                    editingPrompt = CustomPrompt(icon: "star", title: "", systemPrompt: "{{text}}")
                }) {
                    Label("添加提示词", systemImage: "plus")
                }

                Spacer()

                Button("恢复默认") {
                    settings.customPrompts = CustomPrompt.defaults
                }
                .foregroundStyle(.secondary)
            }
            .padding(12)
        }
    }

    // MARK: - Actions

    /// Debounce: wait 0.8s after the user stops typing before fetching
    private func debouncedFetchModels() {
        fetchDebounceTask?.cancel()
        fetchDebounceTask = Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { fetchModels() }
        }
    }

    private func fetchModels() {
        guard !settings.apiKey.isEmpty, !settings.apiBaseURL.isEmpty else { return }
        isFetchingModels = true
        fetchError = nil

        let baseURL = settings.apiBaseURL
        let apiKey = settings.apiKey
        let normalizedURL = AIService.normalizedBaseURL(baseURL)
        print("[Flick] Fetching models from: \(normalizedURL)/models")

        Task {
            do {
                let models = try await AIService.fetchModels(
                    baseURL: baseURL,
                    apiKey: apiKey
                )
                print("[Flick] Fetched \(models.count) models")
                await MainActor.run {
                    availableModels = models
                    isFetchingModels = false
                    if !models.isEmpty && !models.contains(settings.modelName) {
                        settings.modelName = models.first ?? settings.modelName
                    }
                }
            } catch {
                print("[Flick] Fetch models error: \(error)")
                await MainActor.run {
                    fetchError = error.localizedDescription
                    isFetchingModels = false
                }
            }
        }
    }

}

// MARK: - Prompt Editor Sheet

struct PromptEditorSheet: View {
    @State var prompt: CustomPrompt
    let onSave: (CustomPrompt) -> Void
    let onCancel: () -> Void

    private let iconOptions = [
        "star", "book", "doc.text", "globe", "pencil.line", "lightbulb",
        "text.magnifyingglass", "text.quote", "checkmark.circle",
        "arrow.triangle.2.circlepath", "wand.and.stars", "brain",
        "character.bubble", "translate", "doc.plaintext"
    ]

    var body: some View {
        VStack(spacing: 12) {
            Text(prompt.title.isEmpty ? "新建提示词" : "编辑提示词")
                .font(.headline)

            ScrollView {
                Form {
                    Section("基本信息") {
                        Picker("图标", selection: $prompt.icon) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Label(icon, systemImage: icon).tag(icon)
                            }
                        }

                        TextField("名称", text: $prompt.title)
                            .textFieldStyle(.roundedBorder)

                        VStack(alignment: .leading) {
                            Text("提示词内容（使用 {{text}} 表示选中的文本）")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextEditor(text: $prompt.systemPrompt)
                                .font(.body)
                                .frame(height: 100)
                                .border(Color.secondary.opacity(0.2))
                        }
                    }


                }
                .formStyle(.grouped)
            }

            HStack {
                Button("取消", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("保存") {
                    onSave(prompt)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(prompt.title.isEmpty || prompt.systemPrompt.isEmpty)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 420, height: 380)
    }
}


