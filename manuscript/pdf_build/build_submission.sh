#!/usr/bin/env bash
# Rebuild submission PDF + DOCX from the markdown sources.
# Requires: pandoc (>= 2.5), xelatex (TinyTeX or full TeX Live).
#
# Usage:  bash build_submission.sh
# Output: ../MattersArising_v0.3.pdf, ../MattersArising_v0.3.docx,
#         ../CoverLetter.pdf,         ../CoverLetter.docx

set -euo pipefail

cd "$(dirname "$0")"

# Add TinyTeX to PATH if installed in $HOME (no-op if already on PATH).
if [ -d "$HOME/.TinyTeX/bin/x86_64-linux" ]; then
    export PATH="$HOME/.TinyTeX/bin/x86_64-linux:$PATH"
fi

command -v pandoc  >/dev/null || { echo "pandoc not found";  exit 1; }
command -v xelatex >/dev/null || { echo "xelatex not found (install TinyTeX or TeX Live)"; exit 1; }

# ---- PDF ----------------------------------------------------------------
echo "[1/4] MattersArising_v0.3.pdf ..."
pandoc MattersArising_submission.md \
    -o ../MattersArising_v0.3.pdf \
    --pdf-engine=xelatex

echo "[2/4] CoverLetter.pdf ..."
pandoc CoverLetter_submission.md \
    -o ../CoverLetter.pdf \
    --pdf-engine=xelatex

# ---- DOCX ---------------------------------------------------------------
# Word reads PDF figures inconsistently; the markdown sources still point
# at PDFs for LaTeX, so we substitute to PNGs on the fly for the .docx pass.
echo "[3/4] MattersArising_v0.3.docx ..."
sed 's|Figure1_v2/Figure1_v2\.pdf|Figure1_v2/Figure1_v2.png|g; s|Figure1_final/Figure1\.pdf|Figure1_final/Figure1.png|g' \
    MattersArising_submission.md \
  | pandoc -f markdown -o ../MattersArising_v0.3.docx

echo "[4/4] CoverLetter.docx ..."
pandoc CoverLetter_submission.md -o ../CoverLetter.docx

echo "Done."
ls -lh ../MattersArising_v0.3.pdf ../MattersArising_v0.3.docx \
       ../CoverLetter.pdf         ../CoverLetter.docx
