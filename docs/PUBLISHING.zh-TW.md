# 上傳 GitHub

建議 repository 名稱：`hd2-c4-quick-actions`。

英文 description：`PC mouse and keyboard C4 deployment and detonation controls for Helldivers 2.`

1. 建立 repository，將本資料夾內的檔案放在 repository 根目錄。`README.md`、`LICENSE`、`src/` 等應直接位於根目錄。
2. 若使用 GitHub 網頁上傳，先解開整份資料 ZIP 再上傳內容；整份資料 ZIP 不是遊戲安裝包。保留 `.gitignore` 與 `.gitattributes`。
3. 0.7.0 目前只有新遊戲版本的唯讀狀態核對與離線輸入檢查，尚未實際觸發投擲／引爆。完成遊戲內驗收後，若日後發布，可建立 tag／Release `v0.7.0`，附上 `dist/HD2-C4-Quick-Actions-v0.7.0-PC.zip` 與 `dist/SHA256SUMS.txt`。本次公開原始碼，但不建立 GitHub Release。
4. Release 內容可使用下方文字。程式、文件採 MIT，Loader 為另外安裝的依賴。

## Release 文字

HD2 C4 Quick Actions v0.7.0 (PC)

- Independent C4 deploy and detonate controls: mouse LMB/RMB. This version has no controller input route.
- Automatic activation while C4 is equipped; no F6 required.
- Reload no longer permanently disables the mapping.
- Static and read-only live context checks target Helldivers 2 build 25480438. Actual 0.7.0 action calls, visual effects and the full multiplayer/UI matrix remain unverified.
- Requires Bingus Shared Loader v18 / API 1, installed separately.

Download the mod ZIP attached to this release, import it into your mod manager, enable it alongside the loader and deploy. Replace earlier C4 experiment packages.

完整驗證範圍與研究資料已放在 repository。原始碼上傳與 Release 發布是分開的步驟；建立 Release 時請附上 dist/ 內的模組 ZIP 與校驗檔。
