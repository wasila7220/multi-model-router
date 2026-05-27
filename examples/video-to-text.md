# Example: Video → Text with Timestamps(视频转带时间戳文字)

## English

### Scenario

You have a Chinese course video (`.mp4`) and want a transcript with timestamps for note-taking, search, or subtitle generation.

### Critical: ASR models can't read video — extract audio first

```bash
# 1. Extract audio track (lightweight: 64kbps mono mp3 is enough for ASR)
ffmpeg -i course.mp4 -vn -ac 1 -ab 64k /tmp/course.mp3 -y

# 2. Send to qwen3-asr-flash (best Chinese ASR)
source ~/.config/api_keys.env

curl -s --noproxy '*' "$LLM_API_BASE/audio/transcriptions" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -F "file=@/tmp/course.mp3" \
  -F "model=qwen3-asr-flash" \
  -F "response_format=verbose_json" \
  > transcript.json

# 3. Format as markdown with timestamps
jq -r '.segments[] | "[\(.start | floor / 60 | floor):\(.start % 60 | floor)] \(.text)"' \
  transcript.json > transcript.md
```

### Output (sample)

```markdown
[0:0] 今天我们来讲解厄尔尼诺现象的成因和影响。
[0:4] 首先,我们要明白什么是厄尔尼诺。
[0:8] 这是一种发生在赤道东太平洋的海气异常现象。
...
```

### For long videos (> 1 hour)

Most ASR APIs limit single file to 25MB or 1 hour. Split with ffmpeg:

```bash
# Split into 10-min chunks
ffmpeg -i course.mp4 -vn -ac 1 -ab 64k -f segment -segment_time 600 \
  /tmp/course_%03d.mp3

# Process each, then merge JSONs offsetting timestamps
```

### English videos

Replace the model:

```bash
-F "model=gpt-4o-mini-transcribe"
```

### Multi-speaker (interview, meeting)

Use the diarization model:

```bash
-F "model=gpt-4o-transcribe-diarize"
```

This returns segments tagged by speaker.

### Cost (1 hour video)

- `qwen3-asr-flash`: ~¥0.5 - ¥1
- `gpt-4o-mini-transcribe`: ~¥3 - ¥5

---

## 中文

### 场景

你有一段中文课程视频(`.mp4`),想得到带时间戳的文字稿,用于做笔记、搜索、生成字幕。

### 关键认知:ASR 模型不能直接吃视频——必须先抽音轨

```bash
# 1. 抽音轨(64kbps 单声道 mp3 对 ASR 已足够,文件小)
ffmpeg -i course.mp4 -vn -ac 1 -ab 64k /tmp/course.mp3 -y

# 2. 发到 qwen3-asr-flash(最强中文 ASR)
source ~/.config/api_keys.env

curl -s --noproxy '*' "$LLM_API_BASE/audio/transcriptions" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -F "file=@/tmp/course.mp3" \
  -F "model=qwen3-asr-flash" \
  -F "response_format=verbose_json" \
  > transcript.json

# 3. 输出带时间戳的 markdown
jq -r '.segments[] | "[\(.start | floor / 60 | floor):\(.start % 60 | floor)] \(.text)"' \
  transcript.json > transcript.md
```

### 输出示例

```markdown
[0:0] 今天我们来讲解厄尔尼诺现象的成因和影响。
[0:4] 首先,我们要明白什么是厄尔尼诺。
[0:8] 这是一种发生在赤道东太平洋的海气异常现象。
...
```

### 长视频(> 1 小时)

大多数 ASR API 限制单文件 25MB 或 1 小时。用 ffmpeg 切片:

```bash
# 按 10 分钟切片
ffmpeg -i course.mp4 -vn -ac 1 -ab 64k -f segment -segment_time 600 \
  /tmp/course_%03d.mp3

# 逐片处理,合并 JSON 时记得加上时间戳偏移
```

### 英文视频

换模型:

```bash
-F "model=gpt-4o-mini-transcribe"
```

### 多人对话(采访/会议)

用带说话人分离的模型:

```bash
-F "model=gpt-4o-transcribe-diarize"
```

返回的 segments 会带 speaker 标签。

### 进阶:转写后再总结

```bash
# 转完文字稿后,继续调 LLM 整理为结构化笔记
TRANSCRIPT=$(cat transcript.md)

curl -s --noproxy '*' "$LLM_API_BASE/chat/completions" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg t "$TRANSCRIPT" '{
    model: "deepseek-v4-pro",
    messages: [
      {role: "system", content: "把这份带时间戳的口语转写整理成结构化讲义笔记。保留时间戳作为锚点。去掉口癖和重复。按主题分小节。"},
      {role: "user", content: $t}
    ]
  }')" | jq -r '.choices[0].message.content' > notes.md
```

### 成本(1 小时视频)

- `qwen3-asr-flash`:约 ¥0.5 - ¥1
- `gpt-4o-mini-transcribe`:约 ¥3 - ¥5
