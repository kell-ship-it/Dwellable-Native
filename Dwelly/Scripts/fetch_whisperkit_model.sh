#!/bin/bash
# Fetches the WhisperKit "openai_whisper-base" CoreML model and bundles it into
# the app binary at build time, so the model is present at install time with
# zero network dependency on first launch.
#
# Why a build-time fetch script instead of Git LFS (T-097):
# Git LFS adds an external dependency every contributor and CI runner must have
# installed and configured before `git clone` even produces the right files —
# a silent trap if someone's clone quietly gets pointer files instead of the
# ~140MB model. A build-time fetch avoids that: the model is cached on disk by
# this script and simply re-downloaded (once) on a clean machine, like any other
# external dependency (e.g. SPM packages already work this way for WhisperKit
# itself). The raw model is never committed to git either way.
set -euo pipefail

MODEL_REPO="argmaxinc/whisperkit-coreml"
MODEL_VARIANT="openai_whisper-base"
BASE_URL="https://huggingface.co/${MODEL_REPO}/resolve/main/${MODEL_VARIANT}"

FILES=(
  "config.json"
  "generation_config.json"
  "AudioEncoder.mlmodelc/coremldata.bin"
  "AudioEncoder.mlmodelc/metadata.json"
  "AudioEncoder.mlmodelc/model.mil"
  "AudioEncoder.mlmodelc/weights/weight.bin"
  "TextDecoder.mlmodelc/coremldata.bin"
  "TextDecoder.mlmodelc/metadata.json"
  "TextDecoder.mlmodelc/model.mil"
  "TextDecoder.mlmodelc/weights/weight.bin"
  "MelSpectrogram.mlmodelc/coremldata.bin"
  "MelSpectrogram.mlmodelc/metadata.json"
  "MelSpectrogram.mlmodelc/model.mil"
  "MelSpectrogram.mlmodelc/weights/weight.bin"
)

# Persistent cache outside DerivedData so a clean build doesn't re-download.
CACHE_DIR="${HOME}/Library/Caches/Dwelly/WhisperKitModel/${MODEL_VARIANT}"
mkdir -p "$CACHE_DIR"

echo "WhisperKit model fetch: caching to ${CACHE_DIR}"

download_failed=0
for f in "${FILES[@]}"; do
  dest="${CACHE_DIR}/${f}"
  mkdir -p "$(dirname "$dest")"
  if [ -s "$dest" ]; then
    continue
  fi
  echo "Fetching ${f}..."
  if ! curl -sSL --fail -o "${dest}.part" "${BASE_URL}/${f}"; then
    echo "warning: failed to download ${f} (offline?)"
    rm -f "${dest}.part"
    download_failed=1
    continue
  fi
  mv "${dest}.part" "$dest"
done

if [ "$download_failed" -ne 0 ]; then
  echo "warning: WhisperKit model fetch incomplete — app will fall back to downloading the model at runtime."
fi

# Only stage into the app bundle if we actually have a complete model cached
# (either from this run or a previous one).
all_present=1
for f in "${FILES[@]}"; do
  if [ ! -s "${CACHE_DIR}/${f}" ]; then
    all_present=0
    break
  fi
done

if [ "$all_present" -ne 1 ]; then
  echo "WhisperKit model not fully cached — skipping bundle step, app will use the network fallback."
  exit 0
fi

if [ -z "${BUILT_PRODUCTS_DIR:-}" ] || [ -z "${CONTENTS_FOLDER_PATH:-}" ]; then
  echo "warning: build environment variables not set — skipping bundle step (not running inside Xcode?)."
  exit 0
fi

DEST_DIR="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/WhisperKitModel/${MODEL_VARIANT}"
mkdir -p "$DEST_DIR"
rsync -a --delete "${CACHE_DIR}/" "${DEST_DIR}/"
echo "WhisperKit model bundled at ${DEST_DIR}"
