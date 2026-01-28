#!/bin/bash

# 檢查參數
if [ -z "$1" ]; then
    echo "Usage: $0 <model_name>"
    echo "Example: $0 openai/qwen2.5:7b"
    echo "Available local models (Ollama):"
    ollama list
    exit 1
fi

MODEL_NAME=$1
PROJECT_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"
ENV_FILE="$PROJECT_DIR/.env"
PLIST_LABEL="com.clawd.bot"

# 更新 .env
if [ -f "$ENV_FILE" ]; then
    # 如果 AGENT_MODEL 存在，則替換；否則新增
    if grep -q "AGENT_MODEL=" "$ENV_FILE"; then
        # 使用 sed 將整行替換掉 (相容 macOS sed)
        sed -i '' "s|^AGENT_MODEL=.*|AGENT_MODEL=$MODEL_NAME|" "$ENV_FILE"
    else
        echo "AGENT_MODEL=$MODEL_NAME" >> "$ENV_FILE"
    fi
    echo "✅ Updated .env: AGENT_MODEL=$MODEL_NAME"
else
    echo "❌ Error: .env file not found at $ENV_FILE"
    exit 1
fi

# 重啟服務
echo "🔄 Restarting Clawdbot service..."
if launchctl list | grep -q "$PLIST_LABEL"; then
    launchctl kickstart -k "gui/$(id -u)/$PLIST_LABEL"
    echo "✅ Service restarted successfully!"
else
    echo "⚠️ Service not found in launchctl. Please check if it's loaded."
    echo "Try running: launchctl load ~/Library/LaunchAgents/$PLIST_LABEL.plist"
fi

echo "🎉 Done! Switched to model: $MODEL_NAME"
