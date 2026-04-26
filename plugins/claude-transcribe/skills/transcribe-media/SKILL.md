---
name: transcribe-media
description: Transcribe video/audio from a URL (YouTube, X/Twitter, TikTok, Vimeo, podcast, etc.) or a local audio/video file using yt-dlp + OpenAI Whisper. Use whenever the user shares a media URL or local file path and asks to research, transcribe, summarise, take notes from, quote, or discuss its contents. Returns the transcript text for follow-up analysis.
when_to_use: |
  Trigger when the user shares a video/audio URL or local .mp3/.mp4/.wav/.m4a/.webm/.opus file together with any analytical request. Common phrasings: "research this video", "transcribe this", "summarise this clip", "what does this say", "take notes on this", "what's discussed in this URL". Also trigger when a media URL is shared with no explicit verb but the conversation makes content analysis the obvious next step.
argument-hint: <url-or-file-path> [whisper-model]
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/transcribe-url:*) Read
---

# transcribe-media

Turns any video/audio URL or local media file into a plain-text transcript so the assistant can answer the user's actual question about its contents.

## Invocation

If the user typed `/transcribe-media <url-or-path> [model]`, the arguments arrive as `$ARGUMENTS` and you should run the script with them directly. Otherwise, parse the URL or file path out of the user's natural-language message and pass it explicitly.

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/transcribe-url" $ARGUMENTS
```

If no `$ARGUMENTS` were passed (skill auto-triggered from a chat message), use the URL or path the user provided in conversation:

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/transcribe-url" "<url-or-absolute-path>" [model]
```

The script prints **one line on stdout: the absolute path to a `.txt` transcript** under `${TMPDIR}/claude-transcribe/` (or `$CLAUDE_TRANSCRIBE_OUTDIR` if set). Read that file with the Read tool, then continue with whatever the user actually asked for (summarise, extract claims, answer questions, take notes, etc.).

## Model selection (optional second argument)

Default is `small.en` — English-only, ~250 MB, fast, accurate for clear English speech.

| Model | Size | Speed | When to use |
|---|---|---|---|
| `tiny.en` | ~75 MB | fastest | Quick sanity check; very clear English |
| `base.en` | ~150 MB | fast | Decent default for English |
| `small.en` | ~250 MB | medium (default) | Most English content, including technical jargon |
| `medium` | ~1.5 GB | slow | Non-English, heavy accents, music+speech mix |
| `large-v3` | ~3 GB | slowest | Maximum accuracy; long-form professional content |

Models cache at `~/.cache/whisper/` after first download.

## What happens under the hood

1. URL input: yt-dlp downloads the audio track (mp3) into a temp dir, with auto-detected browser cookies for auth-gated sites.
2. Local file input: used directly.
3. Whisper transcribes to `${TMPDIR}/claude-transcribe/<title>.txt`.
4. The transcript path is printed to stdout.

## Notes for the assistant

- **First-ever run for a model downloads it** (~75 MB to ~3 GB depending on choice). Tell the user once and wait — don't poll.
- **Whisper mishears jargon**: trading acronyms (`FVG` heard as `FPG`), brand names, tickers, foreign words. When you produce a clean version, flag obvious mishearings inline; don't silently paste whisper's raw text as if it were perfect.
- **Browser cookies are automatic**: the wrapper detects an installed browser (Chrome → Brave → Arc → Edge → Firefox → Safari) and passes `--cookies-from-browser` to yt-dlp, then retries without cookies if that fails. Only step in if both attempts error — at that point the user is genuinely signed-out everywhere, or the video is geo-blocked / removed.
- **Length expectations**: 3-min clip on `small.en` ≈ 1–2 min CPU time. 60-min clip ≈ 10–15 min. State this up front for long content so the user knows to wait.
- **Copyright**: summarise and quote sparingly; do not reproduce long verbatim sections of copyrighted material.
- **Failure modes**: yt-dlp breaks when sites change. If a download fails with a yt-dlp error, suggest `brew upgrade yt-dlp` and retry once before giving up.
- **Transcripts auto-clean**: output goes to `$TMPDIR` which macOS purges every 3 days. If the user wants a permanent copy, copy it out before then or set `CLAUDE_TRANSCRIBE_OUTDIR` to a permanent location.

## Dependencies

The plugin's `SessionStart` hook auto-installs these on first use (macOS with Homebrew). For manual installation see the project README.

- `yt-dlp` (Homebrew)
- `ffmpeg` (Homebrew)
- `python@3.13` (Homebrew)
- `openai-whisper` in venv at `~/.local/share/claude-transcribe/whisper-venv`
