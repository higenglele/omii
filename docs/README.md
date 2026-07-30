# Flick — macOS 全局 AI 文本处理工具

Flick 是一款菜单栏常驻的 macOS 原生 AI 工具。在任何应用中选中文本，按下 `⌘E` 即可唤起浮窗，快速调用 AI 模型处理文本。

- **始于**：2026 年 3 月
- **作者**：tape
- **许可**：MIT
- **发布渠道**：GitHub Releases

## 功能

### ⚡ 即时访问

- **全局快捷键** `⌘E` — 在任何应用中选中文本后直接唤起
- **极简界面** — 出现在光标位置的紧凑面板

### 🤖  AI 能力

- **通用模型支持** — 兼容 OpenAI 标准 API（OpenAI、OpenRouter、DeepSeek、Claude 等）
- **流式 SSE 回复** — 实时显示 AI 回复内容
- **自动发现** — 自动从 API 端点获取可用模型列表

### 🎨 界面

- **macOS 原生 UI** — 磨砂玻璃效果，响应式设计
- **Markdown 渲染** — 标题、粗体、斜体、删除线、行内代码、链接、有序/无序列表、引用、分隔线、围栏代码块；流式回复中持续渲染，未闭合标记暂以普通文本展示
- **代码块复制** — 每个代码块拥有独立复制按钮，只复制代码正文
- **用户滚动优先** — 阅读旧内容时自动滚动暂停，回到底部后恢复跟随
- **窗口缩放与记忆** — AI 回复页可拖拽缩放（最小 380×360 pt），尺寸跨会话和重启保持
- **图钉固定** — 固定后窗口保持在普通应用窗口上方，切换应用不关闭
- **多结果窗口** — 多个独立窗口，自动错开排列，各自独立回复、移动、缩放和固定
- **拖拽排序** — 拖拽调整提示词顺序

### 🔒 安全

- **API 密钥** — 仅存储在 macOS 钥匙串中
- **隐私优先** — 文本仅在你选择发送时才离开本地
- **无数据收集** — 使用数据不会离开你的电脑

### OpenRouter

- **余额展示** — 位于设置 → 通用 → API 配置，打开设置时自动刷新
- **连接状态** — 显示已连接、加载中、连接失败等状态
- **美元余额** — 保留两位小数，附带相对刷新时间

## 系统要求

- macOS 26.0+
- 辅助功能权限（读取选中文本）

## 安装

### 从 Release 安装

从 [GitHub Releases](https://github.com/yourusername/flick/releases) 下载最新 `.dmg`，拖入 Applications 文件夹。

### 开发者构建

```bash
git clone https://github.com/yourusername/flick.git
cd flick
open Flick.xcodeproj
# 选择 Flick scheme → My Mac → Run (⌘R)
```

## 首次使用

1. 启动 Flick，授予辅助功能权限
2. 点击菜单栏 ✨ 图标 → "设置"
3. 填入 API Base URL（如 `https://api.openai.com/v1`）和 API Key
4. 点击 "刷新模型" 获取可用模型列表
5. 在任何应用中选中文本，按 `⌘E`

### 内置提示词

| 图标 | 提示词 | 说明 |
|------|--------|------|
| 📖 | 解释 | 提供清晰的解释和定义 |
| 📝 | 总结 | 提取关键要点，创建简洁总结 |
| 🌐 | 翻译为中文 | 将文本翻译为中文 |
| ✏️ | 润色 | 提高清晰度、流畅性和专业性 |
| 💡 | 续写 | 按照相同风格生成延续内容 |

按下数字键 `1`–`5` 可快速选择对应提示词。

## API 配置

### 兼容的服务

| 服务 | 基础 URL |
|------|---------|
| **OpenAI** | `https://api.openai.com/v1` |
| **OpenRouter** | `https://openrouter.ai/api/v1` |
| **DeepSeek** | `https://api.deepseek.com` |
| **Azure OpenAI** | `https://{resource}.openai.azure.com/openai/deployments/{deployment}` |
| **Ollama** | `http://localhost:11434/v1` |
| **LM Studio** | `http://localhost:1234/v1` |
| **本地模型** | `http://localhost:8080/v1` |

Flick 兼容任何提供 `/chat/completions` 端点的 OpenAI 标准 API。

## 故障排查

1. 验证 API 基础 URL 是否正确
2. 检查 API 密钥是否有效且有足够额度
3. 确保服务支持 `/chat/completions` 端点并启用流式传输
4. 检查网络连通性：`curl -I <你的 API 基础 URL>`
5. 如果使用代理，检查代理配置是否正确
6. 查看应用日志（控制台 → Flick）获取详细网络错误
7. 检查 macOS 防火墙设置：系统设置 → 网络 → 防火墙

## 常见问题

### Q: 为什么需要辅助功能权限？

macOS 安全机制要求应用具备辅助功能权限才能从其他应用中读取文本。Flick 通过模拟 `⌘C` 获取你选中的文本。

### Q: 可以使用免费的 AI 模型吗？

可以。Flick 兼容任何 OpenAI 标准 API：
- [Ollama](https://ollama.ai/)（本地 LLM）
- [LM Studio](https://lmstudio.ai/)（本地图形界面）
- [OpenRouter](https://openrouter.ai/)（聚合模型）
- 其他自托管解决方案

### Q: 可以使用自定义快捷键吗？

目前 Flick 默认使用 `⌘E`。自定义快捷键支持已在计划中。

### Q: 文本数据会被发送到其他地方吗？

**不会**。你的选中文本仅发送到你明确配置的 AI 服务。应用本身不包含分析、遥测或外部数据收集。

## 贡献

1. 报告问题或建议功能 → [GitHub Issues](https://github.com/yourusername/flick/issues)
2. 提交代码：
   ```bash
   git clone https://github.com/yourusername/flick.git
   cd flick
   git checkout -b feature/你的功能名称
   # 修改后提交 Pull Request
   ```

### 代码风格

- 使用 Swift 现代并发特性（`async/await`）
- 遵循 Apple Swift API 设计指南
- 为新功能编写单元测试

## 项目文档

| 文档 | 内容 |
|---|---|
| [PROJECT_CONTEXT.md](./PROJECT_CONTEXT.md) | 技术栈、模块说明、数据流 |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | 架构图、核心流程、状态管理 |
| [CHANGELOG.md](./CHANGELOG.md) | 版本变更记录 |
| [ROADMAP.md](./ROADMAP.md) | 完成情况与未来方向 |
| [TODO.md](./TODO.md) | 待优化项与技术债 |
| 根目录 `任务清单.md` | 完整开发任务追踪 |
| 根目录 `技术方案.md` | 技术设计文档 |
| 根目录 `需求说明.md` | 产品需求文档 |

## 许可证

MIT © 2026 tape。详见 [LICENSE](../LICENSE)。
