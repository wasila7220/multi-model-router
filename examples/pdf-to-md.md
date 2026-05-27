# Example: PDF → Markdown(PDF 转 Markdown 示例)

## English

### Scenario

You have a PDF (in this case, a Chinese teaching analysis report) and want to convert it to clean markdown — preserving headings, tables, and marking image positions.

### Steps

```bash
# 1. Extract text from PDF (preserves layout)
pdftotext -layout "report.pdf" /tmp/report.txt

# 2. Send to deepseek-v4-pro for structure
source ~/.config/api_keys.env

curl -s --noproxy '*' "$LLM_API_BASE/chat/completions" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -H "Content-Type: application/json" \
  --max-time 180 \
  -d "$(jq -n --arg text "$(cat /tmp/report.txt)" '{
    model: "deepseek-v4-pro",
    messages: [
      {role: "system", content: "Convert this Chinese pdftotext output into clean GFM markdown. Identify heading levels with # ## ###. Convert tables to GFM. Keep original wording, no rewriting. Mark image positions with > [Image: <description>, manual insert needed]. Output markdown only, no preamble."},
      {role: "user", content: $text}
    ],
    temperature: 0.1,
    max_tokens: 8000
  }')" | jq -r '.choices[0].message.content' > "report.md"
```

### Tips

- For very long PDFs (>30 pages), split via `pdftotext -f START -l END` and process in chunks
- For scanned PDFs, run OCR first (MinerU recommended, offline)
- Extract images separately with `pdfimages -all` and reinsert manually using the placeholders

### Cost (1 hr ~ 8-page report)

DeepSeek V3 family: ¥0.01 - ¥0.10

---

## 中文

### 场景

你有一份 PDF(本例是中文授课分析报告),想转成结构化 markdown,保留标题层级、表格,并标记图片位置。

### 步骤

```bash
# 1. 提取 PDF 文本(保留版面)
pdftotext -layout "report.pdf" /tmp/report.txt

# 2. 发送给 deepseek-v4-pro 整理结构
source ~/.config/api_keys.env

curl -s --noproxy '*' "$LLM_API_BASE/chat/completions" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -H "Content-Type: application/json" \
  --max-time 180 \
  -d "$(jq -n --arg text "$(cat /tmp/report.txt)" '{
    model: "deepseek-v4-pro",
    messages: [
      {role: "system", content: "把这份 pdftotext 提取的中文文本整理为规范 GFM markdown。识别标题层级用 # ## ###,表格转为 GFM 格式,保持原始用语不改写。图片位置用引用块标注 > [此处原PDF有<图名>,需手动补图]。直接输出 markdown,不要任何前后说明。"},
      {role: "user", content: $text}
    ],
    temperature: 0.1,
    max_tokens: 8000
  }')" | jq -r '.choices[0].message.content' > "report.md"
```

### Tips

- PDF 较长(>30 页)时,用 `pdftotext -f START -l END` 分段处理
- 扫描件先 OCR(推荐 MinerU,离线)
- 用 `pdfimages -all` 单独导出图片,根据占位符手动补回

### 用你自己的 prompt(推荐)

如果你有针对特定文档类型的提示词(如教学讲义/真题/教材),建议放在 `~/.config/llm-prompts/pdf-to-md.md`,然后:

```bash
# 用本地 prompt 文件做 system message
SYS_PROMPT=$(cat ~/.config/llm-prompts/pdf-to-md.md)
TEXT=$(cat /tmp/report.txt)

curl -s --noproxy '*' "$LLM_API_BASE/chat/completions" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg s "$SYS_PROMPT" --arg t "$TEXT" '{
    model: "deepseek-v4-pro",
    messages: [
      {role: "system", content: $s},
      {role: "user", content: $t}
    ],
    temperature: 0.1,
    max_tokens: 8000
  }')" | jq -r '.choices[0].message.content' > report.md
```

### 成本(1 份约 8 页中文报告)

DeepSeek V3 系列: ¥0.01 - ¥0.10
