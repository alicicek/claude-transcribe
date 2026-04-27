# Privacy Policy — claude-transcribe

Last updated: 27 April 2026

## Plain-English summary

The `claude-transcribe` plugin runs entirely on your own computer. It does not collect, transmit, or store any of your data on any server controlled by the author. There is no telemetry, no analytics, no usage tracking, and no account or login of any kind required by the plugin itself.

This document explains, in detail, exactly what happens to your data when you use the plugin, what third-party services are involved, and what choices you have.

## What data the plugin handles

When you use the plugin, the following kinds of data are processed **on your local machine**:

- **The URL or local file path you provide.** Passed as an argument to the bundled wrapper script.
- **The audio track of the media at that URL or path.** Downloaded by [yt-dlp](https://github.com/yt-dlp/yt-dlp) to a temporary directory if a URL is given, or read directly from disk if a local path is given.
- **The transcript text produced by [OpenAI Whisper](https://github.com/openai/whisper).** Saved as a `.txt` file in `$TMPDIR/claude-transcribe/` (or the directory specified by the `CLAUDE_TRANSCRIBE_OUTDIR` environment variable).
- **Browser cookies for the source site.** Read by yt-dlp via its `--cookies-from-browser` flag from a locally installed browser (Chrome, Brave, Arc, Edge, Firefox, or Safari). Used only to authenticate downloads of age-gated, members-only, or rate-limited content. Cookies never leave your machine.

## What data the author of this plugin receives

**None.** The plugin contains no telemetry, no analytics, no error reporting, and no network calls back to the author or to any third-party service controlled by the author. The plugin's source code is published under the MIT licence and is fully auditable at https://github.com/alicicek/claude-transcribe.

## Third-party services involved

Although the author of `claude-transcribe` does not collect any data, the plugin depends on third-party software and services that have their own privacy practices:

- **The source site you download from** (YouTube, X, TikTok, Vimeo, etc.). Your IP address and any browser cookies you pass via yt-dlp are visible to that site. yt-dlp behaves like an HTTP client downloading public content. See the privacy policy of the site you're downloading from.
- **Homebrew** (https://brew.sh) — used by the SessionStart hook to install `yt-dlp`, `ffmpeg`, and `python@3.13` on macOS. See https://docs.brew.sh/Analytics for Homebrew's anonymous usage analytics, which you can opt out of with `brew analytics off`.
- **The Python Package Index (PyPI)** (https://pypi.org) — used to install the `openai-whisper` Python package. See https://pypi.org/policy/privacy-notice/ for PyPI's privacy practices.
- **The npm registry** (https://www.npmjs.com) — distributes the plugin tarball. See https://docs.npmjs.com/policies/privacy for npm's privacy practices.
- **GitHub** (https://github.com) — hosts the source repository and the marketplace catalog. See https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement for GitHub's privacy practices.
- **Anthropic's Claude Code** (https://claude.com/claude-code) — the application that loads and runs this plugin. See https://www.anthropic.com/legal/privacy for Anthropic's privacy practices.

## Where data is stored on your device

- **Downloaded audio (URLs only):** in a temporary directory created by `mktemp -d`, deleted automatically when the script exits.
- **Transcripts:** in `$TMPDIR/claude-transcribe/` by default. On macOS, `$TMPDIR` is per-user and is automatically cleaned by the operating system every three days. You can override the location with `CLAUDE_TRANSCRIBE_OUTDIR`.
- **Whisper model files:** in `~/.cache/whisper/`, downloaded the first time a model size is used. These are static model weights from OpenAI; they contain no personal data.
- **Whisper Python virtual environment:** in `~/.local/share/claude-transcribe/whisper-venv/`.

## Browser cookies

The wrapper script auto-detects a locally installed browser and passes `--cookies-from-browser` to yt-dlp, so that downloads from sites you're already signed into work without further configuration. The cookies are read from your browser's local cookie store on disk, used in-memory by yt-dlp for the duration of the download, and never written elsewhere or transmitted to the plugin author. If a cookie-assisted download fails, the script automatically retries without cookies.

If you'd rather the plugin not read your browser cookies, you can sign out of the source site in that browser, or delete `Google Chrome.app` (or whichever browser is auto-detected) before running.

## Children's privacy

The plugin is a developer tool and is not directed at children under 13. The plugin does not collect any personal information from anyone, including children.

## Changes to this policy

If the privacy practices of the plugin ever change — for example, if a future version adds telemetry — the change will be documented in this file and announced in the repository's release notes before the version is published. The plugin's MIT licence and open source code allow you to audit any version yourself.

## Contact

Questions about this policy: open an issue at https://github.com/alicicek/claude-transcribe/issues, or email the maintainer (contact details on the GitHub profile at https://github.com/alicicek).
