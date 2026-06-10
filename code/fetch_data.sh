#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# fetch_data.sh — download all public input data needed to reproduce results.
#
# Run from the repository root:
#     bash code/fetch_data.sh
#
# Downloads ~80 MB and verifies file integrity. Idempotent — re-running is safe.
# ----------------------------------------------------------------------------
set -euo pipefail

# Run from repo root regardless of where this script is invoked from.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"
mkdir -p data
cd data

dl_if_missing() {
  local url="$1" out="$2"
  if [[ -s "${out}" ]]; then
    echo "[skip] ${out} already exists"
    return 0
  fi
  echo "[get ] ${out}  <-  ${url}"
  curl --fail --silent --show-error --location --retry 5 --retry-delay 5 \
       --max-time 1800 -o "${out}" "${url}"
}

echo "=== TCMA decontaminated microbiome profiles (Dohlman et al. 2021) ==="
dl_if_missing "https://duke.tind.io/record/126/files/README.txt"   README.txt
dl_if_missing "https://duke.tind.io/record/126/files/metadata.zip" metadata.zip
dl_if_missing "https://duke.tind.io/record/126/files/WGS.zip"      WGS.zip
dl_if_missing "https://duke.tind.io/record/126/files/WXS.zip"      WXS.zip

echo "=== Extracting TCMA archives ==="
[[ -d metadata ]] || unzip -q -o metadata.zip -d metadata/
[[ -d WGS      ]] || (mkdir -p WGS && unzip -q -o WGS.zip -d WGS/)
[[ -d WXS      ]] || (mkdir -p WXS && unzip -q -o WXS.zip -d WXS/)

echo "=== TCGA ABSOLUTE-derived purity (Aran 2015) ==="
dl_if_missing \
  "https://raw.githubusercontent.com/judithabk6/ITH_TCGA/master/external_data/TCGA_mastercalls.abs_tables_JSedit.fixed.txt" \
  TCGA_ABSOLUTE_purity.tsv

echo "=== MC3 v0.2.8 PUBLIC non-silent gene matrix (UCSC Xena mirror) ==="
dl_if_missing \
  "https://pancanatlas.xenahubs.net/download/mc3.v0.2.8.PUBLIC.nonsilentGene.xena.gz" \
  mc3.nonsilent.gene.matrix.gz

# Validate the gz file is complete (Xena occasionally drops connections)
if ! gzip -t mc3.nonsilent.gene.matrix.gz 2>/dev/null; then
  echo "[warn] mc3.nonsilent.gene.matrix.gz is truncated; retrying..."
  rm -f mc3.nonsilent.gene.matrix.gz
  curl --fail --silent --show-error --location --retry 8 --retry-delay 5 \
       -o mc3.nonsilent.gene.matrix.gz \
       "https://pancanatlas.xenahubs.net/download/mc3.v0.2.8.PUBLIC.nonsilentGene.xena.gz"
  gzip -t mc3.nonsilent.gene.matrix.gz
fi

echo
echo "=== All data downloaded successfully ==="
echo "Disk usage:"
du -sh "${ROOT_DIR}/data"
