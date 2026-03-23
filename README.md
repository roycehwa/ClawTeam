# ClawTeam (Fixed Version)

Multi-agent coordination CLI using OpenClaw local agent (no Claude Code login required).

## Quick Start

```bash
# Install
pip install git+https://github.com/roycehwa/ClawTeam.git

# Setup agent wrapper
sudo tee /usr/local/bin/clawteam-agent > /dev/null << 'EOF'
#!/bin/bash
set -e
PROMPT=""
while [[ $# -gt 0 ]]; do case $1 in --version) echo "1.0.0"; exit 0 ;; *) PROMPT="$PROMPT $1"; shift ;; esac; done
[ -z "$PROMPT" ] && PROMPT=$(cat)
[ -f ".env" ] && export $(grep -v '^#' .env | xargs)
SESSION_ID="clawteam-$(date +%s)-$$"
exec openclaw agent --local --message "$PROMPT" --session-id "$SESSION_ID" --timeout 300
EOF
sudo chmod +x /usr/local/bin/clawteam-agent

# Use
export TENCENT_API_KEY="your-key"
clawteam spawn -t my-team -n agent --task "Create a file"
```

## Changes from Original
- Default agent: `clawteam-agent` (OpenClaw wrapper) instead of `claude`
- No Anthropic login required
- Works with any OpenClaw-supported model (Tencent, OpenAI, etc.)

## Full Documentation
See [INSTALL.md](INSTALL.md) for detailed setup.
