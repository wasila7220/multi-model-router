---
name: multi-model-router
description: Use when user requests a task that could be routed to a different AI model via an OpenAI-compatible gateway (a single API key giving access to multiple models like Claude/GPT/DeepSeek/Kimi/Qwen). Triggers include audio/video transcription, TTS, PDF→md conversion, OCR, batch text processing, multi-model comparison, or any mention of "用千问/deepseek/kimi/gpt", "用哪个模型最好". The skill identifies the task, recommends a model with rationale, confirms with AskUserQuestion, and invokes via Bash + curl. Skip when user has explicitly named a model and said "直接干"/"不用问"/"just do it".
---

# Multi-Model Router(多模型路由)

> **TL;DR**:你有一个 OpenAI 兼容网关的 key,这个 skill 帮 Claude 自动判断「该用哪个模型」,询问你确认后调用。
>
> **TL;DR(EN)**: You have one API key for an OpenAI-compatible gateway. This skill helps Claude pick the right model per task, asks you to confirm, then invokes it.

## 🚀 First Time Setup(首次使用)

**This skill needs setup. If `~/.config/api_keys.env` does not exist or is missing `LLM_API_KEY`/`LLM_API_BASE`, do not proceed — direct the user to run:**

```bash
bash ~/.claude/skills/multi-model-router（多模型路由）/scripts/setup.sh
```

详见 [SETUP.md](SETUP.md)。安装完后调 `scripts/verify.sh` 列出可用模型。

## 🔒 Security First — 安全第一(必读)

**绝对禁止**:用户在对话里直接粘贴 API key。

如果用户粘贴了:
1. 立刻在回复中**不要复述 key**(连前缀都不要)
2. 提示用户:**"我已收到 key,但建议立刻在服务商后台 revoke 这一把 → 重新生成 → 用 setup.sh 写入本地文件"**
3. 解释原因:对话历史会被保存(本地 `~/.claude/projects/`、第三方 wiki 同步等),key 可能被无意间泄露
4. **永远不要** 把 key 写到 SKILL.md/README/任何文档里
5. **永远不要** 在 Bash 命令里 echo/print key 内容

**正确路径**:Key 永远只存于 `~/.config/api_keys.env`(权限 600),所有调用通过 `source` 加载,不进入对话上下文。

## 核心原则 — Core Principle

**Identify → Recommend → Confirm → Execute**

1. **Identify**:复述任务,标注关键属性(语言、体量、精度、是否需画面)
2. **Recommend**:对照 [MODELS.md](MODELS.md) 给首选+备选,说明理由
3. **Confirm**:用 AskUserQuestion 让用户拍板(**不允许跳过**)
4. **Execute**:Bash + curl,key 从 `~/.config/api_keys.env` 读

**例外**:用户明确说"直接干"/"不用问"/"just do it",或已指定模型时,跳过询问。

## 何时触发 — When to Use

满足任一即触发:

- 任务涉及**音视频处理**(转写、配音)
- 任务涉及**文档转换**(PDF→md、Word→结构化、OCR)
- 任务涉及**大量批处理**文本(改写、打标、提取)
- 任务涉及**长文本**(>20 万字总结)
- 用户明确说"用千问/deepseek/kimi/gpt"
- 用户问"用哪个模型最好"

**不触发**:小段对话、当前会话内的代码编辑、明确指定用 Claude 的任务。

## 任务-模型快速映射表

> 完整版见 [MODELS.md](MODELS.md)。这里是高频场景速查。

| 任务类型 | 首选模型族 | 选择逻辑 |
|---|---|---|
| 中文音视频转写 | Qwen ASR(`qwen3-asr-flash` 或同类) | 中文 ASR 唯一最佳选 |
| 英文音视频转写 | OpenAI Whisper / `gpt-4o-mini-transcribe` | 英文准 |
| 多人对话转写(说话人分离) | `gpt-4o-transcribe-diarize` | 唯一带 diarization |
| 中文 TTS | Qwen TTS(`qwen3-tts-flash`) | 中文音色丰富 |
| 英文 TTS | `gpt-4o-mini-tts` | OpenAI 音色 |
| PDF→md(中文版式) | DeepSeek V3 系列 | 中文还原好,价格低 |
| PDF→md(英文/学术/公式) | Claude Sonnet | 表格公式精度 |
| 长文本(>20万字)总结 | Kimi(K2 系列) | 上下文最长 |
| 视觉/图表分析 | Claude Sonnet / GPT-4o | 视觉精度 |
| 复杂推理/Agent | Claude Opus / GPT-5 系列 | 工具调用 |
| 大量批处理(廉价) | DeepSeek Flash / Claude Haiku | 单价最低 |
| 中文创意写作 | DeepSeek / Kimi | 文学性 |
| 数学/物理/逻辑 | DeepSeek / Claude Opus | 推理强 |

**实际可用模型由你的网关决定**。运行 `scripts/verify.sh` 查询当前 key 暴露的模型清单,然后人工对照上表(模型名通常带版本号,如 `claude-opus-4-7`、`deepseek-v4-pro`)。

## 调用模板 — Call Templates

### 环境变量约定

```
~/.config/api_keys.env
  export LLM_API_KEY="sk-..."
  export LLM_API_BASE="https://your-gateway/v1"
```

权限必须 `600`,详见 [SETUP.md](SETUP.md)。

### Chat / Completion

```bash
source ~/.config/api_keys.env && \
curl -s --noproxy '*' "$LLM_API_BASE/chat/completions" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg m "MODEL_NAME" --arg p "PROMPT" \
    '{model:$m, messages:[{role:"user",content:$p}], temperature:0.3}')" \
  | jq -r '.choices[0].message.content'
```

### ASR(语音转文字)

