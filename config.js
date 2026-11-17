// 共用儲存設定。兩個欄位都留空 = 作品只存在訪客自己的瀏覽器。
// 這把 publishable key 本來就是公開用的，權限由資料庫的 RLS 規則把關。
// 絕對不要把 service_role / secret key 放在這裡。
window.GALLERY_CONFIG = {
  supabaseUrl: "https://ijfkirvardfbebxqwwga.supabase.co",
  supabaseKey: "sb_publishable_cfD0ndYyRCwDakAtUDamCg_eKBgTVnw",
  bucket: "artworks"
};
