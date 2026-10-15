-- Таблица для синхронизации заметок. Выполните целиком в Supabase → SQL Editor → New query → Run.
create table if not exists public.notes_state (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

-- Каждый пользователь видит и меняет только свои заметки
alter table public.notes_state enable row level security;

drop policy if exists "own notes select" on public.notes_state;
drop policy if exists "own notes insert" on public.notes_state;
drop policy if exists "own notes update" on public.notes_state;
drop policy if exists "own notes delete" on public.notes_state;

create policy "own notes select" on public.notes_state for select using (auth.uid() = user_id);
create policy "own notes insert" on public.notes_state for insert with check (auth.uid() = user_id);
create policy "own notes update" on public.notes_state for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own notes delete" on public.notes_state for delete using (auth.uid() = user_id);