```bash
ffmpeg -i input.mp4 -vn -ab 64k /tmp/audio.mp3 -y 2>/dev/null
source ~/.config/api_keys.env && \
curl -s --noproxy '*' "$LLM_API_BASE/audio/transcriptions" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -F "file=@/tmp/audio.mp3" \
  -F "model=ASR_MODEL" \
  -F "response_format=verbose_json"
```

### TTS(文字转语音)

```bash
source ~/.config/api_keys.env && \
curl -s --noproxy '*' "$LLM_API_BASE/audio/speech" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"TTS_MODEL","input":"文本","voice":"VOICE_NAME"}' \
  --output out.mp3
```

> ⚠️ 不同服务商的 voice 名不同(OpenAI 用 `alloy/nova`,阿里 Qwen 用 `Cherry/Ethan`)。先用 `verify.sh` 探测,或查服务商文档。

### 内网代理坑(中国大陆/公司内网)

**必须加 `--noproxy '*'`**。Claude Code 环境常设了 HTTP 代理,如果不绕开会被代理拦截。

## 询问话术模板 — Confirmation Template

每次必须用这个结构:

```
**需求识别**:[1-2 句复述任务,标注语言/体量/精度]

**推荐方案**:
- 步骤 1:[具体操作,如 ffmpeg 抽音轨]
- 步骤 2:[模型 + 理由]
- 步骤 3(可选):[后处理]

**预估成本**:[¥X-Y / 任务规模]

[AskUserQuestion 列出 2-4 个选项让用户拍板]
```

## Prompt 来源 — Prompt Source(转换类任务必询问)

**触发场景**:涉及"文档→md"、"翻译"、"改写"、"总结"等需要 system prompt 主导的任务时。

**强制流程**:推荐模型之后、执行之前,**必须用 AskUserQuestion 问用户 prompt 从哪来**:

| 选项 | 行为 |
|---|---|
| A. 用我自己的提示词 | 优先级:① 用户对话里贴的 → ② `~/.config/llm-prompts/<task>.md`(规范化路径) → ③ 用户指定的其他本地路径 → 都没有时 fallback 到默认 |
| B. 用 skill 内置默认 | 走 skill 自带的简化 system prompt(适合简单整理) |
| C. 默认 + 我加补充 | 默认 prompt + 用户对话里补充几条规则 |
| D. 我现在贴一份 | 用户在对话里贴新 prompt,本次直接用,不存档 |

**推荐的本地提示词组织方式**(可选):

```
~/.config/llm-prompts/
├── pdf-to-md.md         # PDF 转 markdown
├── translate-zh-en.md   # 中译英
├── lesson-rewrite.md    # 讲义改写
└── ...
```

skill 触发"PDF 转 md"任务时,自动检查 `~/.config/llm-prompts/pdf-to-md.md` 是否存在;翻译任务自动检查 `translate-*.md`;以此类推。**不存在则走默认**,无需任何配置。

**优先级**:对话里临时贴 > 用户指定本地路径 > 默认本地文件 > skill 默认。

**绝对禁止**:跳过这一步直接用默认 prompt 转换重要文档。用户提示词通常包含针对性规则(如序号格式、框注处理、删例题等),用默认 prompt 会丢失这些细节。

## 红旗 — Red Flags(出现立刻 STOP)

- ⛔ 没询问用户直接调外部模型 → 退回询问
- ⛔ 把 key 内容打印到终端/对话 → 立刻撤回,只显示前 10 字符
- ⛔ 用户在对话里粘了 key → 走"安全第一"流程
- ⛔ 跳过 `--noproxy '*'` → 调用会失败,排查时先加上
- ⛔ 用户没说"批量"就默认用 flash/haiku 廉价档 → 改用主力档
- ⛔ 任务明显适合外部模型却让当前 Claude 硬扛(如视频转写) → 切外部

## 常见误判 — Common Mistakes

| 误判 | 正确做法 |
|---|---|
| "用户给了视频文件,直接 Read 它" | Read 不能读视频 → 必须 ffmpeg 抽音轨 + ASR |
| "中文转写用 GPT 模型" | 中文优先 Qwen ASR,GPT 是英文档 |
| "PDF 直接喂给模型" | 大多数模型不收 PDF → 先 pdftotext 或 mineru 提文本 |
| "调外部模型不用 source env" | 必须 source,否则 `$LLM_API_KEY` 是空 |
| "可以省略 --noproxy '*'" | 内网/代理环境会失败,加上没坏处 |

## 使用流程 — Workflow

```
任务来了
  ↓
检查 ~/.config/api_keys.env 是否存在
  ├─ 不存在 → 引导用户跑 setup.sh
  └─ 存在
       ↓
     查 MODELS.md 找首选模型
       ↓
     AskUserQuestion 确认(除非用户说免询问)
       ↓
     Bash + curl 调用
       ↓
     整理输出给用户
```

## 文档导航 — Documentation

- **[SETUP.md](SETUP.md)** — 安装指南(首次使用必读)
- **[MODELS.md](MODELS.md)** — 完整任务-模型映射表
- **[FAQ.md](FAQ.md)** — 常见问题(含"能不能粘 key 到对话")
- **[examples/](examples/)** — 端到端示例(PDF/视频/TTS)
- **[scripts/setup.sh](scripts/setup.sh)** — 一键安装
- **[scripts/verify.sh](scripts/verify.sh)** — 验证安装+列模型

## 与其他 Skill 协作

| 场景 | 协作方式 |
|---|---|
| 视频**生成** | 走专用 skill(如 volc-video),不走本规则 |
| 写代码生成脚本 | 先走 karpathy-guidelines |
| 头脑风暴新功能 | 先走 brainstorming |

---

**License**: MIT。Issue/PR 欢迎到 GitHub repo。
