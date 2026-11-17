# 線上展間 Art Gallery

一間可以在瀏覽器裡逛的 3D 古典展廳：挑高拱頂與天窗、白色壁柱、拱窗、舊木地板，長廊盡頭穿過拱門是一間明亮的後殿。
支援滾動導覽、自由走動、上傳作品掛進畫框、作品說明牌。
純靜態網站（`index.html` + `config.js`），不需要建置步驟，可直接用 GitHub Pages 發布。

## 功能

- **導覽**：向下滑動，鏡頭依序走到 9 件作品前，顯示標題與介紹。
- **自由走動**
  - 鍵盤：方向鍵或 WASD 移動，Q／E 轉頭
  - 觸控板／滾輪：雙指上下滑＝前進後退，左右滑＝轉向
  - 滑鼠：拖曳轉頭
  - 手機：左下搖桿移動，拖曳畫面轉頭
- **上傳作品**：右上「＋ 上傳作品」，選畫框、選圖片、填標題／作者／年份／媒材／介紹。畫框會依圖片比例自動調整，圖片會先縮到長邊 1600px。
- **作品標註**：每幅畫旁有說明牌；點畫作、說明牌或編號圓點可看完整資訊。

## 發布到 GitHub Pages

Settings → Pages → Source 選 `Deploy from a branch`，Branch 選 `main`、資料夾選 `/ (root)`。

## 共用儲存（讓所有訪客看到同一批作品）

`config.js` 留空時，上傳的作品只存在訪客自己的瀏覽器（IndexedDB）。
接上 Supabase 後，作品會存到雲端，所有人看到的都一樣：

1. 在 [supabase.com](https://supabase.com) 建一個專案。
2. 打開 SQL Editor，貼上 [`supabase/setup.sql`](supabase/setup.sql) 整份執行。
3. 到 Project Settings → API，複製 **Project URL** 與 **publishable（anon）key**，填進 `config.js`：

   ```js
   window.GALLERY_CONFIG = {
     supabaseUrl: "https://xxxx.supabase.co",
     supabaseKey: "sb_publishable_...",
     bucket: "artworks"
   };
   ```
4. commit、push，Pages 更新後就生效。

注意：

- publishable／anon key 本來就是放在前端的公開金鑰；**不要**把 `service_role`／secret key 放進這個 repo。
- 預設的 `setup.sql` 讓任何訪客都能上傳與覆蓋作品（不需登入）。若只想自己能上傳，請照 SQL 檔裡的註解改成需要登入。
- 換圖時舊圖檔會留在儲存桶裡，需要時可在 Supabase 後台清理。

## 自訂

- 畫框位置與數量：`index.html` 裡的 `SLOTS`（改數量時，`setup.sql` 的 `slot between 0 and 8` 也要一起改）。
- 展廳尺寸：`W`（寬）、`H`（牆高）、`RISE`（拱頂高度）、`ZF`／`ZB`（前後牆位置）；後殿是 `AW`／`AD`／`AH`。
- 牆面、地板、壁柱、拱窗、拱頂與天窗：`buildRoom()`。
- 可以走到哪裡：`walkable()`。之後要加「走出展廳」的戶外空間，就是在後殿開一道門、在這裡多放行一塊區域。
- 預設示範畫是程式生成的（`genArt()`），不含任何外部圖片。

## 技術

[Three.js](https://threejs.org) r128（從 cdnjs 載入）、原生 JavaScript、Supabase REST／Storage API（選用）。
展廳是用程式搭建的幾何，沒有使用外部 3D 模型。
