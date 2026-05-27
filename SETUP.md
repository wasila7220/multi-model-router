# Setup Guide(安装指南)

[English](#english) | [中文](#中文)

---

## English

### Prerequisites

- **Claude Code** installed (this is a Claude Code skill)
- **macOS / Linux** (Windows users: use WSL2)
- **`bash`, `curl`, `jq`** in PATH (jq optional but recommended)
- **An OpenAI-compatible API key** from one of:
  - [OpenRouter](https://openrouter.ai/keys) (aggregator)
  - [SiliconFlow 硅基流动](https://cloud.siliconflow.cn/account/ak) (China-friendly aggregator)
  - [DeepSeek](https://platform.deepseek.com/api_keys)
  - [Moonshot/Kimi](https://platform.moonshot.cn/console/api-keys)
  - [Alibaba DashScope (Qwen)](https://dashscope.console.aliyun.com/apiKey)
  - Your own self-hosted gateway (One-API / New-API / LiteLLM)

### Step 1 — Install the skill

Place this directory at `~/.claude/skills/multi-model-router/` (or any name; Claude Code reads from `~/.claude/skills/`).

```bash
# Option A: clone from GitHub
git clone https://github.com/YOUR_USERNAME/multi-model-router.git \
  ~/.claude/skills/multi-model-router

# Option B: if you downloaded a zip
unzip multi-model-router.zip -d ~/.claude/skills/
```

### Step 2 — Run setup.sh

```bash
bash ~/.claude/skills/multi-model-router/scripts/setup.sh
```

You'll be prompted for:

1. **Provider** — choose from a list (OpenRouter, SiliconFlow, …) or enter a custom endpoint
2. **API Key** — paste it; **input is hidden**, won't be echoed to terminal

The script writes `~/.config/api_keys.env` with mode 600 (only you can read it):

```bash
export LLM_API_KEY="sk-..."
export LLM_API_BASE="https://your-endpoint/v1"
```

### Step 3 — Verify

`setup.sh` automatically calls `verify.sh` at the end. Or run manually:

```bash
bash ~/.claude/skills/multi-model-router/scripts/verify.sh
```

Expected output:

```
Endpoint: https://...
Key:      sk-xxxxxx...xxxx
✅ Gateway connected, N models available
  claude-sonnet-4-6
  deepseek-v4-pro
  ...
✅ Chat test passed → OK
```

### Step 4 — Use in Claude Code

Just describe a task. The skill activates automatically when keywords match.

Examples that trigger the router:

- "transcribe this video" / "把这个视频转写成文字"
- "convert this PDF to markdown" / "把这个 PDF 转成 md"
- "use deepseek to translate this" / "用 deepseek 翻译"
- "which model is best for X?" / "X 任务用哪个模型最好"

Claude will:
1. Identify the task
2. Recommend a model with rationale
3. Ask you to confirm
4. Execute via Bash + curl

### Troubleshooting

**`HTTP 000` or "Could not resolve host"**:
- Inside corporate networks/Mainland China, set HTTP proxy or use a domestic provider.
- The skill always adds `--noproxy '*'` for `curl` to bypass proxies; if you need a proxy, edit the calls.

**`HTTP 401`**:
- Key invalid. Re-run `setup.sh`.

**`HTTP 404` on `/v1/models`**:
- Wrong endpoint. The base URL should usually end in `/v1`. Examples:
  - `https://api.deepseek.com/v1` ✅
  - `https://api.deepseek.com` ❌

**Models list empty `[]`**:
- Provider may not implement `/v1/models`. The skill works anyway — check provider docs for model names.

**Some models return empty content with `max_tokens: 10`**:
- Newer "thinking" models (e.g., GPT-5.5, GLM-5.1) need higher token budgets. Default to `max_tokens: 1000+`.

### Updating

```bash
cd ~/.claude/skills/multi-model-router
git pull
```

Re-run `verify.sh` to confirm everything still works.

---

## 中文

### 前置条件

- 已安装 **Claude Code**(这是 Claude Code 的 skill)
- **macOS / Linux** 系统(Windows 用户用 WSL2)
- PATH 里有 **`bash`、`curl`、`jq`**(jq 可选但推荐)
- 一把 **OpenAI 兼容的 API key**,可以来自:
  - [OpenRouter](https://openrouter.ai/keys)(聚合)
  - [硅基流动 SiliconFlow](https://cloud.siliconflow.cn/account/ak)(国内聚合)
  - [DeepSeek 官方](https://platform.deepseek.com/api_keys)
  - [Moonshot/Kimi 官方](https://platform.moonshot.cn/console/api-keys)
  - [阿里 DashScope(Qwen)](https://dashscope.console.aliyun.com/apiKey)
  - 你自己部署的网关(One-API / New-API / LiteLLM)

### 第一步 — 安装 skill

把本目录放到 `~/.claude/skills/multi-model-router/`(目录名任意,Claude Code 会扫 `~/.claude/skills/`)。

```bash
# 方式 A: 从 GitHub 克隆
git clone https://github.com/YOUR_USERNAME/multi-model-router.git \
  ~/.claude/skills/multi-model-router

# 方式 B: 下载 zip 后解压
unzip multi-model-router.zip -d ~/.claude/skills/
```

### 第二步 — 运行 setup.sh

```bash
bash ~/.claude/skills/multi-model-router/scripts/setup.sh
```

会提示输入:

1. **服务商** — 从列表选(OpenRouter、硅基流动……)或输入自定义 endpoint
2. **API Key** — 粘贴,**输入隐藏**,不会显示在终端

脚本会写入 `~/.config/api_keys.env`,权限 600(只有你能读):

```bash
export LLM_API_KEY="sk-..."
export LLM_API_BASE="https://your-endpoint/v1"
```

### 第三步 — 验证

`setup.sh` 末尾自动跑 `verify.sh`。也可以手动跑:

```bash
bash ~/.claude/skills/multi-model-router/scripts/verify.sh
```

预期输出:

```
Endpoint: https://...
Key:      sk-xxxxxx...xxxx
✅ 网关连通,共 N 个模型可用
  claude-sonnet-4-6
  deepseek-v4-pro
  ...
✅ Chat 测试通过 → OK
```

### 第四步 — 在 Claude Code 中使用

直接描述任务即可。skill 会在关键词匹配时自动激活。

会触发路由的任务示例:

- "帮我转写这个视频" / "transcribe this video"
- "把这个 PDF 转成 md" / "convert PDF to markdown"
- "用 deepseek 翻译" / "use deepseek to translate"
- "X 任务用哪个模型最好" / "which model is best for X"

Claude 会:
1. 识别任务
2. 推荐模型并说明理由
3. 询问你确认
4. Bash + curl 执行

### 故障排查

**`HTTP 000` 或 "Could not resolve host"**:
- 公司内网/大陆环境需要设置 HTTP 代理,或换用国内服务商
- skill 默认对 curl 加 `--noproxy '*'` 绕过代理;如需走代理,改调用

**`HTTP 401`**:
- key 无效,重新跑 `setup.sh`

**`/v1/models` 返回 `HTTP 404`**:
- endpoint 路径错。base URL 通常应该以 `/v1` 结尾:
  - `https://api.deepseek.com/v1` ✅
  - `https://api.deepseek.com` ❌

**模型列表是空数组 `[]`**:
- 服务商可能没实现 `/v1/models`。skill 仍然能用 — 查服务商文档拿模型名

**某些模型在 `max_tokens: 10` 时返回空内容**:
- 新一代"思考型"模型(如 GPT-5.5、GLM-5.1)需要更大的 token 预算。默认设为 `max_tokens: 1000+`

### 更新

```bash
cd ~/.claude/skills/multi-model-router
git pull
```

重跑 `verify.sh` 确认仍能用。
