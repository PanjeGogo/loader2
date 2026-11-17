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

# Request-contract checks are deliberately static: no credentials are fabricated and
# no live authentication/session endpoints are contacted by CI.
REQUEST_CONTRACTS = {
    "start.php": ["script=", "key=", "hwid=", "nonce=", "ts=", "place_id=", "game_id=", "phase="],
    "loader-info.php": ["place_id="],
    "auth.php": ["script=", "key=", "hwid=", "nonce=", "ts=", "place_id="],
    "load.php": ["token=", "nonce="],
    "heartbeat.php?action=start": ["token=", "nonce=", "hwid="],
    "heartbeat.php?action=ping": ["token=", "hwid="],
}
REQUEST_ANCHORS = {
    "start.php": "BASE..\"/api/start.php?",
    "loader-info.php": "BASE..\"/api/loader-info.php?",
    "auth.php": "BASE..\"/api/auth.php?",
    "load.php": "BASE..\"/api/load.php?",
    "heartbeat.php?action=start": "BASE..\"/api/heartbeat.php?action=start&",
    "heartbeat.php?action=ping": "BASE..\"/api/heartbeat.php?action=ping&",
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
    report += ["## API request contract audit", "", "Static source inspection only; this does NOT send requests or prove the remote server will return HTTP 2xx.", ""]
    contract_failures = []
    for endpoint, required in REQUEST_CONTRACTS.items():
        anchor = REQUEST_ANCHORS[endpoint]
        pos = text.find(anchor)
        segment = text[pos:pos + 1400] if pos >= 0 else ""
        missing = [name for name in required if name not in segment]
        status = "PASS" if pos >= 0 and not missing else "FAIL"
        report.append(f"- {status} `{endpoint}`: " + ("required query keys present in request builder" if not missing and pos >= 0 else "missing request builder or keys: " + ", ".join(missing)))
        if status == "FAIL": contract_failures.append(endpoint)
    report += ["", "HTTP 400/401/403/404/429/5xx can only be confirmed by a controlled live test against the real service with valid, authorized inputs. CI intentionally does not invent keys, tokens, HWIDs, nonces, or execute the loader.", ""]
    if contract_failures:
        report.append("Request contract audit failures: " + ", ".join(contract_failures))
    report += ["## Notes", "", "Lexical triage and static request-contract checks only. It does not deobfuscate code, validate server responses, retrieve payloads, or bypass authorization. Treat extracted URLs and Lua as untrusted; do not execute them merely to inspect them.", ""]
    out.write_text("\n".join(report), encoding="utf-8")
    print("\n".join(report))

if __name__ == "__main__":
    main()
