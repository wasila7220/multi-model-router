# Example: Text → Speech (TTS)(文字转语音示例)

## English

### Scenario

You have written content (lesson notes, summary, article) and want to generate Chinese audio narration — for podcasts, accessibility, listening-on-the-go.

### Steps

```bash
source ~/.config/api_keys.env

curl -s --noproxy '*' "$LLM_API_BASE/audio/speech" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3-tts-flash",
    "input": "今天我们来讲解厄尔尼诺现象。它的成因主要有三点。",
    "voice": "Cherry"
  }' \
  --output narration.mp3
```

### Voice Options

**qwen3-tts-flash (Chinese, verified Q2 2026):**

| Voice | Gender | Style |
|---|---|---|
| `Cherry` | Female | Standard, clear |
| `Chelsie` | Female | Warm |
| `Serena` | Female | News-anchor |
| `Jada` | Female | Lively |
| `Sunny` | Female | Cheerful |
| `Ethan` | Male | Standard |
| `Dylan` | Male | Deep |

> Voices like `zhixiaobai`, `longxiaochun`, `alloy`, `nova` are **NOT** supported by `qwen3-tts-flash`. Always test before deploying.

**gpt-4o-mini-tts (English):** `alloy`, `echo`, `fable`, `onyx`, `nova`, `shimmer`

### Long content (book chapters, lectures)

API has length limits per call. Split long text:

```bash
# Split a 10K-char article into ~1K chunks
csplit -k -f /tmp/chunk_ -b "%03d.txt" article.txt /./ 99

# Generate audio per chunk in parallel
for f in /tmp/chunk_*.txt; do
  out="${f%.txt}.mp3"
  TEXT=$(cat "$f")
  curl -s --noproxy '*' "$LLM_API_BASE/audio/speech" \
    -H "Authorization: Bearer $LLM_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg t "$TEXT" '{model:"qwen3-tts-flash", input:$t, voice:"Cherry"}')" \
    --output "$out" &
done
wait

# Concatenate
ffmpeg -f concat -safe 0 -i <(for f in /tmp/chunk_*.mp3; do echo "file '$f'"; done) \
  -c copy full_narration.mp3
```

### Tips

- **Pre-clean text** for TTS — remove "as shown in the figure", "see table 1", markdown markers; these don't translate to speech naturally
- **Pronunciation** of polyphonic Chinese characters may sometimes be wrong; spell out tricky words phonetically if critical (e.g., "重(zhòng)要")
- **Cost**: qwen3-tts-flash is roughly ¥0.001 per character

---

## 中文

### 场景

你已经写好讲义、总结、文章,想生成中文朗读音频 —— 用于播客、无障碍、通勤听材料。

### 步骤

```bash
source ~/.config/api_keys.env

curl -s --noproxy '*' "$LLM_API_BASE/audio/speech" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3-tts-flash",
    "input": "今天我们来讲解厄尔尼诺现象。它的成因主要有三点。",
    "voice": "Cherry"
  }' \
  --output narration.mp3
```

### 可用音色

**qwen3-tts-flash(中文,2026 Q2 实测可用):**

| 音色 | 性别 | 风格 |
|---|---|---|
| `Cherry` | 女 | 标准清晰 |
| `Chelsie` | 女 | 温暖 |
| `Serena` | 女 | 新闻播报 |
| `Jada` | 女 | 活泼 |
| `Sunny` | 女 | 阳光 |
| `Ethan` | 男 | 标准 |
| `Dylan` | 男 | 深沉 |

> ⚠️ 老的 `zhixiaobai`、`longxiaochun` 等以及 OpenAI 风格的 `alloy`、`nova` 在 `qwen3-tts-flash` **不可用**。先测后用。

**gpt-4o-mini-tts(英文):** `alloy`、`echo`、`fable`、`onyx`、`nova`、`shimmer`

### 长内容(书籍章节、讲义)

API 单次调用有长度限制。切片处理:

```bash
# 把万字文章切成 ~1K 字一片
csplit -k -f /tmp/chunk_ -b "%03d.txt" article.txt /./ 99

# 并行生成每片音频
for f in /tmp/chunk_*.txt; do
  out="${f%.txt}.mp3"
  TEXT=$(cat "$f")
  curl -s --noproxy '*' "$LLM_API_BASE/audio/speech" \
    -H "Authorization: Bearer $LLM_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg t "$TEXT" '{model:"qwen3-tts-flash", input:$t, voice:"Cherry"}')" \
    --output "$out" &
done
wait

# 拼接
ffmpeg -f concat -safe 0 -i <(for f in /tmp/chunk_*.mp3; do echo "file '$f'"; done) \
  -c copy full_narration.mp3
```

### Tips

- **TTS 前预清理文本** — 删掉"如图所示"、"见表 1"、markdown 标记;这些读出来不自然
- **多音字发音** 偶尔会错;关键词不放心可写拼音(如 "重(zhòng)要")
- **成本**:qwen3-tts-flash 约 ¥0.001/字

### 进阶:朗读前先用 LLM 改写

```bash
# 把 markdown 讲义改写成"朗读友好"文本,再 TTS
NOTES=$(cat lesson.md)

READABLE=$(curl -s --noproxy '*' "$LLM_API_BASE/chat/completions" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg t "$NOTES" '{
    model: "deepseek-v4-pro",
    messages: [
      {role: "system", content: "把这份 markdown 讲义改写成适合朗读的口语化文本。删除 markdown 标记、图片引用、表格(转为口述)、'如图所示'等文字版才有的表达。保留所有知识点。"},
      {role: "user", content: $t}
    ]
  }')" | jq -r '.choices[0].message.content')

# 然后用 qwen3-tts-flash 生成音频
echo "$READABLE" | head -c 2000 | curl ... # (省略,同上)
```
