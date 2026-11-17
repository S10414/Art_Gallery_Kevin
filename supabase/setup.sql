-- 線上展間：共用儲存設定（所有人可看，只有管理員能上傳）
-- 在 Supabase 專案的 SQL Editor 貼上整份執行一次即可。

-- 1) 作品資料表：一個畫框（slot 0–11）一筆
create table if not exists public.works (
  slot        int primary key check (slot between 0 and 11),
  title       text not null default '' check (char_length(title)  <= 80),
  artist      text not null default '' check (char_length(artist) <= 60),
  year        text not null default '' check (char_length(year)   <= 30),
  medium      text not null default '' check (char_length(medium) <= 80),
  description text not null default '' check (char_length(description) <= 800),
  image_url   text not null check (char_length(image_url) <= 500),
  updated_at  timestamptz not null default now()
);
alter table public.works enable row level security;

-- 2) 管理員名單。沒有任何 policy，前端讀不到也寫不進，只能透過下面的函式。
create table if not exists public.admins (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.admins enable row level security;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.admins where user_id = (select auth.uid()));
$$;

-- 第一個登入並呼叫這個函式的帳號會成為唯一的管理員；之後任何人呼叫都只會回傳自己是不是管理員。
create or replace function public.claim_admin()
returns boolean language plpgsql security definer set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    return false;
  end if;
  lock table public.admins in share row exclusive mode;
  if not exists (select 1 from public.admins) then
    insert into public.admins (user_id) values ((select auth.uid()));
  end if;
  return exists (select 1 from public.admins where user_id = (select auth.uid()));
end;
$$;

revoke execute on function public.claim_admin() from public, anon;
grant  execute on function public.claim_admin() to authenticated;
revoke execute on function public.is_admin() from public;
grant  execute on function public.is_admin() to anon, authenticated;

-- 3) 權限：所有人可讀，只有管理員可新增／修改／刪除
drop policy if exists "works: public read"  on public.works;
drop policy if exists "works: admin insert" on public.works;
drop policy if exists "works: admin update" on public.works;
drop policy if exists "works: admin delete" on public.works;
create policy "works: public read"  on public.works for select using (true);
create policy "works: admin insert" on public.works for insert to authenticated with check ((select public.is_admin()));
create policy "works: admin update" on public.works for update to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "works: admin delete" on public.works for delete to authenticated using ((select public.is_admin()));

-- 4) 圖片儲存桶：公開讀取（靠公開網址），單檔上限 5 MB，只收圖片；只有管理員能上傳／刪除
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('artworks', 'artworks', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists "artworks: admin upload" on storage.objects;
drop policy if exists "artworks: admin delete" on storage.objects;
create policy "artworks: admin upload" on storage.objects for insert to authenticated
  with check (bucket_id = 'artworks' and (select public.is_admin()));
create policy "artworks: admin delete" on storage.objects for delete to authenticated
  using (bucket_id = 'artworks' and (select public.is_admin()));
