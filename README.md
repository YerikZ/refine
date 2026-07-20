# Refine

A lightweight macOS menu bar writing tool. Paste or type text, pick a mode, and get a result — powered by a locally hosted LLM via [Ollama](https://ollama.com), with nothing sent off your machine.

Built with SwiftUI (`MenuBarExtra`), no external dependencies.

## Features

- **Three modes** — Rewrite (with Style: Professional/Casual/Concise/Persuasive, and Tone: Neutral/Friendly/Confident/Formal), Summarise, and Polish.
- Results stream live into a separate result card, so your original input is never overwritten. Copy, Revert, or Clear with one click.
- **History** — the last 5 runs are saved and restorable, even after relaunching.
- **Settings** — server URL, model (auto-populated from Ollama), temperature, and an editable system prompt for Rewrite mode.
- Lives entirely in the menu bar — no Dock icon.

## Requirements

- macOS 14+
- [Ollama](https://ollama.com) running locally (default `http://localhost:11434`) with at least one model pulled, e.g. `ollama pull qwen2.5:7b`

## Build & run

```sh
swift run                       # dev loop — menu bar item appears immediately
scripts/make-app.sh             # builds a signed Refine.app into dist/
scripts/make-app.sh --install   # also copies it to /Applications
```

## License

MIT — see [LICENSE](LICENSE).
