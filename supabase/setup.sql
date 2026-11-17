-- 線上展間：共用儲存設定
-- 在 Supabase 專案的 SQL Editor 貼上整份執行一次即可。

-- 1) 作品資料表：一個畫框（slot 0–8）一筆
create table if not exists public.works (
  slot        int primary key check (slot between 0 and 8),
  title       text not null default '' check (char_length(title)  <= 80),
  artist      text not null default '' check (char_length(artist) <= 60),
  year        text not null default '' check (char_length(year)   <= 30),
  medium      text not null default '' check (char_length(medium) <= 80),
  description text not null default '' check (char_length(description) <= 800),
  image_url   text not null check (char_length(image_url) <= 500),
  updated_at  timestamptz not null default now()
);

alter table public.works enable row level security;

-- 所有人都能看
create policy "works: public read" on public.works
  for select using (true);

-- ⚠️ 下面三條讓「任何訪客」都能新增、覆蓋、移除作品（不需登入）。
-- 這是最簡單的共用模式，適合展示或朋友間使用。
-- 若只想讓自己上傳，把這三條的 (true) 改成 (auth.role() = 'authenticated')，
-- 再替網站加上 Supabase Auth 登入。
create policy "works: public insert" on public.works
  for insert with check (true);
create policy "works: public update" on public.works
  for update using (true) with check (true);
create policy "works: public delete" on public.works
  for delete using (true);

-- 2) 圖片儲存桶：公開讀取，單檔上限 5 MB，只收圖片
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('artworks', 'artworks', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

create policy "artworks: public read" on storage.objects
  for select using (bucket_id = 'artworks');
create policy "artworks: public upload" on storage.objects
  for insert with check (bucket_id = 'artworks');
