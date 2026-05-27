# Task-to-Model Mapping(任务-模型映射手册)

[English](#english) | [中文](#中文)

> **Note:** This is the **selection guide** the skill consults. Actual available models depend on your gateway. Run `verify.sh` to see what your key exposes.
>
> **说明**:这是 skill 推荐模型时参考的依据。实际可用模型取决于你的网关。跑 `verify.sh` 查询你这把 key 暴露的清单。

---

## English

### Model Family Tiers

| Tier | Family | Examples | Use For |
|---|---|---|---|
| 🏆 **Top Reasoning** | Claude Opus, GPT-5+, DeepSeek-R1 | `claude-opus-4-7`, `gpt-5.5`, `deepseek-r1` | Complex agents, multi-step reasoning, hardest problems |
| ⚡ **Workhorse** | Claude Sonnet, GPT-5/4, DeepSeek V3, Kimi K2 | `claude-sonnet-4-6`, `gpt-5.4`, `deepseek-v4-pro`, `kimi-k2.6` | 90% of daily tasks |
| 💨 **Fast/Cheap** | Claude Haiku, DeepSeek Flash, GLM, GPT-mini | `claude-haiku-4-5`, `deepseek-v4-flash`, `glm-5`, `gpt-5.4-mini` | Batch processing, classification, tagging |
| 💻 **Code-Specialized** | GPT-Codex, DeepSeek-Coder | `gpt-5.3-codex`, `deepseek-coder-v3` | Code completion, refactoring |
| 🎙️ **Audio (CN)** | Qwen ASR/TTS | `qwen3-asr-flash`, `qwen3-tts-flash` | Chinese transcription/synthesis (best in class) |
| 🎙️ **Audio (EN)** | OpenAI Audio | `gpt-4o-mini-transcribe`, `gpt-4o-transcribe-diarize`, `gpt-4o-mini-tts` | English transcription, speaker diarization |
| 🖼️ **Vision** | Claude Sonnet/Opus, GPT-4o | `claude-sonnet-4-6`, `gpt-4o` | Image understanding, charts, OCR |

### Task Mapping

#### Document Conversion

| Task | First Choice | Second Choice | Why |
|---|---|---|---|
| PDF → md (Chinese, regular layout) | DeepSeek V3 family | Kimi K2 | Best Chinese layout, very cheap |
| PDF → md (English/academic with formulas) | Claude Sonnet | GPT-5/4 | Best at tables and equations |
| PDF → md (scanned, OCR needed) | MinerU (offline tool) + Qwen VL OCR | — | Use offline first, model for fallback |
| Word → structured md | Claude Sonnet | DeepSeek V3 | Layout fidelity |
| Long document summary (> 200K chars) | Kimi K2 | — | Longest context window |

#### Audio / Video

| Task | First Choice | Second Choice | Why |
|---|---|---|---|
| Chinese video → text with timestamps | `qwen3-asr-flash` (extract audio first via ffmpeg) | — | Only top-tier Chinese ASR available |
| English video → text | `gpt-4o-mini-transcribe` | — | English-optimized |
| Multi-speaker (interviews, meetings) | `gpt-4o-transcribe-diarize` | — | Only one with diarization |
| Chinese TTS | `qwen3-tts-flash` (voices: Cherry/Ethan/Chelsie/etc.) | — | Best Chinese voices |
| English TTS | `gpt-4o-mini-tts` (voices: alloy/nova/etc.) | — | OpenAI voice quality |
| **Video generation** | (Out of scope — use Volcengine Seedance, Kling, or other dedicated video skill) |

#### Text Processing

| Task | First Choice | Second Choice | Why |
|---|---|---|---|
| Chinese creative writing | DeepSeek V3 family | Kimi K2, Mimo | Strong literary quality |
| English creative writing | Claude Sonnet/Opus | GPT-5+ | Style/voice |
| Translation (literary) | Claude Sonnet | DeepSeek V3 | Tone preservation |
| Translation (technical) | DeepSeek V3 | Claude Sonnet | Terminology accuracy |
| Math / logic problems | DeepSeek V3 (or R1) | Claude Opus | Reasoning depth |
| Code generation | (current Claude session) → Claude Sonnet/Codex | GPT-5.3-codex | Tool use + Karpathy guidelines |
| Batch text processing (cheap) | DeepSeek Flash | Claude Haiku | Lowest unit cost |
| Structured extraction (JSON) | Claude Sonnet, Mimo, DeepSeek V3 | GPT-5.4 | Reliable JSON output |

#### Vision

| Task | First Choice | Second Choice | Why |
|---|---|---|---|
| Chart/graph data extraction | Claude Sonnet | GPT-4o | Numeric precision |
| OCR (Chinese, single image) | Qwen VL OCR (if available) → Claude Sonnet | GPT-4o | Chinese accuracy |
| Document image understanding | Claude Sonnet | GPT-4o | Layout reasoning |
| PPT/slide visual analysis | Claude Sonnet | GPT-4o | Mixed text+visual |

#### Agent / Tool Use

| Task | First Choice | Second Choice | Why |
|---|---|---|---|
| Complex multi-step agent | Claude Opus | GPT-5.5 | Best tool calling |
| Web search + summarize | (current Claude with built-in WebSearch) | — | Native support |
| Coding agent | Claude Sonnet | DeepSeek V3 | Tool use stability |

### Decision Cheatsheet

```
Is the task CHINESE?
  Audio? → qwen3-asr-flash / qwen3-tts-flash
  Document? → deepseek-v4-pro family
  Long text (>200K)? → kimi-k2.6
  Otherwise? → deepseek-v4-pro or claude-sonnet

Is the task ENGLISH or technical?
  Audio? → gpt-4o-* family
  Code? → claude-sonnet or gpt-5.3-codex
  Otherwise? → claude-sonnet or gpt-5.4

Is the task BATCH/CHEAP?
  → deepseek-v4-flash or claude-haiku-4-5

Is the task COMPLEX REASONING?
  → claude-opus-4-7 or gpt-5.5
```

---

## 中文

### 模型家族档位

| 档位 | 家族 | 示例 | 适合 |
|---|---|---|---|
| 🏆 **顶级推理** | Claude Opus、GPT-5+、DeepSeek-R1 | `claude-opus-4-7`、`gpt-5.5`、`deepseek-r1` | 复杂 Agent、多步推理、最难任务 |
| ⚡ **主力性价比** | Claude Sonnet、GPT-5/4、DeepSeek V3、Kimi K2 | `claude-sonnet-4-6`、`gpt-5.4`、`deepseek-v4-pro`、`kimi-k2.6` | 日常 90% 任务 |
| 💨 **快速廉价** | Claude Haiku、DeepSeek Flash、GLM、GPT-mini | `claude-haiku-4-5`、`deepseek-v4-flash`、`glm-5`、`gpt-5.4-mini` | 批处理、分类、打标 |
| 💻 **代码专用** | GPT-Codex、DeepSeek-Coder | `gpt-5.3-codex`、`deepseek-coder-v3` | 代码补全、重构 |
| 🎙️ **语音(中)** | Qwen ASR/TTS | `qwen3-asr-flash`、`qwen3-tts-flash` | 中文转写/合成(顶级) |
| 🎙️ **语音(英)** | OpenAI Audio | `gpt-4o-mini-transcribe`、`gpt-4o-transcribe-diarize`、`gpt-4o-mini-tts` | 英文转写、说话人分离 |
| 🖼️ **视觉** | Claude Sonnet/Opus、GPT-4o | `claude-sonnet-4-6`、`gpt-4o` | 图像理解、图表、OCR |

### 任务映射

#### 文档转换

| 任务 | 首选 | 备选 | 理由 |
|---|---|---|---|
| PDF → md(中文,普通版式) | DeepSeek V3 系列 | Kimi K2 | 中文版式还原最好,价格极低 |
| PDF → md(英文/学术含公式) | Claude Sonnet | GPT-5/4 | 表格公式精度 |
| PDF → md(扫描件需 OCR) | MinerU(离线) + Qwen VL OCR | — | 离线优先,模型兜底 |
| Word → 结构化 md | Claude Sonnet | DeepSeek V3 | 版式还原 |
| 长文档总结(> 20 万字) | Kimi K2 | — | 上下文最长 |

#### 音视频

| 任务 | 首选 | 备选 | 理由 |
|---|---|---|---|
| 中文视频 → 带时间戳文字 | `qwen3-asr-flash`(先 ffmpeg 抽音轨) | — | 唯一顶级中文 ASR |
| 英文视频 → 文字 | `gpt-4o-mini-transcribe` | — | 英文优化 |
| 多人对话(采访/会议) | `gpt-4o-transcribe-diarize` | — | 唯一带说话人分离 |
| 中文 TTS | `qwen3-tts-flash`(音色:Cherry/Ethan/Chelsie 等) | — | 中文音色最好 |
| 英文 TTS | `gpt-4o-mini-tts`(音色:alloy/nova 等) | — | OpenAI 音色 |
| **视频生成** | (不在本 skill 范围 — 走火山 Seedance、可灵或其他专用 skill) |

#### 文本处理

| 任务 | 首选 | 备选 | 理由 |
|---|---|---|---|
| 中文创意写作 | DeepSeek V3 系列 | Kimi K2、Mimo | 文学性强 |
| 英文创意写作 | Claude Sonnet/Opus | GPT-5+ | 文风把控 |
| 翻译(文学) | Claude Sonnet | DeepSeek V3 | 语气保留 |
| 翻译(技术) | DeepSeek V3 | Claude Sonnet | 术语准确 |
| 数学/逻辑题 | DeepSeek V3(或 R1) | Claude Opus | 推理深度 |
| 代码生成 | (当前 Claude 会话) → Claude Sonnet/Codex | GPT-5.3-codex | 工具调用 + Karpathy 准则 |
| 批量文本处理(廉价) | DeepSeek Flash | Claude Haiku | 单价最低 |
| 结构化提取(JSON) | Claude Sonnet、Mimo、DeepSeek V3 | GPT-5.4 | JSON 输出可靠 |

#### 视觉

| 任务 | 首选 | 备选 | 理由 |
|---|---|---|---|
| 图表/坐标图数据提取 | Claude Sonnet | GPT-4o | 数值精度 |
| OCR(中文单图) | Qwen VL OCR(若可用) → Claude Sonnet | GPT-4o | 中文准确率 |
| 文档图片理解 | Claude Sonnet | GPT-4o | 版式推理 |
| PPT/课件视觉分析 | Claude Sonnet | GPT-4o | 文+图混合 |

#### Agent / 工具调用

| 任务 | 首选 | 备选 | 理由 |
|---|---|---|---|
| 复杂多步 Agent | Claude Opus | GPT-5.5 | 工具调用最稳 |
| 网页搜索+总结 | (当前 Claude 内置 WebSearch) | — | 原生支持 |
| 编码 Agent | Claude Sonnet | DeepSeek V3 | 工具调用稳定性 |

### 决策速查

```
任务是中文吗?
  音频? → qwen3-asr-flash / qwen3-tts-flash
  文档? → deepseek-v4-pro 系列
  长文(>20万字)? → kimi-k2.6
  其他? → deepseek-v4-pro 或 claude-sonnet

任务是英文/技术?
  音频? → gpt-4o-* 系列
  代码? → claude-sonnet 或 gpt-5.3-codex
  其他? → claude-sonnet 或 gpt-5.4

任务是批处理/省钱?
  → deepseek-v4-flash 或 claude-haiku-4-5

任务是复杂推理?
  → claude-opus-4-7 或 gpt-5.5
```
