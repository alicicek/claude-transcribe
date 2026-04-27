# claude-transcribe

A [Claude Code](https://claude.com/claude-code) plugin that turns any video or audio — a YouTube link, an X / TikTok / Vimeo URL, a podcast, or a local media file — into a plain-text transcript that Claude can read and reason about.

Auto-triggers when you ask Claude to *research*, *transcribe*, *summarise*, or *take notes on* a video. Powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp) + [OpenAI Whisper](https://github.com/openai/whisper). Runs entirely on your machine.

## Install

In Claude Code:

```
/plugin marketplace add alicicek/claude-transcribe
/plugin install claude-transcribe@alicicek-marketplace
```

A `SessionStart` hook installs `yt-dlp`, `ffmpeg`, `python@3.13`, and `openai-whisper` on first use (Homebrew or `apt`). See the [main README](https://github.com/alicicek/claude-transcribe#readme) for full docs, manual install, troubleshooting, and privacy notes.

## Use

Just ask Claude:

> research this video https://www.youtube.com/watch?v=…
> transcribe ~/Downloads/podcast.mp3 and summarise

Or invoke the skill explicitly:

```
/transcribe-media <url-or-file> [model]
```

## Licence

[MIT](LICENSE) © Ali Cicek
