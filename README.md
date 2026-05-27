# multi-model-router(多模型路由)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#)
[![Skill Type](https://img.shields.io/badge/Claude_Code-skill-7C3AED.svg)](https://docs.claude.com/en/docs/claude-code/skills)
[![Docs](https://img.shields.io/badge/docs-中文_%7C_English-success.svg)](#)

> A Claude Code skill that lets one OpenAI-compatible API key power many AI tasks — automatically picking the right model for each job, asking you to confirm, then invoking it via Bash.
>
> 一个 Claude Code skill,让一把 OpenAI 兼容 API key 驱动多种 AI 任务——自动为每个任务挑选合适的模型,询问你确认后通过 Bash 调用。

[English](#english) | [中文](#中文)

---

## English

### Why?

You have one API key (e.g., from OpenRouter, SiliconFlow, DeepSeek, or your company's gateway) that exposes many models — Claude, GPT, DeepSeek, Kimi, Qwen, GLM, etc.

But you don't want to memorize "which model is best for which task". This skill makes Claude do it for you:

1. **You describe the task** ("transcribe this video", "convert this PDF to markdown", "summarize this 200K-word doc")
2. **Claude identifies** the task type, language, and constraints
3. **Claude recommends** a model with rationale ("for Chinese ASR, qwen3-asr-flash is the only top-tier option")
4. **Claude asks you to confirm** via an interactive prompt
5. **Claude executes** via Bash + curl, output back to you

### Features

- 🔀 **Smart routing** — task → recommended model with reasoning
- 🔐 **Secure setup** — keys never enter conversation context, stored in `~/.config/api_keys.env` (mode 600)
- 🌐 **Provider-agnostic** — works with any OpenAI-compatible gateway (OpenRouter, SiliconFlow, DeepSeek, Moonshot, custom)
- 🧠 **Prompt source choice** — uses your own prompt files (`~/.config/llm-prompts/pdf-to-md.md`, etc.) or built-in defaults; asks before overriding
- ⚡ **One-command setup** — `bash scripts/setup.sh` handles everything
- 📝 **Bilingual docs** — Chinese + English

### Quick Start

```bash
# 1. Clone (or download as a Claude Code skill)
git clone https://github.com/YOUR_USERNAME/multi-model-router.git \
  ~/.claude/skills/multi-model-router

# 2. Run setup (you'll be prompted for provider + API key, hidden input)
bash ~/.claude/skills/multi-model-router/scripts/setup.sh

# 3. Verify (lists available models, runs a smoke test)
bash ~/.claude/skills/multi-model-router/scripts/verify.sh

# 4. In Claude Code, just describe a task — the skill activates automatically
```

### Documentation

- **[SETUP.md](SETUP.md)** — Full installation walkthrough
- **[MODELS.md](MODELS.md)** — Task-to-model mapping reference
- **[FAQ.md](FAQ.md)** — Common questions, **including "Can I paste my API key into the chat?"**
- **[examples/](examples/)** — End-to-end examples

### Security

🔒 **Never paste your API key directly into a chat with Claude.** Conversation history may be saved to local logs, knowledge bases, or third-party syncs. Always use `setup.sh` which reads keys via hidden input and stores them in a 600-permission file. See [FAQ.md](FAQ.md) for details.

### License

MIT. PRs welcome.

---

## 中文

### 为什么需要这个 skill?

你有一把 API key(可能来自 OpenRouter、硅基流动、DeepSeek 官方,或公司内部网关),它能调多种模型——Claude、GPT、DeepSeek、Kimi、Qwen、GLM 等等。

但你不想每次都记"哪个模型最适合哪类任务"。这个 skill 让 Claude 帮你判断:

1. **你描述任务**("帮我转写这个视频"、"把这个 PDF 转成 markdown"、"总结这份 20 万字文档")
2. **Claude 识别**任务类型、语言、约束
3. **Claude 推荐**模型并说明理由("中文转写 qwen3-asr-flash 是唯一顶级选择")
4. **Claude 询问确认**(交互式提示)
5. **Claude 执行** Bash + curl 调用,结果返回给你

### 特性

- 🔀 **智能路由** — 任务 → 推荐模型,附理由
- 🔐 **安全配置** — key 不进对话上下文,存于 `~/.config/api_keys.env`(600 权限)
- 🌐 **服务商无关** — 支持任意 OpenAI 兼容网关(OpenRouter / 硅基流动 / DeepSeek / Kimi / 自部署)
- 🧠 **提示词复用** — 优先使用你自己的提示词文件(如 `~/.config/llm-prompts/pdf-to-md.md`),没有才用默认
- ⚡ **一键安装** — `bash scripts/setup.sh` 全自动
- 📝 **中英双语文档**

### 快速开始

```bash
# 1. 克隆(或作为 Claude Code skill 下载)
git clone https://github.com/YOUR_USERNAME/multi-model-router.git \
  ~/.claude/skills/multi-model-router

# 2. 运行安装(会提示你选服务商 + 输入 API key,隐藏输入)
bash ~/.claude/skills/multi-model-router/scripts/setup.sh

# 3. 验证(列出可用模型,跑一次冒烟测试)
bash ~/.claude/skills/multi-model-router/scripts/verify.sh

# 4. 在 Claude Code 里直接描述任务,skill 会自动激活
```

### 文档

- **[SETUP.md](SETUP.md)** — 完整安装指南
- **[MODELS.md](MODELS.md)** — 任务-模型映射手册
- **[FAQ.md](FAQ.md)** — 常见问题,**包括"我能不能把 API key 直接粘到对话里?"**
- **[examples/](examples/)** — 端到端示例(PDF 转 md / 视频转写 / TTS 配音)

### 安全

🔒 **永远不要把 API key 直接粘贴到与 Claude 的对话里。** 对话历史可能被保存到本地日志、知识库、或第三方同步。请使用 `setup.sh`,它通过隐藏输入读取 key,存到 600 权限的文件里。详见 [FAQ.md](FAQ.md)。

### 协议

MIT。欢迎 PR。
