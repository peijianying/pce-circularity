#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# run_all.sh — reproduce all results end-to-end.
#
# Usage (from repository root):
#     bash code/run_all.sh
#
# Steps:
#   1. Download public data (idempotent)
#   2. Run the simulation (Figure 1A-C inputs)
#   3. Run the TCGA reanalysis (Figure 1D-F inputs)
#   4. Render the final composite figure
#
# Total runtime: ~2 minutes (download time excluded; ~5 minutes with download)
# ----------------------------------------------------------------------------
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

echo "[1/4] Fetching public data..."
bash code/fetch_data.sh

echo "[2/4] Running PCE circularity simulation..."
Rscript code/01_PCE_circularity_simulation.R

echo "[3/4] Running TMB-purity reanalysis..."
Rscript code/02_TMB_purity_reanalysis.R

echo "[4/4] Rendering Figure 1..."
Rscript code/03_Figure1_final.R

echo
echo "Done. Main outputs:"
echo "  - results/Figure1_final/Figure1.pdf"
echo "  - results/Figure1_final/Figure1.png"
echo "  - results/TMB_purity_correlation_table.csv"
echo "  - results/PCE_threshold_sensitivity.csv"
