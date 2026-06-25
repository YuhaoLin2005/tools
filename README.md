# tools

> 个人实用工具集 — OCR、桌面整理、代码格式化

## 工具列表

| 工具 | 说明 | 用法 |
|------|------|------|
| `ocr.py` | PaddleOCR-VL + PP-OCRv6 封装，GPU加速 | `python ocr.py image.png` |
| `organize_desktop.ps1` | Windows 桌面文件自动分类整理 | 右键 → 使用 PowerShell 运行 |
| `auto-format.py` | Claude Code hook — 文件编辑后自动 prettier 格式化 | 放入 `~/.claude/hooks/` |

## ocr.py

```
# VL 模式（默认）：文档/PPT/公式 → Markdown + LaTeX
python ocr.py screenshot.png

# 快速模式：纯文字 ~0.5s
python ocr.py screenshot.png --fast

# JSON 输出（含坐标/置信度）
python ocr.py screenshot.png --json

# 纯文本
python ocr.py screenshot.png --text
```

**依赖**：PaddlePaddle GPU + PaddleOCR，建议使用独立 venv。

## organize_desktop.ps1

将桌面文件按类别自动移动到 `桌面整理/` 子文件夹：
- 课程作业、课程实验、遥感实习
- 软件安装包、GIS地图数据
- 图片、文档、代码项目
- 临时文件

**使用前**：根据自己的学号和课程名修改匹配规则。

## auto-format.py

Claude Code 的 PostToolUse hook，在 Write/Edit 操作后自动运行 prettier。

支持的格式：Vue, JS/TS, CSS/SCSS, HTML, JSON, Markdown

配置方法：放入 Claude Code hooks 目录，或在 `settings.json` 中注册。
