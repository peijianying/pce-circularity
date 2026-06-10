#!/usr/bin/env bash
# Rebuild submission PDFs from the markdown sources.
# Requires: pandoc, xelatex (TinyTeX or full TeX Live).
#
# Usage:  bash build_pdf.sh
# Output: ../MattersArising_v0.3.pdf, ../CoverLetter.pdf

set -euo pipefail

cd "$(dirname "$0")"

# Add TinyTeX to PATH if installed in $HOME (no-op if already on PATH).
if [ -d "$HOME/.TinyTeX/bin/x86_64-linux" ]; then
    export PATH="$HOME/.TinyTeX/bin/x86_64-linux:$PATH"
fi

command -v pandoc   >/dev/null || { echo "pandoc not found"; exit 1; }
command -v xelatex  >/dev/null || { echo "xelatex not found (install TinyTeX or TeX Live)"; exit 1; }

echo "[1/2] Rendering MattersArising_v0.3.pdf ..."
pandoc MattersArising_submission.md -o ../MattersArising_v0.3.pdf --pdf-engine=xelatex

echo "[2/2] Rendering CoverLetter.pdf ..."
pandoc CoverLetter_submission.md   -o ../CoverLetter.pdf       --pdf-engine=xelatex

echo "Done."
ls -lh ../MattersArising_v0.3.pdf ../CoverLetter.pdf
