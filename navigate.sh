#!/bin/bash

echo "🧭 Project Navigation Helper"
echo "============================"

show_structure() {
    echo ""
    echo "📁 Project Structure:"
    echo "├── 🚀 Quick Start:"
    echo "│   ├── ./start.sh (Start environment)"
    echo "│   ├── ./stop.sh (Stop environment)"
    echo "│   └── ./docker-compose.yml (Main config)"
    echo "│"
    echo "├── 📜 Scripts:"
    echo "│   ├── scripts/environment/ (Start/stop)"
    echo "│   ├── scripts/build/ (Optimizations)"
    echo "│   └── scripts/optimization/ (Performance)"
    echo "│"
    echo "├── 📚 Documentation:"
    echo "│   ├── docs/setup/ (Setup guides)"
    echo "│   ├── docs/troubleshooting/ (Issues)"
    echo "│   ├── docs/guides/ (Features)"
    echo "│   └── docs/architecture/ (Design)"
    echo "│"
    echo "├── 🐳 Docker:"
    echo "│   ├── docker/compose/ (Docker configs)"
    echo "│   └── docker/infrastructure/ (Infrastructure)"
    echo "│"
    echo "└── ⚙️ Configs:"
    echo "    ├── configs/gradle/ (Build settings)"
    echo "    ├── configs/docker/ (Docker settings)"
    echo "    └── configs/services/ (Service configs)"
}

show_quick_commands() {
    echo ""
    echo "⚡ Quick Commands:"
    echo "=================="
    echo "Environment:"
    echo "  ./start.sh              # Start everything"
    echo "  ./stop.sh               # Stop everything"
    echo "  ./start.sh status       # Check status"
    echo ""
    echo "Build & Optimization:"
    echo "  ./scripts/build/optimize-builds.sh        # Gradle optimizations"
    echo "  ./scripts/build/optimize-docker-builds.sh # Docker optimizations"
    echo ""
    echo "Documentation:"
    echo "  cat docs/README.md                        # Main documentation"
    echo "  ls docs/troubleshooting/                  # Troubleshooting guides"
    echo "  ls docs/guides/                           # Feature guides"
}

case "${1:-help}" in
    "structure"|"tree")
        show_structure
        ;;
    "commands"|"cmd")
        show_quick_commands
        ;;
    "docs")
        echo "📚 Available Documentation:"
        find docs/ -name "*.md" | sort
        ;;
    "scripts")
        echo "📜 Available Scripts:"
        find scripts/ -name "*.sh" | sort
        ;;
    *)
        echo "Usage: ./navigate.sh {structure|commands|docs|scripts}"
        echo ""
        show_structure
        show_quick_commands
        ;;
esac
