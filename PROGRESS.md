# Kimodo fork：目前進度

更新日期：2026-10-29（台北時間）。此 fork 用於管理原 Kimodo repository 上的本機功能修改。

## 來源與分支

- 上游：`nv-tlabs/kimodo`，本次修改起點 `58e781898b3d7e328a676a75d3e338c45dce3ad9`。
- 個人 fork 目標：`BillSavart/kimodo`。
- 開發分支：`work/vrm-preview`；`main` 保留上游版本。
- `upstream` 指向官方 repo，`origin` 指向個人 fork；預設 push 選擇 `origin`。

## 已完成

- 在原生成介面內嵌 VRoid 預覽，沿用 seed-viewer 的 VRM 重定向。
- SOMA 生成、動作載入、清空、時間軸與逐幀播放同步到各自的瀏覽器 session。
- 多樣本並排；切換 Editing Mode 時恢復原本的約束視圖。
- 增加預覽開關、本機啟動腳本、安裝環境與操作說明。

使用方式與限制見 [VRM_PREVIEW.md](VRM_PREVIEW.md)，環境見 [LOCAL_SETUP.md](LOCAL_SETUP.md)。

## 與另一個 fork 的關係

需要 `BillSavart/seed-viewer` 的 `work/ssd-vrm-viewer` 分支提供
`http://127.0.0.1:8666/kimodo-preview.html` 與 avatar API。
可用 `KIMODO_VRM_PREVIEW_URL` 覆寫預覽網址。VRM 角色與模型權重由本機另外準備。

## 驗證與待辦

- 先前已在真正 Kimodo 介面以 GPU 生成 180 幀／30 fps，驗證自動預覽、54 骨骼、播放／暫停、逐幀及 Editing Mode 切換。
- 2026-10-29 整理時 Python／JavaScript 語法與原修改的 Git 空白檢查通過；相依 Viewer 的 production build 及 3 項 NPZ 轉換測試通過。
- 此次沒有重新執行 GPU 生成或瀏覽器互動；先前紀錄位於同層工作區的 `bones-example/`。
- 待辦：移除啟動器的固定 conda 路徑、VRoid 畫布截圖／錄影、多樣本直接點選、腳鎖定與道具接觸。

## 日常管理

```bash
git status
git add <changed-files>
git commit -m "describe the change"
git push -u origin work/vrm-preview
```

更新上游時先保持工作目錄乾淨，再執行 `git fetch upstream`，檢視差異後選擇合併方式。不要將 `models/`、token 或整套資料集加入 Git。
