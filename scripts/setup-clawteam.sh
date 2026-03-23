#!/bin/bash
# setup-clawteam.sh - Install ClawTeam with OpenClaw integration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAWTEAM_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🦞 ClawTeam Setup (OpenClaw Edition)"
echo "====================================="
echo ""

# Check dependencies
echo "📋 Checking dependencies..."

if ! command -v openclaw &> /dev/null; then
    echo "❌ openclaw not found. Please install OpenClaw first."
    echo "   npm install -g openclaw"
    exit 1
fi
echo "   ✅ openclaw found"

if ! command -v tmux &> /dev/null; then
    echo "❌ tmux not found. Please install tmux."
    echo "   apt-get install tmux  # Debian/Ubuntu"
    echo "   brew install tmux     # macOS"
    exit 1
fi
echo "   ✅ tmux found"

if ! command -v python3 &> /dev/null; then
    echo "❌ python3 not found. Please install Python 3."
    exit 1
fi
echo "   ✅ python3 found"

# Install clawteam-agent wrapper
echo ""
echo "🔧 Installing wrappers..."

if [ -w /usr/local/bin ]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    echo "   (Using $INSTALL_DIR - ensure it's in your PATH)"
fi

cp "$SCRIPT_DIR/clawteam-agent" "$INSTALL_DIR/clawteam-agent"
chmod +x "$INSTALL_DIR/clawteam-agent"
echo "   ✅ Installed clawteam-agent to $INSTALL_DIR"

cp "$SCRIPT_DIR/clawteam-wrapper" "$INSTALL_DIR/clawteam"
chmod +x "$INSTALL_DIR/clawteam"
echo "   ✅ Installed clawteam to $INSTALL_DIR"

# Install ClawTeam Python package
echo ""
echo "📦 Installing ClawTeam Python package..."
cd "$CLAWTEAM_ROOT"

# Check if we need --break-system-packages
PIP_ARGS=""
if python3 -c "import sys; print(sys.version_info)" 2>/dev/null | grep -q "externally-managed"; then
    PIP_ARGS="--break-system-packages"
fi

if pip3 show clawteam $PIP_ARGS &> /dev/null; then
    pip3 install -e . $PIP_ARGS --quiet 2>/dev/null || pip3 install -e . --break-system-packages --quiet
    echo "   ✅ Updated existing installation"
else
    pip3 install -e . $PIP_ARGS --quiet 2>/dev/null || pip3 install -e . --break-system-packages --quiet
    echo "   ✅ Installed clawteam package"
fi

# Create default config
echo ""
echo "⚙️  Creating default configuration..."
mkdir -p ~/.clawteam
if [ ! -f ~/.clawteam/config.json ]; then
    cat > ~/.clawteam/config.json << 'EOF'
{
  "data_dir": "",
  "user": "",
  "default_team": "",
  "transport": "file",
  "workspace": "auto",
  "default_backend": "tmux",
  "skip_permissions": true
}
EOF
    echo "   ✅ Created ~/.clawteam/config.json"
else
    echo "   ⏭️  Config already exists"
fi

# Verify installation
echo ""
echo "🧪 Verifying installation..."
if command -v clawteam &> /dev/null; then
    echo "   ✅ clawteam command available"
else
    echo "   ⚠️  clawteam not in PATH. You may need to:"
    echo "       export PATH=\"$HOME/.local/bin:\$PATH\""
fi

if command -v clawteam-agent &> /dev/null; then
    echo "   ✅ clawteam-agent command available"
    VERSION=$(clawteam-agent --version 2>/dev/null || echo "unknown")
    echo "      Version: $VERSION"
else
    echo "   ⚠️  clawteam-agent not in PATH"
fi

# Test OpenClaw
echo ""
echo "🧪 Testing OpenClaw agent..."
if openclaw agent --local --message "ping" --timeout 30 &> /dev/null; then
    echo "   ✅ OpenClaw agent is working"
else
    echo "   ⚠️  OpenClaw agent test failed - you may need to configure API keys"
fi

echo ""
echo "====================================="
echo "🎉 ClawTeam setup complete!"
echo ""
echo "Quick start:"
echo "  1. Set your API key: export TENCENT_API_KEY='your-key'"
echo "  2. Create a team:    clawteam team spawn-team my-team"
echo "  3. Spawn an agent:   clawteam spawn -t my-team -n agent1 --task 'Hello world'"
echo "  4. View board:       clawteam board show my-team"
echo ""
echo "Documentation: cat $CLAWTEAM_ROOT/README.md"
