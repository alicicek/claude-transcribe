# claude-transcribe

A Claude Code plugin that turns any video or audio — a YouTube link, an X / TikTok / Vimeo URL, a podcast, or a local media file — into a plain-text transcript that Claude can read and reason about.

Auto-triggers when you ask Claude to *research*, *transcribe*, *summarise*, or *take notes on* a video, so most of the time you just paste a URL and ask your question.

Powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp) + [OpenAI Whisper](https://github.com/openai/whisper). Runs entirely on your machine — nothing is uploaded.

---

## Install

You'll need [Claude Code](https://claude.com/claude-code) and (on macOS) [Homebrew](https://brew.sh). Linux works too — see [Manual install](#manual-install).

In Claude Code:

```
/plugin marketplace add alicicek/claude-transcribe
/plugin install claude-transcribe@alicicek-marketplace
```

The plugin itself ships through npm (`claude-transcribe` on [npmjs.com](https://www.npmjs.com/package/claude-transcribe)) — that's a deliberate choice so the install uses HTTPS and works without GitHub SSH keys, while the marketplace catalog stays on GitHub for visibility.

The first time the plugin loads, a `SessionStart` hook installs `yt-dlp`, `ffmpeg`, `python@3.13`, and `openai-whisper` (in an isolated venv at `~/.local/share/claude-transcribe/whisper-venv`). Subsequent sessions skip the install.

## Use

Just ask:

> research this video https://www.youtube.com/watch?v=…
>
> what's said in this clip: https://x.com/…/status/…
>
> transcribe ~/Downloads/podcast.mp3 and summarise the main points

Or invoke the skill explicitly:

```
/transcribe-media <url-or-file> [model]
```

The skill runs `bin/transcribe-url`, which:

1. Downloads the audio track with `yt-dlp` (using your browser cookies automatically, so age-gated and members-only videos work if you're signed in).
2. Transcribes with Whisper.
3. Writes the transcript to `$TMPDIR/claude-transcribe/<title>.txt` and prints the path.

Claude then reads the transcript and answers whatever you actually asked.

### Choosing a Whisper model

| Model | Size | Speed | When to use |
|---|---|---|---|
| `tiny.en` | ~75 MB | fastest | Quick sanity check, very clear English |
| `base.en` | ~150 MB | fast | Decent default for English |
| `small.en` | ~250 MB | medium **(default)** | Most English content, technical jargon |
| `medium` | ~1.5 GB | slow | Non-English, heavy accents, music+speech mix |
| `large-v3` | ~3 GB | slowest | Maximum accuracy, long-form professional content |

Pass it as the second argument: `/transcribe-media <url> medium`. Models are cached at `~/.cache/whisper/` after first download.

### Where transcripts go

By default: `$TMPDIR/claude-transcribe/` — your per-user temp directory, which macOS auto-purges every ~3 days for files older than 3 days.

Override with the `CLAUDE_TRANSCRIBE_OUTDIR` environment variable:

```bash
export CLAUDE_TRANSCRIBE_OUTDIR="$HOME/Documents/transcripts"
```

## Manual install

If you're on Linux, prefer not to use the SessionStart hook, or want to call the script outside Claude Code:

```bash
# macOS
brew install yt-dlp ffmpeg python@3.13

# Debian/Ubuntu
sudo apt install yt-dlp ffmpeg python3.13 python3.13-venv

# Then create the whisper venv (works on both)
python3.13 -m venv ~/.local/share/claude-transcribe/whisper-venv
~/.local/share/claude-transcribe/whisper-venv/bin/pip install -U openai-whisper
```

To use the script directly from your shell, add the plugin's `bin/` to your `PATH` or symlink it. The exact plugin install path depends on your Claude Code version — check with `/plugin list`.

## Privacy

- **Everything runs locally.** Audio is downloaded to a temp directory, transcribed by Whisper on your CPU, written to your filesystem, and never sent anywhere else.
- **Browser cookies** are passed to `yt-dlp` so authenticated downloads work. They never leave your machine. The plugin only reads cookies for the domain you're downloading from, the same way `yt-dlp --cookies-from-browser` does normally.
- **Transcripts auto-expire.** They live in `$TMPDIR`, which macOS cleans automatically. Set `CLAUDE_TRANSCRIBE_OUTDIR` to keep them.

The full privacy policy — including every third-party service the plugin touches and where each piece of data lives on your machine — is at [PRIVACY.md](PRIVACY.md).

## Troubleshooting

| Symptom | Fix |
|---|---|
| `yt-dlp: ERROR: Sign in to confirm you're not a bot` | The wrapper auto-tries browser cookies. If both attempts fail, sign into the source site once in your browser and retry. |
| Download fails with a generic yt-dlp error | `brew upgrade yt-dlp` — sites change format and yt-dlp ships near-daily fixes. |
| `whisper: command not found` after install | The hook may have failed silently. Run `bash ~/.claude/plugins/<…>/claude-transcribe/hooks/install-deps.sh` manually and check the output. |
| Transcript looks garbled / non-English | Pass `medium` or `large-v3` as the second argument. The default `small.en` is English-only. |

## How it's structured

```
claude-transcribe/
├── .claude-plugin/
│   ├── plugin.json         # plugin manifest
│   └── marketplace.json    # makes this repo a Claude Code marketplace
├── skills/
│   └── transcribe-media/
│       └── SKILL.md        # instructions Claude follows
├── bin/
│   └── transcribe-url      # the actual download + transcribe script
├── hooks/
│   └── install-deps.sh     # first-run installer
├── README.md
└── LICENSE
```

## Licence

[MIT](LICENSE) © Ali Cicek
