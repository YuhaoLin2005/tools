# tools

> 个人实用工具集 — OCR、代码格式化

## 工具列表

| 工具 | 说明 | 用法 |
|------|------|------|
| `ocr.py` | RapidOCR 封装，ONNX GPU加速 | `python ocr.py image.png` |
| `auto-format.py` | Claude Code hook — 文件编辑后自动 prettier 格式化 | 放入 `~/.claude/hooks/` |

## ocr.py

```
# 默认模式
python ocr.py screenshot.png

# 含置信度+坐标
python ocr.py screenshot.png --detail

# JSON 输出
python ocr.py screenshot.png --json

# 纯文本
python ocr.py screenshot.png --text
```

**依赖**：`pip install rapidocr-onnxruntime onnxruntime-gpu`

## auto-format.py

Claude Code 的 PostToolUse hook，在 Write/Edit 操作后自动运行 prettier。

支持的格式：Vue, JS/TS, CSS/SCSS, HTML, JSON, Markdown

配置方法：放入 `~/.claude/scripts/`，或在 `settings.json` 中注册。
