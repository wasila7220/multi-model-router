# FAQ(常见问题)

[English](#english) | [中文](#中文)

---

## English

### 🔒 Q1: Can I paste my API key directly into the chat with Claude?

**Short answer: No. Use `setup.sh` instead.**

**Why?**

Conversation history is **persisted** in multiple places:

1. **Local Claude Code transcripts** — `~/.claude/projects/<dir>/<session>.jsonl` retains full conversation
2. **Anthropic's prompt cache** — sent prompts are cached for ~5 minutes server-side
3. **Third-party syncs** — if you use skills like `save-to-wiki`, the key may end up in your Obsidian vault, GitHub, or shared notes
4. **Screen recordings / screenshots** — if you share a screen recording or screenshot, the key is visible
5. **Copy-paste accidents** — keys in chat are easy to accidentally paste somewhere else

**Even if you delete the message, copies persist.**

**What if I already pasted it?** Take these steps immediately:

1. Go to your provider's dashboard and **revoke** the key
2. **Create a new key**
3. Run `setup.sh` and enter the new key (hidden input)
4. Optionally: clear conversation history if your Claude Code config saves it

### Q2: How does `setup.sh` keep my key safe?

- **Hidden input** — `read -s` doesn't echo the key to the terminal
- **No shell history** — input via `read` doesn't go into `~/.bash_history` or `~/.zsh_history`
- **File permission 600** — only your user can read `~/.config/api_keys.env`
- **Never echoed** — no command in the skill ever prints the key to logs/output

### Q3: My provider isn't in the list. Can I still use this skill?

Yes. As long as the provider exposes an **OpenAI-compatible API** (i.e., supports `POST /v1/chat/completions` with `model`/`messages` fields), choose "Custom" in `setup.sh` and enter the endpoint URL.

Common compatible endpoints:
- `https://your-provider.com/v1`
- `https://your-self-hosted.com/api/v1`

### Q4: Can I switch providers?

Yes. Just re-run `setup.sh` — it overwrites the previous config. Or edit `~/.config/api_keys.env` directly:

```bash
export LLM_API_KEY="new-key"
export LLM_API_BASE="new-endpoint/v1"
```

### Q5: How do I see what models are available with my key?

```bash
bash ~/.claude/skills/multi-model-router/scripts/verify.sh
```

It calls `GET /v1/models` and prints the list.

### Q6: What if a model returns empty content?

Some "thinking" models (e.g., GPT-5+ family, GLM-5.1+) consume tokens for internal reasoning before producing output. If `max_tokens` is too small (like 10), the budget is consumed by thinking tokens and the visible content is empty.

**Fix:** Set `max_tokens >= 1000` (or higher for reasoning-heavy tasks).

### Q7: Will Claude automatically pick the cheapest model?

**No, not by default.** The skill recommends models based on **task suitability**, not cost. If you say "do this cheaply" or "batch process", it'll switch to flash/haiku tier.

### Q8: Does this affect my Claude Code subscription quota?

**No.** External model calls go through your gateway's API key, not Anthropic's Claude Code subscription. They are billed separately by the gateway provider.

### Q9: Can the skill use my own prompts?

**Yes — that's a core feature.** When the task involves transforming text (PDF→md, translation, rewriting, etc.), the skill **must ask** which prompt to use:

| Option | Behavior |
|---|---|
| A. My own prompt | Reads from `~/.config/llm-prompts/pdf-to-md.md` or another path you specify |
| B. Skill's default | Uses a built-in simple prompt |
| C. Default + my additions | Default prompt plus what you say in chat |
| D. Paste new one now | You paste the prompt in this turn |

Place reusable prompts at `~/.config/llm-prompts/pdf-to-md.md` (the skill knows this default location).

### Q10: How do I update the skill?

```bash
cd ~/.claude/skills/multi-model-router
git pull
bash scripts/verify.sh  # confirm still working
```

---

## 中文

### 🔒 Q1: 我能不能把 API key 直接粘到与 Claude 的对话里?

**简答:不能。请用 `setup.sh`。**

**为什么?**

对话历史会**持久化**保存在多个地方:

1. **本地 Claude Code 会话日志** — `~/.claude/projects/<dir>/<session>.jsonl` 保留完整对话
2. **Anthropic 的 prompt 缓存** — 已发送的 prompt 在服务端缓存约 5 分钟
3. **第三方同步** — 如果你用 `save-to-wiki` 等 skill,key 可能进入 Obsidian、GitHub、分享笔记
4. **屏幕录制/截图** — 录屏或截图分享时 key 会暴露
5. **复制粘贴意外** — 对话里的 key 容易被无意中粘到别处

**即使删除消息,副本仍存在。**

**已经粘了怎么办?** 立刻执行:

1. 去服务商后台 **revoke** 旧 key
2. **生成新 key**
3. 跑 `setup.sh` 输入新 key(隐藏输入)
4. 可选:清理 Claude Code 的会话历史(如果配置了保存)

### Q2: `setup.sh` 怎么保护我的 key?

- **隐藏输入** — `read -s` 不会在终端回显
- **不进 history** — `read` 输入不进 `~/.bash_history` 或 `~/.zsh_history`
- **文件权限 600** — 只有你能读 `~/.config/api_keys.env`
- **永不打印** — skill 里的所有命令都不会把 key 输出到日志/控制台

### Q3: 我的服务商不在列表里,还能用吗?

能。只要服务商提供 **OpenAI 兼容的 API**(即支持 `POST /v1/chat/completions`,带 `model`/`messages` 字段),在 `setup.sh` 里选 "Custom" 输入 endpoint URL 即可。

常见兼容 endpoint:
- `https://your-provider.com/v1`
- `https://your-self-hosted.com/api/v1`

### Q4: 我能切换服务商吗?

能。重跑 `setup.sh` 即可覆盖。或直接编辑 `~/.config/api_keys.env`:

```bash
export LLM_API_KEY="新key"
export LLM_API_BASE="新endpoint/v1"
```

### Q5: 怎么看我这把 key 能用哪些模型?

```bash
bash ~/.claude/skills/multi-model-router/scripts/verify.sh
```

它会调 `GET /v1/models` 列出清单。

### Q6: 模型返回空内容怎么办?

一些"思考型"模型(如 GPT-5+ 系列、GLM-5.1+)在生成可见内容前会消耗 token 做内部推理。如果 `max_tokens` 太小(比如 10),预算被思考 token 占完,可见内容就空。

**解决**:把 `max_tokens` 设到 `>= 1000`(推理任务更高)。

### Q7: skill 会自动挑最便宜的模型吗?

**不会(默认)。** skill 按"任务匹配度"推荐,不是按价格。如果你说"便宜处理"、"批量处理",会切到 flash/haiku 档。

### Q8: 这会影响我的 Claude Code 订阅额度吗?

**不会。** 外部模型调用走的是你网关的 API key,不是 Anthropic 的 Claude Code 订阅。账单由网关服务商单独出。

### Q9: skill 能用我自己的 prompt 吗?

**能 — 这是核心功能。** 当任务涉及文本转换(PDF→md、翻译、改写等),skill **必须询问**用哪份 prompt:

| 选项 | 行为 |
|---|---|
| A. 用我自己的 | 从 `~/.config/llm-prompts/pdf-to-md.md` 或你指定的路径读 |
| B. skill 默认 | 用内置简化 prompt |
| C. 默认 + 我补充 | 默认 prompt + 对话里你说的几条 |
| D. 现在贴新的 | 你在本轮对话里贴 prompt |

把可复用的 prompt 放在 `~/.config/llm-prompts/pdf-to-md.md`(skill 知道这个默认位置)。

### Q10: 怎么更新 skill?

```bash
cd ~/.claude/skills/multi-model-router
git pull
bash scripts/verify.sh  # 确认仍能用
```
