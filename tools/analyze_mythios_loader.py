#!/usr/bin/env python3
"""Static, non-executing Lua loader triage. Never evaluates Lua or contacts endpoints."""
from pathlib import Path
import argparse, re

PATTERNS = {
    "URLs": r"""https?://[^\s"'<>]+""",
    "API paths": r"""["'](/api/[A-Za-z0-9_./?=&%-]+)["']""",
    "PlaceId / GameId constants": r"""(?:PlaceId|place_id|GameId|game_id)\s*["']?\s*[:=]\s*["']?(\d{5,})""",
    "load/compile sites": r"""\b(?:loadstring|load|CompileString)\s*\(""",
    "HTTP/request sites": r"""\b(?:HttpGet|GetAsync|PostAsync|RequestAsync|request|http_request)\s*\(""",
    "response markers": r"""MYTH\w*|[A-Z]{3,8}\d\n""",
}
SECRET_KEYS = re.compile(r'(?i)(key|token|secret|authorization|cookie|hwid|nonce)\s*([=:])\s*([^\s,;&]+)')
def redact(s):
    return SECRET_KEYS.sub(lambda m: f"{m.group(1)}{m.group(2)}[REDACTED]", s)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", default="input/loader.lua")
    ap.add_argument("--output", default="analysis/loader-report.md")
    args = ap.parse_args()
    src = Path(args.input)
    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    if not src.is_file():
        report = f"# Static Lua loader analysis\n\nInput not found: {src}.\n\nAdd the authorized loader source at this path, then rerun the workflow. The analyzer does not execute Lua or make network requests.\n"
        out.write_text(report, encoding="utf-8")
        print(report)
        return
    text = src.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    report = ["# Static Lua loader analysis", "", f"- Input: {src}", f"- Size: {len(text.encode('utf-8'))} bytes", f"- Lines: {len(lines)}", "- Execution: NOT performed", "- Network requests: NONE", ""]
    for title, pattern in PATTERNS.items():
        hits = []
        rx = re.compile(pattern, re.I)
        for n, line in enumerate(lines, 1):
            if rx.search(line):
                hits.append((n, redact(line.strip())[:240]))
        report += [f"## {title}", ""]
        if hits:
            report += [f"- L{n}: {value.replace(chr(96), chr(39))}" for n, value in hits[:100]]
            if len(hits) > 100: report.append(f"- ... {len(hits)-100} more matches omitted")
        else:
            report.append("- No matches")
        report.append("")
    report += ["## Notes", "", "Lexical triage only. It does not deobfuscate code, validate server responses, retrieve payloads, or bypass authorization. Treat extracted URLs and Lua as untrusted; do not execute them merely to inspect them.", ""]
    out.write_text("\n".join(report), encoding="utf-8")
    print("\n".join(report))

if __name__ == "__main__":
    main()
