![HD2 C4 Quick Actions — C4 實機畫面封面](assets/cover.png)

# HD2 C4 Quick Actions

[English](README.md)

《絕地戰兵 2》C4 的 **PC 滑鼠鍵盤版**：手持 C4 引爆器時，**滑鼠左鍵投擲，右鍵引爆**。拿出 C4 後自動啟用，不受遊戲目前選擇的 C4 射擊模式影響；其他武器維持原本滑鼠操作。0.7.0 不讀取手柄輸入。

## 安裝

1. 退出遊戲，另外安裝 [Bingus Shared Loader v18](https://github.com/CowboyBingus/BingusSharedLoader/releases/tag/v18)。
2. 將 [HD2-C4-Quick-Actions-v0.7.0-PC.zip](dist/HD2-C4-Quick-Actions-v0.7.0-PC.zip) 匯入 Mod Manager，啟用本模組及 Loader，再部署。
3. 停用舊版 C4 Quick Actions，同時只啟用一個版本。

`dist/` 內的 ZIP 是安裝包；GitHub 的 Source code ZIP 是開發資料。建置僅在本地產生 ZIP，不會自動替換遊戲目錄內的 Mod。

## 操作

| PC 輸入 | C4 動作 |
| --- | --- |
| 滑鼠左鍵 | 投擲 |
| 滑鼠右鍵 | 引爆 |

拿出 C4 引爆器後，先放開滑鼠左右鍵再按下。無須 F6；長按不連發，同時按兩鍵時以引爆優先。R 維持遊戲原本補彈流程。補彈、選單、顯示游標或失焦時暫停自訂動作，恢復後先放開按鍵再重新按下。F7 可寫入診斷標記。

模組沿用遊戲原生 C4 動作生命週期，不直接建立炸藥或爆炸。原版瞄準行為保留；切換其他武器或暫停時，會恢復原本的武器輸入。

## 相容性與驗證

0.7.0 以 Steam 遊戲 build **`25480438`** 為目標，啟動與每次動作前會核對 `game.dll` 雜湊及 28 處程式指紋。已在實際任務中以**唯讀方式**確認本機 C4 身份、兩種射擊模式、資源與動作准入狀態；PC 輸入經離線測試。**此新安裝包尚未在遊戲中實際執行投擲／引爆。** 動畫、畫面效果、多人與特殊 UI／移動狀態仍待實機驗收。

舊 0.6.x 實機記錄對應 build `24826606`，不能作為 0.7.0 的實機通過證據。詳見 [驗證紀錄](docs/VALIDATION.md)。歷史手柄版本仍保留於 repository，本版不提供手柄路由。

## 從原始碼建置

需 Python 3.10+ 與 LuaJIT 2.1：

```bash
python -B scripts/check_pc.py
python -B scripts/build.py --loader /path/to/BingusSharedLoader-v18
```

打包工具版本鎖定於 [dependencies.lock.json](dependencies.lock.json)。詳見 [建置方法](docs/BUILDING.md)、[架構](docs/ARCHITECTURE.md) 與 [研究索引](research/README.md)。專案原創程式與文件採 [MIT 授權](LICENSE)；第三方來源見 [THIRD_PARTY.md](THIRD_PARTY.md)。研究、程式與文件有 AI 協助，實機唯讀觀察與模擬檢查會分開標示。

此 repository 保留 [etxp/HD2-C4-Quick-Actions](https://github.com/etxp/HD2-C4-Quick-Actions) 先前的 Git 歷史；此處的 0.7.0 PC 專用版為獨立保存的版本。
