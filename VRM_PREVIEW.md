# Kimodo 生成介面的 VRoid 預覽

開啟 **http://127.0.0.1:7860/**。這是 Kimodo 原本的文字生成、時間軸與約束編輯介面，現在加入 `AvatarSample_M.vrm` 的預覽。

`http://127.0.0.1:8666/` 則是 BONES-SEED 動作庫。兩個頁面的用途不同。

## 使用

1. 在 Kimodo 頁面選 SOMA 模型；`Skeleton` 指的是生成模型的骨架。
2. 保持 **VRoid Preview** 勾選，播放外觀就會使用你的 VRoid。
3. 雙擊時間軸文字修改動作描述，按 **Generate**。
4. 生成完成後，結果自動套用到 VRoid。無須匯出 NPZ、換頁或手動選檔。
5. 點 3D 畫面後可用空白鍵播放／暫停，左右方向鍵逐幀移動；也可使用原時間軸。
6. 取消 **VRoid Preview** 可看原始 SOMA。進入 Editing Mode 時會自動切回原始約束視圖，離開後恢復 VRoid。

模型仍由 Kimodo 在 SOMA 骨架上生成，預覽再將動作重定向到 VRM；沒有另外訓練 VRoid 動作模型。

## 多樣本與限制

- 多樣本會在預覽中並排顯示。要採用某個樣本，先取消 VRoid Preview，在原始視圖點選樣本，再切回 VRoid。
- SOMA 生成、載入動作、載入範例都會經由同一個 `add_character_motion` 入口自動同步。
- G1／SMPL-X 使用原始預覽；目前 VRoid 重定向支援 SOMA。
- 約束與 gizmo 編輯仍在原始 SOMA 視圖進行，VRoid 顯示結果。
- 原本的 NPZ／BVH 匯出保留 SOMA 動作資料。原生 Download Screenshot／Video 擷取的是 Viser 的原始畫布，尚未改為擷取嵌入的 VRoid 畫布。
- 預覽包含基本地面補正與 VRM Spring Bone 更新，沒有新增完整腳鎖定／道具接觸 IK。
- 每個瀏覽器連線維持自己的動作與預覽；重新整理會建立新的 Kimodo session。

## 啟動

```bash
cd /home/imlab/Desktop/Bill/kimodo
./start-demo.sh
```

腳本會啟動本機 avatar 資源服務，然後載入 Kimodo。原始啟動方式與文字編碼器設定仍適用。沒有增加開機自動啟動。

目前已啟動的測試程序使用本機快取權重，日誌位於 `/tmp/kimodo-vrm.log`。

## 實作

- `kimodo/demo/vrm_preview.py`：將 Kimodo session 的完整動作轉成標準 T-pose BVH，送到對應瀏覽器。
- `kimodo/demo/vrm_preview.js`：在 Kimodo 的 3D 視窗內建立預覽，傳遞動作與時間軸影格。
- `seed-viewer/frontend/public/kimodo-preview.html` 與 `src/kimodo_preview.ts`：獨立的 VRoid 渲染畫布，沒有 BONES-SEED 清單或 metadata 介面。
- 沿用已驗證的 `VRMModel` 重定向，包含 54 個人形骨骼。

預覽資源預設來自 `http://127.0.0.1:8666/kimodo-preview.html`，可用 `KIMODO_VRM_PREVIEW_URL` 覆寫。動作直接由 Kimodo 的本機連線傳送到嵌入預覽，沒有上傳外部服務。

驗證結果與畫面保存在 `../bones-example/kimodo-vrm-generation-verification.json` 與 `../bones-example/kimodo-vrm-generated.png`。

已在真正的 Kimodo 介面按 Generate，使用 `Kimodo-SOMA-RP-v1.1` 在 GPU 生成 `A person walks forward.`，共 180 幀、30 fps。驗證了結果自動套用、54 個骨骼、播放／暫停、方向鍵逐幀、取消／恢復預覽，以及進出 Editing Mode 的視圖切換；瀏覽器未回報程式錯誤。前端正式 build、Python 與 JavaScript 語法檢查通過。
