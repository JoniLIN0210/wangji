-- 六月的小本子：在 Supabase 的 SQL Editor 里整段运行一次

-- 1. 存记录的表：每个账号一行
create table if not exists public.liuyue_docs (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);
alter table public.liuyue_docs enable row level security;
grant select, insert, update on public.liuyue_docs to authenticated;
drop policy if exists "read own" on public.liuyue_docs;
drop policy if exists "insert own" on public.liuyue_docs;
drop policy if exists "update own" on public.liuyue_docs;
create policy "read own"   on public.liuyue_docs for select using (auth.uid() = user_id);
create policy "insert own" on public.liuyue_docs for insert with check (auth.uid() = user_id);
create policy "update own" on public.liuyue_docs for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 2. 存照片的私有空间：每个账号只能读写自己文件夹
insert into storage.buckets (id, name, public) values ('photos', 'photos', false) on conflict (id) do nothing;
drop policy if exists "photos read own" on storage.objects;
drop policy if exists "photos insert own" on storage.objects;
drop policy if exists "photos update own" on storage.objects;
drop policy if exists "photos delete own" on storage.objects;
create policy "photos read own"   on storage.objects for select using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos insert own" on storage.objects for insert with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos update own" on storage.objects for update using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos delete own" on storage.objects for delete using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
