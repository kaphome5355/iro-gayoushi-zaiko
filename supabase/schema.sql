-- 色画用紙の在庫：データベースの形（Supabase / PostgreSQL）
-- 参考用。実際のデータベースには作成済みです。
create table public.stock (
  code text primary key,
  n integer not null default 0 check (n >= 0),
  min integer not null default 0 check (min >= 0),
  updated_at timestamptz not null default now()
);
create table public.logs (
  id bigint generated always as identity primary key,
  t timestamptz not null default now(),
  code text not null references public.stock(code),
  d integer not null,
  a integer not null,
  k text not null check (k in ('step','set'))
);
alter table public.stock enable row level security;
alter table public.logs enable row level security;
create policy "read stock" on public.stock for select to anon, authenticated using (true);
create policy "read logs" on public.logs for select to anon, authenticated using (true);
-- 書きこみは change_stock / set_stock / undo_log の3つの関数からだけ行います。

-- リアルタイム：在庫と記録の変更を、開いている画面にすぐ知らせる
alter publication supabase_realtime add table public.stock, public.logs;
alter table public.logs replica identity full;
