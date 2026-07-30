# Flick — macOS 全局 AI 文本处理工具

Flick 是一款菜单栏常驻的 macOS 原生 AI 工具。在任何应用中选中文本，按下 `⌘E` 即可唤起浮窗，快速调用 AI 模型处理文本。

- 始于 2026 年 3 月
- 作者：tape
- 许可：MIT
- 发布渠道：GitHub Releases

## 功能

- **全局快捷键** `⌘E` — 在任何应用中选中文本后直接唤起
- **兼容 OpenAI 标准 API** — 支持 OpenAI、OpenRouter、DeepSeek、本地模型等
- **流式 SSE 回复** — 实时显示 AI 回复，支持 Markdown 渲染
- **Markdown 渲染** — 标题、粗体、斜体、删除线、行内代码、链接、有序/无序列表、引用、分隔线、围栏代码块；流式过程中未闭合标记暂以普通文本展示
- **代码块独立复制** — 每个代码块有独立的复制按钮，只复制代码正文
- **多结果窗口** — 多个浮窗可同时存在，响应、缩放、固定互不影响
- **窗口缩放与尺寸记忆** — AI 回复页可拖拽缩放（最小 380×360 pt），尺寸跨会话和重启保持
- **图钉固定** — 固定后窗口保持在普通应用窗口上方，切换应用不关闭
- **OpenRouter 余额** — 设置页自动刷新并展示余额、连接状态
- **自定义提示词** — 内置 5 个预设提示词，支持自定义

## 系统要求

- macOS 26.0+
- 辅助功能权限（读取选中文本）

## 安装

### 开发者构建

```bash
git clone https://github.com/yourusername/flick.git
cd flick
open Flick.xcodeproj
# Xcode → 选择 My Mac → Run (⌘R)
```

### 从 Release 安装

从 [GitHub Releases](https://github.com/yourusername/flick/releases) 页面下载最新 `.dmg`，拖入 Applications 文件夹。

## 首次使用

1. 启动 Flick，系统会提示授予辅助功能权限
2. 点击菜单栏 ✨ 图标 → "设置"
3. 填入你的 API Base URL 和 API Key
4. 点击 "刷新模型" 加载可用模型列表
5. 在任何应用中选中文本，按 `⌘E`

## 用户反馈

欢迎通过 [GitHub Issues](https://github.com/yourusername/flick/issues) 报告问题或建议功能。

## 项目状态

当前分支 `OpenRoter_build`。详细开发记录见 [CHANGELOG.md](./CHANGELOG.md)，技术细节见 [ARCHITECTURE.md](./ARCHITECTURE.md)，开发计划见 [ROADMAP.md](./ROADMAP.md)。
