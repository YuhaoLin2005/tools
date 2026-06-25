#!/usr/bin/env python3
"""PaddleOCR wrapper — PaddleOCR-VL + PP-OCRv6, GPU-accelerated, isolated venv.

Usage:
    python ocr.py <image>                 # VL mode: Markdown with LaTeX (for PPT/docs/formulas)
    python ocr.py <image> --fast          # Fast mode: PP-OCRv6 text only (~0.5s)
    python ocr.py <image> --json          # JSON with blocks/boxes + confidence
    python ocr.py <image> --text          # Plain text output (no markdown formatting)
    python ocr.py <image> --detail        # Debug timings

Prerequisites:
    pip install paddlepaddle-gpu paddleocr
    VL mode requires PaddleOCR-VL-1.6 model (auto-downloaded on first run)
"""

import subprocess, sys, os, argparse, json

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")


def get_venv_python():
    """Find python in preferred venvs, fallback to system python."""
    candidates = [
        os.path.expanduser(r"~\.ocr-vl-venv\Scripts\python.exe"),
        os.path.expanduser(r"~\.ocr-venv\Scripts\python.exe"),
        sys.executable,
    ]
    for p in candidates:
        if os.path.exists(p):
            return p
    return sys.executable


OCR_VENV_PYTHON = get_venv_python()
OCR_ENGINE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "_ocr_engine.py")


def check_deps():
    missing = []
    if not os.path.exists(OCR_VENV_PYTHON):
        missing.append(f"OCR venv not found at {OCR_VENV_PYTHON}")
    if not os.path.exists(OCR_ENGINE):
        missing.append(f"Engine script missing: {OCR_ENGINE}")
    if missing:
        for m in missing:
            print(f"ERROR: {m}", file=sys.stderr)
        sys.exit(1)


def run_engine(image_path, mode="vl", lang="ch", detail=False):
    cmd = [OCR_VENV_PYTHON, OCR_ENGINE, image_path, "--mode", mode]
    if mode == "fast" and lang:
        cmd.extend(["--lang", lang])
    if detail:
        cmd.append("--detail")

    env = os.environ.copy()
    env["PYTHONIOENCODING"] = "utf-8"

    result = subprocess.run(
        cmd, capture_output=True, text=True, timeout=300,
        env=env, encoding="utf-8", errors="replace",
    )

    output_line = ""
    for line in result.stdout.strip().split("\n"):
        if line.startswith("OCR_OUTPUT:"):
            output_line = line
            break

    if output_line:
        tmp_path = output_line[len("OCR_OUTPUT:"):]
        try:
            with open(tmp_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            return data
        finally:
            try:
                os.remove(tmp_path)
            except OSError:
                pass

    if result.stdout:
        print(result.stdout)
    if result.stderr and detail:
        print(result.stderr.strip(), file=sys.stderr)
    return None


def format_output(data, fmt="markdown"):
    if data is None:
        return

    if fmt == "json":
        print(json.dumps(data, ensure_ascii=False, indent=2))
        return

    mode = data.get("mode", "vl")

    if mode == "vl":
        md = data.get("markdown", "")
        if fmt == "text":
            for block in data.get("blocks", []):
                if block["content"]:
                    print(block["content"])
        elif fmt == "markdown":
            print(md if md else "(no text detected)")
    else:
        for line in data.get("lines", []):
            print(line["text"])


def main():
    parser = argparse.ArgumentParser(
        description="PaddleOCR-VL + PP-OCRv6 — OCR for text, formulas, documents"
    )
    parser.add_argument("image", help="Path to image file")
    parser.add_argument("--fast", action="store_true",
                        help="Use PP-OCRv6 fast text mode instead of VL document parsing")
    parser.add_argument("--json", action="store_true",
                        help="Output full JSON with blocks/bbox/confidence")
    parser.add_argument("--text", action="store_true",
                        help="Plain text output (no markdown formatting)")
    parser.add_argument("--lang", default="ch",
                        help="Language for fast mode (ch/en/...)")
    parser.add_argument("--detail", action="store_true",
                        help="Show timing info on stderr")
    args = parser.parse_args()

    check_deps()

    image_path = os.path.abspath(args.image)
    if not os.path.exists(image_path):
        print(f"ERROR: Image not found: {image_path}", file=sys.stderr)
        sys.exit(1)

    mode = "fast" if args.fast else "vl"
    data = run_engine(image_path, mode=mode, lang=args.lang, detail=args.detail)

    if data is None:
        print("ERROR: OCR engine returned no data", file=sys.stderr)
        sys.exit(1)

    if args.detail:
        print(f"[mode={data['mode']}, {data['time_s']:.3f}s]", file=sys.stderr)

    out_fmt = "json" if args.json else ("text" if args.text else "markdown")
    format_output(data, fmt=out_fmt)


if __name__ == "__main__":
    main()
