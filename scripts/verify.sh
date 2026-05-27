#!/usr/bin/env bash
# multi-model-router verify
# 验证 ~/.config/api_keys.env 配置是否正确,列出可用模型
# 用法: bash scripts/verify.sh

set -uo pipefail  # 不用 -e,要让单个模型失败时继续

ENV_FILE="$HOME/.config/api_keys.env"

G='\033[0;32m'; Y='\033[0;33m'; R='\033[0;31m'; N='\033[0m'

# 1. 检查 env 文件
if [[ ! -f "$ENV_FILE" ]]; then
  echo -e "${R}❌ 未找到 $ENV_FILE${N}"
  echo "请先运行: bash scripts/setup.sh"
  exit 1
fi

# shellcheck source=/dev/null
source "$ENV_FILE"

if [[ -z "${LLM_API_KEY:-}" || -z "${LLM_API_BASE:-}" ]]; then
  echo -e "${R}❌ env 文件缺少 LLM_API_KEY 或 LLM_API_BASE${N}"
  exit 1
fi

# 2. 显示配置(key 只显示前缀)
key_preview="${LLM_API_KEY:0:8}...${LLM_API_KEY: -4}"
echo "Endpoint: $LLM_API_BASE"
echo "Key:      $key_preview"
echo ""

# 3. 列模型
echo "列出可用模型..."
resp=$(curl -s --noproxy '*' "$LLM_API_BASE/models" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -w "\nHTTP_CODE:%{http_code}")

http_code=$(echo "$resp" | grep -oE 'HTTP_CODE:[0-9]+' | cut -d: -f2)
body=$(echo "$resp" | sed '/^HTTP_CODE/d')

if [[ "$http_code" != "200" ]]; then
  echo -e "${R}❌ HTTP $http_code${N}"
  echo "$body" | head -c 500
  echo ""
  echo ""
  echo "排查:"
  echo "  - 401: key 无效"
  echo "  - 404: endpoint 路径错(应该带 /v1)"
  echo "  - 000: 网络/代理问题(已加 --noproxy '*')"
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo -e "${Y}⚠️  未安装 jq,无法解析模型列表${N}"
  echo "$body" | head -c 1000
  exit 0
fi

models=$(echo "$body" | jq -r '.data[].id' 2>/dev/null | sort)
count=$(echo "$models" | wc -l | tr -d ' ')

echo -e "${G}✅ 网关连通,共 $count 个模型可用${N}"
echo ""
echo "$models" | sed 's/^/  /'
echo ""

# 4. 冒烟测试一个 chat 模型(挑列表里第一个看起来是 chat 的)
chat_model=$(echo "$models" | grep -iE '^(gpt|claude|deepseek|kimi|glm|qwen[0-9]|llama)' | grep -ivE 'tts|asr|transcribe|embed' | head -1)

if [[ -n "$chat_model" ]]; then
  echo "冒烟测试 chat 模型: $chat_model"
  test_resp=$(curl -s --noproxy '*' "$LLM_API_BASE/chat/completions" \
    -H "Authorization: Bearer $LLM_API_KEY" \
    -H "Content-Type: application/json" \
    --max-time 30 \
    -d "$(jq -n --arg m "$chat_model" '{model:$m, messages:[{role:"user",content:"回复 OK"}], max_tokens:50}')" \
    -w "\nHTTP_CODE:%{http_code}")

  test_code=$(echo "$test_resp" | grep -oE 'HTTP_CODE:[0-9]+' | cut -d: -f2)
  test_content=$(echo "$test_resp" | sed '/^HTTP_CODE/d' | jq -r '.choices[0].message.content // "(no content)"' 2>/dev/null | head -c 100)

  if [[ "$test_code" == "200" ]]; then
    echo -e "${G}✅ Chat 测试通过${N} → $test_content"
  else
    echo -e "${Y}⚠️  Chat 测试 HTTP $test_code(模型可能需要不同参数)${N}"
  fi
else
  echo -e "${Y}⚠️  未识别到 chat 模型,跳过冒烟测试${N}"
fi

echo ""
echo "下一步: 在 Claude Code 里说出你的任务,会自动用 multi-model-router 路由。"
