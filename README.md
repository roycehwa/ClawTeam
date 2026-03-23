# ClawTeam (OpenClaw Edition) 🦞

Multi-agent coordination CLI using OpenClaw local agent (no Claude Code login required).

## ✨ Features

- 🤖 **OpenClaw Native** - Uses OpenClaw embedded agents instead of Claude Code
- 📦 **No External Dependencies** - No Anthropic account needed
- 🖥️ **Tmux Integration** - Visual monitoring of all agents in tiled panes
- 💬 **Inter-Agent Messaging** - Built-in mailbox system for coordination
- 📋 **Task Management** - Create, assign, and track tasks across agents
- 📊 **Live Dashboard** - Real-time kanban board in terminal or web UI
- 🔧 **Git Worktree Isolation** - Each agent gets isolated workspace

## 🚀 Quick Start

```bash
# 1. Clone and setup
git clone https://github.com/roycehwa/ClawTeam.git
cd ClawTeam
bash scripts/setup-clawteam.sh

# 2. Set API key (Tencent/OpenAI)
export TENCENT_API_KEY="your-key-here"

# 3. Create a team
clawteam team spawn-team my-team

# 4. Spawn agents
clawteam spawn -t my-team -n researcher --task "Research Python async patterns"
clawteam spawn -t my-team -n coder --task "Implement the solution"

# 5. Monitor
clawteam board show my-team
tmux attach -t clawteam-my-team
```

## 📊 Commands

### Team Management
```bash
clawteam team spawn-team <name>              # Create team
clawteam team status <name>                  # Show team info
clawteam team discover                       # List all teams
clawteam team cleanup <name> --force         # Delete team
```

### Agent Spawning
```bash
clawteam spawn -t <team> -n <name> --task "<task>"    # Spawn agent
clawteam spawn -t <team> -n <name> --workspace        # With git worktree
```

### Messaging
```bash
clawteam inbox send <team> <agent> "<message>"        # Send message
clawteam inbox receive <team> --agent <name>          # Check messages
clawteam inbox peek <team> --agent <name>             # View without consuming
clawteam inbox broadcast <team> "<message>"           # Broadcast to all
```

### Tasks
```bash
clawteam task create <team> "<subject>" --owner <agent>     # Create task
clawteam task list <team>                                   # List tasks
clawteam task update <team> <id> --status completed         # Update status
clawteam task stats <team>                                  # Show statistics
```

### Dashboard
```bash
clawteam board show <team>               # Terminal kanban board
clawteam board live <team>               # Live updating board
clawteam board serve <team> -p 8080      # Web UI dashboard
clawteam board attach <team>             # Tmux tiled view
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     ClawTeam CLI                        │
├─────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │  Team    │  │  Task    │  │  Mailbox │  │  Board  │ │
│  │ Manager  │  │  Store   │  │  Manager │  │Renderer │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬────┘ │
│       └─────────────┴─────────────┴─────────────┘      │
│                          │                              │
│                   ┌──────┴──────┐                       │
│                   │ FileTransport│                      │
│                   │ ~/.clawteam │                      │
│                   └──────┬──────┘                       │
│                          │                              │
│       ┌──────────────────┼──────────────────┐          │
│       │                  │                  │          │
│  ┌────┴────┐       ┌────┴────┐       ┌────┴────┐     │
│  │ Agent 1 │◄─────►│ Agent 2 │◄─────►│ Agent N │     │
│  │ (tmux)  │       │ (tmux)  │       │ (tmux)  │     │
│  └────┬────┘       └────┬────┘       └────┬────┘     │
│       │                 │                  │          │
│       └─────────────────┴──────────────────┘          │
│                    OpenClaw Local                     │
└─────────────────────────────────────────────────────────┘
```

## 🔧 How It Works

1. **Agent Spawning**: Each agent runs in a tmux window with isolated git worktree
2. **Communication**: File-based transport stores messages in `~/.clawteam/teams/{team}/inboxes/`
3. **Task Execution**: Agents use `openclaw agent --local` to execute tasks
4. **Coordination**: Built-in mailbox system for request/response patterns

## 📝 Agent Protocol

Agents automatically follow this coordination protocol:

```python
# Check tasks
clawteam task list <team> --owner <agent>

# Start working
clawteam task update <team> <id> --status in_progress

# Report completion
clawteam inbox send <team> leader "Task completed: ..."
clawteam task update <team> <id> --status completed

# Report costs
clawteam cost report <team> --input-tokens <N> --output-tokens <N>
```

## 🛠️ Configuration

Config file: `~/.clawteam/config.json`

```json
{
  "data_dir": "",
  "user": "",
  "default_team": "",
  "transport": "file",
  "workspace": "auto",
  "default_backend": "tmux",
  "skip_permissions": true
}
```

Environment variables:
- `TENCENT_API_KEY` / `OPENAI_API_KEY` - API credentials
- `CLAWTEAM_USER` - Your username
- `CLAWTEAM_DATA_DIR` - Override data directory
- `CLAWTEAM_TRANSPORT` - `file` or `p2p`

## 🧪 Testing

```bash
# Run test suite
clawteam config health              # Check data directory
clawteam team spawn-team test       # Create test team
clawteam spawn -t test -n a1 --task "Create test file"  # Spawn agent
clawteam board show test            # View board
```

## 📚 Differences from Original

| Feature | Original | OpenClaw Edition |
|---------|----------|------------------|
| Default Agent | `claude` CLI | `clawteam-agent` (OpenClaw) |
| Login Required | Anthropic account | None (local execution) |
| Models | Claude only | Any OpenClaw-supported model |
| Cost | Anthropic API | Your own API keys |

## 🤝 Contributing

This is a community fork focused on OpenClaw integration. Original ClawTeam concepts apply.

## 📄 License

MIT License - See original ClawTeam repository for details.

---

**Note**: This edition requires OpenClaw to be installed (`npm install -g openclaw`).
