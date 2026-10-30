#!/usr/bin/env bash
# Ubuntu launcher for the existing Kimodo + VRoid environment.
set -euo pipefail

DEMO_BASE="${DEMO_ROOT:-$HOME/Desktop/Bill}"
VIEWER_DIR="$DEMO_BASE/seed-viewer"
KIMODO_DIR="$DEMO_BASE/kimodo"
VIEWER_PYTHON="$VIEWER_DIR/.venv/bin/python"
DEMO_URL="http://127.0.0.1:7860/"
PREVIEW_URL="http://127.0.0.1:8666/kimodo-preview.html"
viewer_pid=""
browser_pid=""

fail() { printf '錯誤：%s\n' "$*" >&2; exit 1; }
ready() { curl --noproxy '*' -fsS --max-time 2 -o /dev/null "$1"; }
cleanup() {
    [[ -z "$browser_pid" ]] || kill "$browser_pid" 2>/dev/null || true
    [[ -z "$viewer_pid" ]] || kill "$viewer_pid" 2>/dev/null || true
}
trap cleanup EXIT

command -v curl >/dev/null || fail '需要 curl，請先安裝：sudo apt install curl'
[[ -f "$KIMODO_DIR/start-demo.sh" ]] || fail "找不到 $KIMODO_DIR/start-demo.sh；請確認 Kimodo 使用 work/vrm-preview 分支。"
[[ -f "$VIEWER_DIR/frontend/public/kimodo-preview.html" ]] || fail '請確認 seed-viewer 使用 work/ssd-vrm-viewer 分支。'

printf '啟動 Viewer…\n'
if ready "$PREVIEW_URL" 2>/dev/null; then
    printf 'Viewer 已在執行。\n'
elif command -v systemctl >/dev/null && systemctl --user cat bones-seed-viewer.service >/dev/null 2>&1; then
    systemctl --user start bones-seed-viewer.service
else
    [[ -x "$VIEWER_PYTHON" ]] || fail "找不到 Viewer 環境：$VIEWER_PYTHON"
    (
        cd "$VIEWER_DIR/backend/src"
        export DATA_ROOT="$DEMO_BASE/bones-seed"
        export DATA_FILES_ROOT="$DATA_ROOT"
        export BONES_ARCHIVE_ROOT="$DATA_ROOT"
        exec "$VIEWER_PYTHON" -m uvicorn main:app --host 127.0.0.1 --port 8666
    ) > "$DEMO_BASE/viewer-demo.log" 2>&1 &
    viewer_pid=$!
fi

viewer_ready=false
for ((attempt=0; attempt<60; attempt++)); do
    if ready "$PREVIEW_URL" 2>/dev/null; then viewer_ready=true; break; fi
    sleep 1
done
[[ "$viewer_ready" == true ]] || fail "Viewer 未就緒。請查看 $DEMO_BASE/viewer-demo.log 或 journalctl --user -u bones-seed-viewer.service -n 50。"
curl --noproxy '*' -fsS --max-time 15 --range 0-0 -o /dev/null \
    http://127.0.0.1:8666/api/avatar || fail "找不到角色，請確認 $DEMO_BASE/AvatarSample_M.vrm 存在。"

if ready "$DEMO_URL" 2>/dev/null; then
    printf 'Kimodo 已在執行：%s\n' "$DEMO_URL"
    if [[ -n "$viewer_pid" ]]; then
        printf '保留此終端機以提供 VRoid 資源；按 Ctrl+C 結束。\n'
    fi
    if command -v xdg-open >/dev/null && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
        xdg-open "$DEMO_URL" >/dev/null 2>&1 || true
    fi
    if [[ -n "$viewer_pid" ]]; then wait "$viewer_pid"; fi
    exit 0
fi

# Open the page once Kimodo is ready; keep generation logs in this terminal.
(
    for ((attempt=0; attempt<900; attempt++)); do
        if ready "$DEMO_URL" 2>/dev/null; then
            if command -v xdg-open >/dev/null && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
                xdg-open "$DEMO_URL" >/dev/null 2>&1 || true
            fi
            exit 0
        fi
        sleep 1
    done
    printf '請查看 Kimodo 載入訊息，或手動開啟 %s\n' "$DEMO_URL" >&2
) &
browser_pid=$!

printf '啟動 Kimodo，載入完成後開啟 %s；按 Ctrl+C 結束。\n' "$DEMO_URL"
cd "$KIMODO_DIR"
export KIMODO_VRM_PREVIEW_URL="$PREVIEW_URL"
bash ./start-demo.sh
