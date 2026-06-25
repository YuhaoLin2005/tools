#!/usr/bin/env python3
"""
Claude Code PostToolUse hook — auto-format web files with prettier after Write/Edit.
Drop into ~/.claude/hooks/ or configure in settings.json.

Supports: .vue, .js, .jsx, .ts, .tsx, .css, .scss, .html, .json, .md
"""

import json, os, subprocess, sys

WEB_EXTENSIONS = (".vue", ".js", ".jsx", ".ts", ".tsx", ".css", ".scss", ".html", ".json", ".md")


def main():
    tool_input_raw = os.environ.get("CLAUDE_TOOL_INPUT", "{}")
    try:
        tool_input = json.loads(tool_input_raw)
    except json.JSONDecodeError:
        tool_input = {}

    file_path = tool_input.get("file_path", "") or tool_input.get("path", "")
    if not file_path:
        sys.exit(0)

    if not file_path.endswith(WEB_EXTENSIONS):
        sys.exit(0)

    if "node_modules" in file_path:
        sys.exit(0)

    for cmd in [
        ["npx", "--no", "prettier", "--write", file_path],
        ["prettier", "--write", file_path],
    ]:
        try:
            result = subprocess.run(cmd, timeout=10, capture_output=True, text=True)
            if result.returncode == 0:
                sys.exit(0)
        except (FileNotFoundError, subprocess.TimeoutExpired):
            continue

    sys.exit(0)


if __name__ == "__main__":
    main()
