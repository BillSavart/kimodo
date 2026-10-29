# Kimodo 本機使用

官方來源：https://github.com/nv-tlabs/kimodo

程式：`/home/imlab/Desktop/Bill/kimodo`

Python 環境：`/home/imlab/anaconda3/envs/kimodo`（conda 環境名稱 `kimodo`）

預設動作模型：`Kimodo-SOMA-RP-v1.1`，已下載至 `models/Kimodo-SOMA-RP-v1.1/`。此模型是 NVIDIA 官方預訓練權重，與本機先前訓練的 MLD 無關。

## 首次使用：Llama 模型權限

Kimodo 使用 Llama 3 8B + LLM2Vec 將文字轉成動作條件。LLM2Vec 的兩個 adapter 已下載；Llama 基礎模型需先獲准存取。

1. 登入 https://huggingface.co ，使用與本機 `hf auth whoami` 相同的帳號。
2. 開啟 https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct 。
3. 在 Model card 頁籤找到「You need to agree to share your contact information to access this model」。往下捲至授權條款下的表單。
4. 填寫頁面要求的資料，閱讀並自行同意條款，送出存取申請。若顯示 pending，需等待核准。
5. 若瀏覽器使用另一個帳號，請在終端機執行 `/home/imlab/anaconda3/envs/kimodo/bin/hf auth login`，登入獲准的帳號。不要將 token 貼到聊天或寫入專案。

## 啟動官方介面

```bash
cd /home/imlab/Desktop/Bill/kimodo
./start-demo.sh
```

第一次會下載 Llama 權重（約 16 GB），並載入文字編碼與動作模型。等待終端機顯示服務已啟動，再在瀏覽器開啟 http://127.0.0.1:7860 。此腳本使用本機文字編碼器，並只允許本機連線。

載入 LLM2Vec 時出現 `lm_head.weight UNEXPECTED` 與多筆 LoRA `MISSING`／`UNEXPECTED` 是官方已說明的預期訊息，見 [Quick Start](https://github.com/nv-tlabs/kimodo/blob/main/docs/source/getting_started/quick_start.md#run-text-encoder-service)。官方程式會接著用 PEFT 載入 adapter。不要僅因這份中途載入報告重新訓練或刪除權重；以後續是否成功載入與實際生成結果判斷。

保留啟動終端機；按 Ctrl+C 停止。沒有安裝背景服務或開機自動啟動。

## 生成與播放

- 關閉首次使用說明，雙擊時間軸上的文字 prompt，輸入英文動作，例如 `A person walks forward.`。
- 在 Generate 頁籤設定長度與生成參數，按 Generate。
- 滑鼠左鍵拖曳旋轉、右鍵平移、滾輪縮放。
- 空白鍵播放／暫停；左右方向鍵逐幀檢視。
- 也可載入官方 Examples，查看文字、路徑與姿勢約束。
- 儲存／匯出功能位於介面的 Save/Load 控制。

RTX 3090 有 24 GB VRAM，可先使用預設 GPU 模式。若其他程式占用顯示記憶體，可先關閉那些工作；也可用 `TEXT_ENCODER_DEVICE=cpu ./start-demo.sh` 將文字編碼放到 CPU，但速度會較慢。

官方教學：https://research.nvidia.com/labs/sil/projects/kimodo/docs/interactive_demo/index.html

## 2026-10-11 安裝驗證

- 官方程式版本：`58e781898b3d7e328a676a75d3e338c45dce3ad9`。
- Python 3.10、PyTorch `2.7.1+cu118`；RTX 3090 CUDA 運算檢查通過。
- 官方 Kimodo、Viser fork、SOMA-X 與 MotionCorrection 已安裝；`pip check` 通過。
- `kimodo_demo --help` 正常執行。
- 官方 Viser 前端編譯完成，測試服務回傳 HTTP 200；測試服務已停止。
- `Kimodo-SOMA-RP-v1.1` 的 283,281,777 參數 denoiser 成功載入 GPU；官方 SOMA skin 成功載入。
- 初次啟動曾因 Llama 權限等待審核而回傳 HTTP 403；後續使用者啟動紀錄已顯示 Llama 下載完成及 `Model kimodo-soma-rp-v1.1 loaded successfully`。
- 已確認正式 Kimodo 程序在執行，`http://127.0.0.1:7860` 回傳 HTTP 200。尚未驗證實際動作生成與播放。
- 已安裝套件記錄於 `local-requirements.freeze.txt`（供診斷與版本參考）。
