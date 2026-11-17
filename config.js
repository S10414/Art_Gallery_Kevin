// 共用儲存設定。兩個欄位都留空 = 作品只存在訪客自己的瀏覽器。
// 填上 Supabase 專案的 URL 與 publishable（anon）key 後，上傳的作品所有訪客都看得到。
// 設定步驟見 README。這把 key 本來就是公開用的；絕對不要把 service_role / secret key 放在這裡。
window.GALLERY_CONFIG = {
  supabaseUrl: "",
  supabaseKey: "",
  bucket: "artworks"
};
