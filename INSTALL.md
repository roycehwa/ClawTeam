# ClawTeam 修复版 - 使用 OpenClaw 本地 Agent

## 问题
原版 ClawTeam 依赖 `claude` 命令（Claude Code CLI），需要登录 Anthropic 账号。

## 解决方案
使用 `clawteam-agent` 包装器，调用 `openclaw agent --local`，无需登录即可使用。

## 安装

### 1. 安装修改版 ClawTeam
```bash
git clone https://github.com/roycehwa/ClawTeam.git
cd ClawTeam
pip install -e .
```

### 2. 创建 clawteam-agent 脚本
创建 `/usr/local/bin/clawteam-agent`：

```bash
#!/bin/bash
# Custom Agent for ClawTeam - Uses OpenClaw local agent

set -e

# Parse arguments
PROMPT=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      echo "ClawTeam-Agent 1.0.0"
      exit 0
      ;;
    *)
      PROMPT="$PROMPT $1"
      shift
      ;;
  esac
done

# Read from stdin if no prompt
if [ -z "$PROMPT" ]; then
  PROMPT=$(cat)
fi

# Load API keys
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Run openclaw agent
SESSION_ID="clawteam-$(date +%s)-$$"
exec openclaw agent --local --message "$PROMPT" --session-id "$SESSION_ID" --timeout 300
```

```bash
chmod +x /usr/local/bin/clawteam-agent
```

### 3. 配置 API Key
设置环境变量：
```bash
export TENCENT_API_KEY="your-key-here"
# 或
export OPENAI_API_KEY="your-key-here"
```

## 使用

```bash
clawteam spawn -t my-team -n my-agent --task "创建 hello.txt 文件"
```

## 修改内容

1. **cli/commands.py**: 默认命令从 `claude` 改为 `clawteam-agent`
2. **spawn/tmux_backend.py**: 识别 `clawteam-agent` 为有效的交互式 CLI

## 测试

```bash
cd /tmp
clawteam spawn -t test -n verify --task "创建文件 test.txt，内容为'works!'"
```
