#!/usr/bin/env bash
# install-deps.sh — first-run setup for the claude-transcribe plugin.
# Runs from the SessionStart hook in plugin.json, but is idempotent and
# also safe to run by hand.

set -uo pipefail

DATA_DIR="${HOME}/.local/share/claude-transcribe"
FLAG="${DATA_DIR}/.deps-installed"
VENV="${DATA_DIR}/whisper-venv"

mkdir -p "$DATA_DIR"

# Already installed? Bail fast so SessionStart isn't slowed.
if [[ -f "$FLAG" ]] \
  && command -v yt-dlp >/dev/null 2>&1 \
  && command -v ffmpeg >/dev/null 2>&1 \
  && [[ -x "$VENV/bin/whisper" ]]; then
  exit 0
fi

# Need Homebrew for the system tools.
if ! command -v brew >/dev/null 2>&1; then
  echo "[claude-transcribe] Homebrew not found." >&2
  echo "[claude-transcribe] Install Homebrew (https://brew.sh) then restart the session." >&2
  echo "[claude-transcribe] On Linux: install yt-dlp, ffmpeg, python3.13 via your package manager and rerun this script." >&2
  exit 0
fi

NEED_BREW=()
command -v yt-dlp   >/dev/null 2>&1 || NEED_BREW+=(yt-dlp)
command -v ffmpeg   >/dev/null 2>&1 || NEED_BREW+=(ffmpeg)
command -v python3.13 >/dev/null 2>&1 || NEED_BREW+=(python@3.13)

if (( ${#NEED_BREW[@]} > 0 )); then
  echo "[claude-transcribe] Installing: ${NEED_BREW[*]}" >&2
  if ! brew install "${NEED_BREW[@]}" >&2; then
    echo "[claude-transcribe] brew install failed; see output above." >&2
    exit 0
  fi
fi

if [[ ! -x "$VENV/bin/whisper" ]]; then
  echo "[claude-transcribe] Creating whisper venv at $VENV" >&2
  rm -rf "$VENV"
  if ! python3.13 -m venv "$VENV"; then
    echo "[claude-transcribe] failed to create venv with python3.13" >&2
    exit 0
  fi
  echo "[claude-transcribe] Installing openai-whisper (this can take a minute)" >&2
  if ! "$VENV/bin/pip" install --quiet --disable-pip-version-check -U openai-whisper >&2; then
    echo "[claude-transcribe] pip install openai-whisper failed" >&2
    exit 0
  fi
fi

touch "$FLAG"
echo "[claude-transcribe] dependencies installed" >&2
exit 0
