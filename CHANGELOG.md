# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.0] - 2026-05-27

### Added

**Core**
- `SKILL.md` — Claude Code skill entry point with task identification, model recommendation, and confirmation flow
- Identify → Recommend → Confirm → Execute workflow with mandatory `AskUserQuestion` before invoking external models
- Prompt source choice: user's local prompt files (`~/.config/llm-prompts/<task>.md`) → in-conversation paste → built-in default

**Documentation (bilingual: 中英)**
- `README.md` — overview, quick start, security note
- `SETUP.md` — full installation walkthrough with prerequisites and troubleshooting
- `MODELS.md` — task-to-model mapping reference (document conversion, audio/video, text, vision, agent)
- `FAQ.md` — 10 common questions, headlined by "Can I paste my API key into the chat?" (No.)
- `examples/pdf-to-md.md` — PDF → markdown end-to-end
- `examples/video-to-text.md` — video → timestamped transcript via ffmpeg + ASR
- `examples/text-to-speech.md` — text → audio narration with verified Qwen voices

**Scripts**
- `scripts/setup.sh` — one-command setup: provider menu (9 presets + custom), hidden key input via `read -s`, writes `~/.config/api_keys.env` with mode 600, auto-runs verify
- `scripts/verify.sh` — lists available models via `GET /v1/models`, runs a chat smoke test on the first detected chat model
- `scripts/providers.json` — 9 OpenAI-compatible provider presets: OpenRouter, SiliconFlow, DeepSeek, Moonshot, OpenAI, Anthropic, DashScope, Volcengine ARK, ZhipuAI

**Project files**
- `LICENSE` — MIT
- `.gitignore` — explicitly ignores `*.env`, `api_keys.env`, and large test artifacts to prevent accidental key leaks
- `CHANGELOG.md` — this file

### Security
- API keys are **never** logged, echoed, or written to documentation
- `setup.sh` uses `read -s` (hidden input) and bypasses shell history
- Output file `~/.config/api_keys.env` is created with mode `600` (user-only read)
- `--noproxy '*'` added to all `curl` calls to avoid corporate-proxy interception
- FAQ Q1 explicitly explains why pasting keys into Claude conversations is unsafe (5 leak vectors documented)

### Tested

Smoke-tested against an internal OpenAI-compatible gateway exposing 21 models across Claude/GPT/DeepSeek/Kimi/Qwen/GLM/Mimo families. All 16 chat models returned HTTP 200; Qwen ASR/TTS verified end-to-end with real audio; voices `Cherry`, `Ethan`, `Chelsie`, `Serena`, `Dylan`, `Jada`, `Sunny` confirmed working for `qwen3-tts-flash`.
