#!/usr/bin/env bash
set -euo pipefail
kimodo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$kimodo_root"
export CHECKPOINT_DIR="$kimodo_root/models"
export TEXT_ENCODER_MODE=local
export SERVER_NAME=127.0.0.1
export SERVER_PORT="${SERVER_PORT:-7860}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-4}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-4}"
# The embedded avatar renderer is served locally; no dataset browser is opened.
if [[ -z "${KIMODO_VRM_PREVIEW_URL:-}" ]] && systemctl --user cat bones-seed-viewer.service >/dev/null 2>&1; then
    systemctl --user start bones-seed-viewer.service
fi
exec /home/imlab/anaconda3/envs/kimodo/bin/kimodo_demo --model Kimodo-SOMA-RP-v1.1 "$@"
