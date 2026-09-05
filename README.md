# Omii — 选中文字，按 ⌘E

常驻 macOS 菜单栏的 AI 文本助手。

## 功能

- 五个预设提示词：解释、总结、翻译、润色、续写
- 支持自定义提示词
- Markdown 流式渲染
- 每个代码块都有独立的复制按钮
- 图钉固定
- 多窗口并存，互不干扰
- 自动记住窗口尺寸

## 安装

从 [Releases](https://github.com/higenglele/Omii/releases) 下载 dmg 并安装。

首次打开若被 Gatekeeper 拦截，在终端执行：

```bash
xattr -dr com.apple.quarantine /Applications/Omii.app
```

## 首次配置

1. 授予辅助功能权限
2. 点击菜单栏图标
3. 打开设置，填写 API Base URL 和 API Key
4. 刷新模型列表

然后选中任意文字，按 ⌘E 即可。

## 支持的服务

| 服务 | API Base URL |
|---|---|
| OpenAI | `https://api.openai.com/v1` |
| OpenRouter | `https://openrouter.ai/api/v1` |
| DeepSeek | `https://api.deepseek.com` |
| Azure OpenAI | 你的专属地址 |
| Ollama（本地） | `http://localhost:11434/v1` |
| LM Studio（本地） | `http://localhost:1234/v1` |

Omii 兼容任何 OpenAI 标准 API，以上服务开箱即用。

## 系统要求

- macOS 14.0+
- 需要辅助功能权限

## 常见问题

**为什么需要辅助功能权限？**
macOS 不允许一个应用直接读取另一个应用的选中文字。Omii 通过模拟 ⌘C 来获取文本，这需要辅助功能权限。

**我的文字数据发到哪里？**
选中的文字只发送给你自己配置的 AI 服务。Omii 本身不收集、不分析、不上传任何数据。

**为什么上不了 App Store？**
读取其他应用选中文字依赖辅助功能 API，这类权限超出 App Store 允许范围，因此 Omii 以独立分发方式提供。

## 许可证

MIT，详见 [LICENSE](./LICENSE)。
