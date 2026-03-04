'use client';

import Image from 'next/image';
import { Dispatch, FormEvent, SetStateAction, useEffect, useState } from 'react';
import {
  EventItem,
  GroupItem,
  MassSchedule,
  NewsItem,
  NextMassResponse,
  OfficeHour,
  TabKey,
  User,
} from './home-page.types';

type AuthMode = 'login' | 'register';

type HomeHeaderProps = {
  user: User;
  accessLevelLabel: (level: number) => string;
};

type AuthPanelProps = {
  authMode: AuthMode;
  setAuthMode: Dispatch<SetStateAction<AuthMode>>;
  registerName: string;
  setRegisterName: Dispatch<SetStateAction<string>>;
  email: string;
  setEmail: Dispatch<SetStateAction<string>>;
  password: string;
  setPassword: Dispatch<SetStateAction<string>>;
  authError: string | null;
  busy: boolean;
  onLogin: (event: FormEvent<HTMLFormElement>) => Promise<void>;
  onRegister: (event: FormEvent<HTMLFormElement>) => Promise<void>;
  onForgotPassword: () => Promise<void>;
};

type AuthenticatedAreaProps = {
  tab: TabKey;
  setTab: Dispatch<SetStateAction<TabKey>>;
  user: User;
  busy: boolean;
  refreshToken: string | null;
  canCreateContent: boolean;
  canManageAdmin: boolean;
  formatDateTime: (value: string) => string;
  accessLevelLabel: (level: number) => string;
  news: NewsItem[];
  events: EventItem[];
  filteredNews: NewsItem[];
  filteredEvents: EventItem[];
  massSchedules: MassSchedule[];
  officeHours: OfficeHour[];
  nextMass: NextMassResponse | null;
  groups: GroupItem[];
  filteredGroups: GroupItem[];
  missas: EventItem[];
  onLogout: () => Promise<void>;
  newsTitle: string;
  setNewsTitle: Dispatch<SetStateAction<string>>;
  newsBody: string;
  setNewsBody: Dispatch<SetStateAction<string>>;
  eventName: string;
  setEventName: Dispatch<SetStateAction<string>>;
  eventLocal: string;
  setEventLocal: Dispatch<SetStateAction<string>>;
  eventType: 'MISSA' | 'REUNIAO' | 'FESTA';
  setEventType: Dispatch<SetStateAction<'MISSA' | 'REUNIAO' | 'FESTA'>>;
  eventDate: string;
  setEventDate: Dispatch<SetStateAction<string>>;
  onCreateNews: (event: FormEvent<HTMLFormElement>) => Promise<void>;
  onCreateEvent: (event: FormEvent<HTMLFormElement>) => Promise<void>;
  onUpdateNews: (id: number, payload: { titulo: string; conteudo: string }) => Promise<void>;
  onDeleteNews: (id: number) => Promise<void>;
  onUpdateEvent: (id: number, payload: { nome: string; local: string }) => Promise<void>;
  onDeleteEvent: (id: number) => Promise<void>;
  newsSearch: string;
  setNewsSearch: Dispatch<SetStateAction<string>>;
  eventsSearch: string;
  setEventsSearch: Dispatch<SetStateAction<string>>;
  groupsSearch: string;
  setGroupsSearch: Dispatch<SetStateAction<string>>;
  adminNotice: string | null;
  newUserName: string;
  setNewUserName: Dispatch<SetStateAction<string>>;
  newUserEmail: string;
  setNewUserEmail: Dispatch<SetStateAction<string>>;
  newUserPassword: string;
  setNewUserPassword: Dispatch<SetStateAction<string>>;
  newUserLevel: number;
  setNewUserLevel: Dispatch<SetStateAction<number>>;
  onCreateUserByAdmin: (event: FormEvent<HTMLFormElement>) => Promise<void>;
  usersLoading: boolean;
  usersManagement: User[];
  onRefreshUsers: () => void;
  onUpdateUserAccessLevel: (targetUserId: number, level: number) => Promise<void>;
  onDeleteUser: (targetUserId: number) => Promise<void>;
  massWeekday: number;
  setMassWeekday: Dispatch<SetStateAction<number>>;
  massTime: string;
  setMassTime: Dispatch<SetStateAction<string>>;
  massLocation: string;
  setMassLocation: Dispatch<SetStateAction<string>>;
  massNotes: string;
  setMassNotes: Dispatch<SetStateAction<string>>;
  onCreateMassSchedule: (event: FormEvent<HTMLFormElement>) => Promise<void>;
  onDeactivateMassSchedule: (id: number) => Promise<void>;
  officeWeekday: number;
  setOfficeWeekday: Dispatch<SetStateAction<number>>;
  officeOpenTime: string;
  setOfficeOpenTime: Dispatch<SetStateAction<string>>;
  officeCloseTime: string;
  setOfficeCloseTime: Dispatch<SetStateAction<string>>;
  officeLabel: string;
  setOfficeLabel: Dispatch<SetStateAction<string>>;
  officeNotes: string;
  setOfficeNotes: Dispatch<SetStateAction<string>>;
  onCreateOfficeHour: (event: FormEvent<HTMLFormElement>) => Promise<void>;
  onDeactivateOfficeHour: (id: number) => Promise<void>;
  weekdayOptions: Array<{ value: number; label: string }>;
};

export function HomeHeader({ user, accessLevelLabel }: HomeHeaderProps) {
  return (
    <header className="bg-vinho text-white">
      <div className="mx-auto flex w-full max-w-6xl items-center justify-between gap-4 px-4 py-4">
        <div className="flex items-center gap-3">
          <Image
            src="/img/IMAGEM DE SÃO PAULO APOSTOLO MONOCROMATICA.png"
            alt="Logo da Paroquia"
            width={42}
            height={42}
            className="h-10 w-10 object-contain"
          />
          <div className="leading-tight">
            <div className="text-lg font-bold" style={{ fontFamily: 'var(--font-playfair)' }}>
              Paroquia Sao Paulo Apostolo
            </div>
            <div className="text-sm opacity-90">Versao Web</div>
          </div>
        </div>
        <div className="text-right text-sm">
          <div>
            <div className="font-semibold">{user.nome}</div>
            <div className="opacity-80">{accessLevelLabel(user.nivelAcesso)}</div>
          </div>
        </div>
      </div>
    </header>
  );
}

export function AuthPanel({
  authMode,
  setAuthMode,
  registerName,
  setRegisterName,
  email,
  setEmail,
  password,
  setPassword,
  authError,
  busy,
  onLogin,
  onRegister,
  onForgotPassword,
}: AuthPanelProps) {
  return (
    <section className="mx-auto flex min-h-[80vh] w-full max-w-md items-center justify-center">
      <div className="w-full rounded-3xl border bg-white/95 p-7 shadow-sm">
        <div className="mx-auto mb-4 flex h-28 w-28 items-center justify-center overflow-hidden rounded-full bg-vinho">
          <Image
            src="/img/IMAGEM DE SÃO PAULO APOSTOLO MONOCROMATICA.png"
            alt="Logo da Paroquia"
            width={112}
            height={112}
            className="scale-105 object-cover"
          />
        </div>

        <h1
          className="text-center text-3xl font-bold leading-tight"
          style={{ fontFamily: 'var(--font-playfair)' }}
        >
          Paroquia Sao Paulo Apostolo
        </h1>
        <p className="mt-2 text-center text-sm text-zinc-600">
          {authMode === 'login'
            ? 'Acesse com sua conta para continuar.'
            : 'Crie sua conta para acessar o sistema.'}
        </p>

        <form className="mt-6 space-y-3" onSubmit={authMode === 'login' ? onLogin : onRegister}>
          {authMode === 'register' ? (
            <input
              className="w-full rounded-xl border border-zinc-300 px-3 py-3 outline-none ring-vinho focus:ring-2"
              placeholder="Nome completo"
              value={registerName}
              onChange={(event) => setRegisterName(event.target.value)}
              required
            />
          ) : null}
          <input
            className="w-full rounded-xl border border-zinc-300 px-3 py-3 outline-none ring-vinho focus:ring-2"
            placeholder="Email"
            type="email"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            required
          />
          <input
            className="w-full rounded-xl border border-zinc-300 px-3 py-3 outline-none ring-vinho focus:ring-2"
            placeholder="Senha"
            type="password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            required
          />
          {authError ? (
            <div className="rounded-xl border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">
              {authError}
            </div>
          ) : null}
          <button
            type="submit"
            disabled={busy}
            className="w-full rounded-xl bg-vinho px-4 py-3 font-semibold text-white disabled:opacity-60"
          >
            {busy ? 'Processando...' : authMode === 'login' ? 'Entrar' : 'Cadastrar'}
          </button>
        </form>

        <div className="mt-3 flex flex-wrap justify-center gap-2 text-sm">
          <button
            className="rounded-lg border px-3 py-1.5 hover:bg-zinc-50"
            onClick={() => setAuthMode(authMode === 'login' ? 'register' : 'login')}
          >
            {authMode === 'login' ? 'Criar conta' : 'Ja tenho conta'}
          </button>
          <button className="rounded-lg border px-3 py-1.5 hover:bg-zinc-50" onClick={() => void onForgotPassword()}>
            Esqueci minha senha
          </button>
          <button
            className="rounded-lg border px-3 py-1.5 hover:bg-zinc-50"
            onClick={() => window.open('https://paroquia.local/politica-de-privacidade', '_blank')}
          >
            Politica de Privacidade
          </button>
        </div>
      </div>
    </section>
  );
}

export function AuthenticatedArea({
  tab,
  setTab,
  user,
  busy,
  refreshToken,
  canCreateContent,
  canManageAdmin,
  formatDateTime,
  accessLevelLabel,
  news,
  events,
  filteredNews,
  filteredEvents,
  massSchedules,
  officeHours,
  nextMass,
  groups,
  filteredGroups,
  missas,
  onLogout,
  newsTitle,
  setNewsTitle,
  newsBody,
  setNewsBody,
  eventName,
  setEventName,
  eventLocal,
  setEventLocal,
  eventType,
  setEventType,
  eventDate,
  setEventDate,
  onCreateNews,
  onCreateEvent,
  onUpdateNews,
  onDeleteNews,
  onUpdateEvent,
  onDeleteEvent,
  newsSearch,
  setNewsSearch,
  eventsSearch,
  setEventsSearch,
  groupsSearch,
  setGroupsSearch,
  adminNotice,
  newUserName,
  setNewUserName,
  newUserEmail,
  setNewUserEmail,
  newUserPassword,
  setNewUserPassword,
  newUserLevel,
  setNewUserLevel,
  onCreateUserByAdmin,
  usersLoading,
  usersManagement,
  onRefreshUsers,
  onUpdateUserAccessLevel,
  onDeleteUser,
  massWeekday,
  setMassWeekday,
  massTime,
  setMassTime,
  massLocation,
  setMassLocation,
  massNotes,
  setMassNotes,
  onCreateMassSchedule,
  onDeactivateMassSchedule,
  officeWeekday,
  setOfficeWeekday,
  officeOpenTime,
  setOfficeOpenTime,
  officeCloseTime,
  setOfficeCloseTime,
  officeLabel,
  setOfficeLabel,
  officeNotes,
  setOfficeNotes,
  onCreateOfficeHour,
  onDeactivateOfficeHour,
  weekdayOptions,
}: AuthenticatedAreaProps) {
  const isSelfAccessTestUser = user.email === 'usuario.teste@paroquia.local';
  const [testAccessLevel, setTestAccessLevel] = useState(user.nivelAcesso);
  const [selectedNews, setSelectedNews] = useState<NewsItem | null>(null);
  const [selectedEvent, setSelectedEvent] = useState<EventItem | null>(null);

  useEffect(() => {
    setTestAccessLevel(user.nivelAcesso);
  }, [user.nivelAcesso]);

  return (
    <>
      <nav className="mb-6 flex flex-wrap gap-2">
        {[
          { key: 'home', label: 'Inicio' },
          ...(canCreateContent ? [{ key: 'conteudo', label: 'Conteudo' }] : []),
          { key: 'horarios', label: 'Horarios' },
          { key: 'grupos', label: 'Grupos' },
          { key: 'eventos', label: 'Eventos' },
          { key: 'perfil', label: 'Perfil' },
          ...(canManageAdmin ? [{ key: 'admin', label: 'Admin' }] : []),
        ].map((item) => (
          <button
            key={item.key}
            onClick={() => setTab(item.key as TabKey)}
            className={`rounded-full border px-4 py-2 text-sm font-semibold ${
              tab === item.key ? 'bg-vinho text-white' : 'bg-white text-zinc-700'
            }`}
          >
            {item.label}
          </button>
        ))}
      </nav>

      {canCreateContent && tab === 'conteudo' ? (
        <section className="mb-6 grid gap-4 md:grid-cols-2">
          <form onSubmit={onCreateNews} className="rounded-2xl border bg-white p-4 shadow-sm">
            <h2 className="text-lg font-bold">Nova noticia</h2>
            <input
              className="mt-3 w-full rounded-lg border border-zinc-300 px-3 py-2"
              placeholder="Titulo"
              value={newsTitle}
              onChange={(event) => setNewsTitle(event.target.value)}
              required
            />
            <textarea
              className="mt-2 min-h-24 w-full rounded-lg border border-zinc-300 px-3 py-2"
              placeholder="Conteudo"
              value={newsBody}
              onChange={(event) => setNewsBody(event.target.value)}
              required
            />
            <button
              disabled={busy}
              className="mt-2 rounded-lg bg-vinho px-4 py-2 text-sm font-medium text-white disabled:opacity-60"
              type="submit"
            >
              Publicar noticia
            </button>
          </form>

          <form onSubmit={onCreateEvent} className="rounded-2xl border bg-white p-4 shadow-sm">
            <h2 className="text-lg font-bold">Novo evento</h2>
            <input
              className="mt-3 w-full rounded-lg border border-zinc-300 px-3 py-2"
              placeholder="Nome"
              value={eventName}
              onChange={(event) => setEventName(event.target.value)}
              required
            />
            <input
              className="mt-2 w-full rounded-lg border border-zinc-300 px-3 py-2"
              placeholder="Local"
              value={eventLocal}
              onChange={(event) => setEventLocal(event.target.value)}
              required
            />
            <div className="mt-2 grid gap-2 md:grid-cols-2">
              <select
                className="w-full rounded-lg border border-zinc-300 px-3 py-2"
                value={eventType}
                onChange={(event) => setEventType(event.target.value as 'MISSA' | 'REUNIAO' | 'FESTA')}
              >
                <option value="MISSA">Missa</option>
                <option value="REUNIAO">Reuniao</option>
                <option value="FESTA">Festa</option>
              </select>
              <input
                className="w-full rounded-lg border border-zinc-300 px-3 py-2"
                type="datetime-local"
                value={eventDate}
                onChange={(event) => setEventDate(event.target.value)}
              />
            </div>
            <button
              disabled={busy}
              className="mt-2 rounded-lg bg-vinho px-4 py-2 text-sm font-medium text-white disabled:opacity-60"
              type="submit"
            >
              Publicar evento
            </button>
          </form>
        </section>
      ) : null}

      {tab === 'home' ? (
        <section className="grid gap-4 md:grid-cols-2">
          <article className="rounded-2xl border bg-white p-5 shadow-sm md:col-span-2">
            <h1 className="text-2xl font-bold">Vida Paroquial</h1>
            <p className="mt-2 text-zinc-700">Agenda, comunicados e contagem para a proxima missa.</p>
          </article>
          <article className="rounded-2xl border bg-vinho p-5 text-white shadow-sm">
            <h2 className="text-lg font-semibold">Proxima missa</h2>
            {nextMass?.nextMass ? (
              <>
                <p className="mt-3 text-xl font-bold">{formatDateTime(nextMass.nextMass.startsAt)}</p>
                <p className="mt-1 text-sm">{nextMass.nextMass.locationName}</p>
                <p className="mt-1 text-xs opacity-85">Horario de referencia: Brasilia</p>
              </>
            ) : (
              <p className="mt-3 text-sm">Nenhuma missa futura cadastrada.</p>
            )}
          </article>
          <article className="rounded-2xl border bg-white p-5 shadow-sm">
            <h2 className="text-lg font-semibold">Ultimas noticias</h2>
            <input
              className="mt-3 w-full rounded-lg border border-zinc-300 px-3 py-2 text-sm"
              placeholder="Buscar noticias..."
              value={newsSearch}
              onChange={(event) => setNewsSearch(event.target.value)}
            />
            <div className="mt-3 space-y-3">
              {filteredNews.map((item) => (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => setSelectedNews(item)}
                  className="w-full rounded-lg border p-3 text-left hover:bg-zinc-50"
                >
                  <p className="font-semibold">{item.titulo}</p>
                  <p className="mt-1 text-sm text-zinc-600">{item.conteudo}</p>
                  <p className="mt-1 text-xs text-zinc-500">
                    {new Date(item.dataPublicacao).toLocaleString('pt-BR')} | {item.autorNome ?? 'Autor nao informado'}
                  </p>
                </button>
              ))}
            </div>
          </article>
        </section>
      ) : null}

      {tab === 'horarios' ? (
        <section className="grid gap-4 md:grid-cols-2">
          <article className="rounded-2xl border bg-white p-5 shadow-sm">
            <h2 className="text-lg font-semibold">Horarios de missa</h2>
            <div className="mt-3 space-y-2">
              {massSchedules.map((item) => (
                <div key={item.id} className="rounded-lg border p-3 text-sm">
                  <p className="font-semibold">
                    {item.weekdayLabel} - {item.time}
                  </p>
                  <p className="text-zinc-600">{item.locationName}</p>
                  {item.notes ? <p className="text-zinc-500">{item.notes}</p> : null}
                </div>
              ))}
            </div>
          </article>
          <article className="rounded-2xl border bg-white p-5 shadow-sm">
            <h2 className="text-lg font-semibold">Horarios da secretaria</h2>
            <div className="mt-3 space-y-2">
              {officeHours.map((item) => (
                <div key={item.id} className="rounded-lg border p-3 text-sm">
                  <p className="font-semibold">
                    {item.weekdayLabel} - {item.openTime}
                    {item.closeTime ? ` ate ${item.closeTime}` : ''}
                  </p>
                  <p className="text-zinc-600">{item.label ?? 'Secretaria'}</p>
                </div>
              ))}
            </div>
          </article>
        </section>
      ) : null}

      {tab === 'grupos' ? (
        <section className="rounded-2xl border bg-white p-5 shadow-sm">
          <h2 className="text-lg font-semibold">Grupos</h2>
          <input
            className="mt-3 w-full rounded-lg border border-zinc-300 px-3 py-2 text-sm"
            placeholder="Buscar grupos..."
            value={groupsSearch}
            onChange={(event) => setGroupsSearch(event.target.value)}
          />
          <div className="mt-3 space-y-2">
            {filteredGroups.map((item) => (
              <article key={item.id} className="rounded-lg border p-3">
                <p className="font-semibold">{item.nome}</p>
                <p className="text-sm text-zinc-600">{item.descricao}</p>
                <div className="mt-2 flex flex-wrap gap-2 text-xs">
                  {item.permiteNoticias ? <span className="rounded bg-zinc-100 px-2 py-1">Noticias</span> : null}
                  {item.permiteEventos ? <span className="rounded bg-zinc-100 px-2 py-1">Eventos</span> : null}
                  {item.permiteFormularios ? <span className="rounded bg-zinc-100 px-2 py-1">Formularios</span> : null}
                  {item.permitePdfUpload ? <span className="rounded bg-zinc-100 px-2 py-1">Escalas PDF</span> : null}
                </div>
              </article>
            ))}
            {groups.length > 0 && filteredGroups.length === 0 ? (
              <p className="text-sm text-zinc-600">Nenhum grupo encontrado para a busca.</p>
            ) : null}
            {groups.length === 0 ? (
              <p className="text-sm text-zinc-600">Nenhum grupo cadastrado no momento.</p>
            ) : null}
          </div>
        </section>
      ) : null}

      {tab === 'eventos' ? (
        <section className="rounded-2xl border bg-white p-5 shadow-sm">
          <h2 className="text-lg font-semibold">Eventos e missas</h2>
          <input
            className="mt-3 w-full rounded-lg border border-zinc-300 px-3 py-2 text-sm"
            placeholder="Buscar eventos..."
            value={eventsSearch}
            onChange={(event) => setEventsSearch(event.target.value)}
          />
          <div className="mt-3 grid gap-3 md:grid-cols-2">
            {filteredEvents.map((item) => (
              <article key={item.id} className="rounded-lg border p-3">
                <button
                  type="button"
                  className="w-full text-left"
                  onClick={() => setSelectedEvent(item)}
                >
                  <p className="font-semibold">{item.nome}</p>
                </button>
                <p className="text-sm text-zinc-600">{item.local}</p>
                <p className="text-sm text-zinc-600">{formatDateTime(item.dataHora)}</p>
                <p className="mt-1 text-xs text-vinho">{item.tipo}</p>
                {canCreateContent ? (
                  <div className="mt-2 flex gap-2">
                    <button
                      type="button"
                      className="rounded border px-2 py-1 text-xs hover:bg-zinc-50"
                      onClick={() => {
                        const nome = window.prompt('Novo nome do evento:', item.nome);
                        if (nome == null || !nome.trim()) return;
                        const local = window.prompt('Novo local do evento:', item.local);
                        if (local == null || !local.trim()) return;
                        void onUpdateEvent(item.id, { nome, local });
                      }}
                    >
                      Editar
                    </button>
                    <button
                      type="button"
                      className="rounded border border-red-300 bg-red-50 px-2 py-1 text-xs text-red-700"
                      onClick={() => {
                        if (!window.confirm('Excluir este evento?')) return;
                        void onDeleteEvent(item.id);
                      }}
                    >
                      Excluir
                    </button>
                  </div>
                ) : null}
              </article>
            ))}
          </div>
          {missas.length === 0 ? (
            <p className="mt-3 text-sm text-zinc-600">Nenhuma missa cadastrada no momento.</p>
          ) : null}
        </section>
      ) : null}

      {tab === 'perfil' ? (
        <section className="rounded-2xl border bg-white p-5 shadow-sm">
          <h2 className="text-lg font-semibold">Perfil</h2>
          <div className="mt-3 space-y-2 text-sm">
            <p>
              <span className="font-semibold">Nome:</span> {user.nome}
            </p>
            <p>
              <span className="font-semibold">Email:</span> {user.email}
            </p>
            <p>
              <span className="font-semibold">Nivel de acesso:</span> {accessLevelLabel(user.nivelAcesso)}
            </p>
            <p>
              <span className="font-semibold">Refresh token:</span>{' '}
              {refreshToken ? 'Sessao ativa no navegador' : 'Nao disponivel'}
            </p>
          </div>
          {isSelfAccessTestUser ? (
            <div className="mt-4 rounded-xl border border-amber-200 bg-amber-50 p-3">
              <p className="text-sm font-semibold text-amber-900">Menu de teste: alterar meu nivel</p>
              <div className="mt-2 flex flex-wrap items-center gap-2">
                <select
                  className="rounded border px-2 py-1 text-sm"
                  value={testAccessLevel}
                  onChange={(event) => setTestAccessLevel(Number(event.target.value))}
                  disabled={busy}
                >
                  <option value={0}>Usuario padrao</option>
                  <option value={1}>Membro pastoral</option>
                  <option value={2}>Coordenador</option>
                  <option value={3}>Administrativo</option>
                </select>
                <button
                  className="rounded bg-vinho px-3 py-1 text-sm font-semibold text-white disabled:opacity-60"
                  onClick={() => void onUpdateUserAccessLevel(user.id, testAccessLevel)}
                  disabled={busy || testAccessLevel === user.nivelAcesso}
                >
                  Salvar nivel
                </button>
              </div>
            </div>
          ) : null}
          <button
            className="mt-4 rounded-lg border border-red-300 bg-red-50 px-4 py-2 text-sm font-semibold text-red-700"
            onClick={() => void onLogout()}
          >
            Sair
          </button>
        </section>
      ) : null}

      {tab === 'admin' ? (
        <section className="space-y-4">
          {!canManageAdmin ? (
            <article className="rounded-2xl border bg-white p-5 shadow-sm">
              <p className="text-sm text-zinc-700">Sem permissao para acessar o modulo administrativo.</p>
            </article>
          ) : (
            <>
              {adminNotice ? (
                <div className="rounded-lg border border-blue-200 bg-blue-50 px-3 py-2 text-sm text-blue-800">
                  {adminNotice}
                </div>
              ) : null}

              <article className="rounded-2xl border bg-white p-5 shadow-sm">
                <h2 className="text-lg font-semibold">Criar usuario</h2>
                <form className="mt-3 grid gap-2 md:grid-cols-4" onSubmit={onCreateUserByAdmin}>
                  <input
                    className="rounded-lg border border-zinc-300 px-3 py-2"
                    placeholder="Nome"
                    value={newUserName}
                    onChange={(event) => setNewUserName(event.target.value)}
                    required
                  />
                  <input
                    className="rounded-lg border border-zinc-300 px-3 py-2"
                    type="email"
                    placeholder="Email"
                    value={newUserEmail}
                    onChange={(event) => setNewUserEmail(event.target.value)}
                    required
                  />
                  <input
                    className="rounded-lg border border-zinc-300 px-3 py-2"
                    type="password"
                    placeholder="Senha (min. 8)"
                    value={newUserPassword}
                    onChange={(event) => setNewUserPassword(event.target.value)}
                    required
                  />
                  <div className="flex gap-2">
                    <select
                      className="w-full rounded-lg border border-zinc-300 px-3 py-2"
                      value={newUserLevel}
                      onChange={(event) => setNewUserLevel(Number(event.target.value))}
                    >
                      <option value={0}>Usuario padrao</option>
                      <option value={1}>Membro pastoral</option>
                      <option value={2}>Coordenador</option>
                      <option value={3}>Administrativo</option>
                    </select>
                    <button
                      disabled={busy}
                      className="rounded-lg bg-vinho px-4 py-2 text-sm font-medium text-white disabled:opacity-60"
                      type="submit"
                    >
                      Criar
                    </button>
                  </div>
                </form>
              </article>

              <article className="rounded-2xl border bg-white p-5 shadow-sm">
                <div className="mb-3 flex items-center justify-between">
                  <h2 className="text-lg font-semibold">Gerenciar usuarios</h2>
                  <button className="rounded border px-3 py-1 text-sm hover:bg-zinc-50" onClick={onRefreshUsers}>
                    Atualizar lista
                  </button>
                </div>
                {usersLoading ? (
                  <p className="text-sm text-zinc-600">Carregando usuarios...</p>
                ) : (
                  <div className="space-y-2">
                    {usersManagement.map((item) => (
                      <div
                        key={item.id}
                        className="grid gap-2 rounded-lg border p-3 text-sm md:grid-cols-[1fr_auto_auto]"
                      >
                        <div>
                          <p className="font-semibold">{item.nome}</p>
                          <p className="text-zinc-600">{item.email}</p>
                        </div>
                        <select
                          className="rounded border px-2 py-1"
                          value={item.nivelAcesso}
                          onChange={(event) => void onUpdateUserAccessLevel(item.id, Number(event.target.value))}
                          disabled={busy}
                        >
                          <option value={0}>Usuario</option>
                          <option value={1}>Membro</option>
                          <option value={2}>Coordenador</option>
                          <option value={3}>Admin</option>
                        </select>
                        <button
                          className="rounded border border-red-300 bg-red-50 px-3 py-1 text-red-700"
                          onClick={() => void onDeleteUser(item.id)}
                          disabled={busy || item.id === user.id}
                        >
                          Excluir
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </article>

              <section className="grid gap-4 md:grid-cols-2">
                <article className="rounded-2xl border bg-white p-5 shadow-sm">
                  <h2 className="text-lg font-semibold">Novo horario de missa</h2>
                  <form className="mt-3 space-y-2" onSubmit={onCreateMassSchedule}>
                    <select
                      className="w-full rounded border px-3 py-2"
                      value={massWeekday}
                      onChange={(event) => setMassWeekday(Number(event.target.value))}
                    >
                      {weekdayOptions.map((weekday) => (
                        <option key={weekday.value} value={weekday.value}>
                          {weekday.label}
                        </option>
                      ))}
                    </select>
                    <input
                      className="w-full rounded border px-3 py-2"
                      type="time"
                      value={massTime}
                      onChange={(event) => setMassTime(event.target.value)}
                      required
                    />
                    <input
                      className="w-full rounded border px-3 py-2"
                      placeholder="Local"
                      value={massLocation}
                      onChange={(event) => setMassLocation(event.target.value)}
                      required
                    />
                    <textarea
                      className="min-h-20 w-full rounded border px-3 py-2"
                      placeholder="Observacoes (opcional)"
                      value={massNotes}
                      onChange={(event) => setMassNotes(event.target.value)}
                    />
                    <button
                      disabled={busy}
                      className="rounded-lg bg-vinho px-4 py-2 text-sm font-medium text-white disabled:opacity-60"
                      type="submit"
                    >
                      Criar horario de missa
                    </button>
                  </form>
                  <div className="mt-3 space-y-2">
                    {massSchedules.map((item) => (
                      <div key={item.id} className="flex items-center justify-between rounded border p-2 text-sm">
                        <span>
                          {item.weekdayLabel} - {item.time} ({item.locationName})
                        </span>
                        <button
                          className="rounded border border-red-300 bg-red-50 px-2 py-1 text-red-700"
                          onClick={() => void onDeactivateMassSchedule(item.id)}
                          disabled={busy}
                        >
                          Desativar
                        </button>
                      </div>
                    ))}
                  </div>
                </article>

                <article className="rounded-2xl border bg-white p-5 shadow-sm">
                  <h2 className="text-lg font-semibold">Novo horario da secretaria</h2>
                  <form className="mt-3 space-y-2" onSubmit={onCreateOfficeHour}>
                    <select
                      className="w-full rounded border px-3 py-2"
                      value={officeWeekday}
                      onChange={(event) => setOfficeWeekday(Number(event.target.value))}
                    >
                      {weekdayOptions.map((weekday) => (
                        <option key={weekday.value} value={weekday.value}>
                          {weekday.label}
                        </option>
                      ))}
                    </select>
                    <div className="grid grid-cols-2 gap-2">
                      <input
                        className="w-full rounded border px-3 py-2"
                        type="time"
                        value={officeOpenTime}
                        onChange={(event) => setOfficeOpenTime(event.target.value)}
                        required
                      />
                      <input
                        className="w-full rounded border px-3 py-2"
                        type="time"
                        value={officeCloseTime}
                        onChange={(event) => setOfficeCloseTime(event.target.value)}
                      />
                    </div>
                    <input
                      className="w-full rounded border px-3 py-2"
                      placeholder="Label"
                      value={officeLabel}
                      onChange={(event) => setOfficeLabel(event.target.value)}
                    />
                    <textarea
                      className="min-h-20 w-full rounded border px-3 py-2"
                      placeholder="Observacoes (opcional)"
                      value={officeNotes}
                      onChange={(event) => setOfficeNotes(event.target.value)}
                    />
                    <button
                      disabled={busy}
                      className="rounded-lg bg-vinho px-4 py-2 text-sm font-medium text-white disabled:opacity-60"
                      type="submit"
                    >
                      Criar horario da secretaria
                    </button>
                  </form>
                  <div className="mt-3 space-y-2">
                    {officeHours.map((item) => (
                      <div key={item.id} className="flex items-center justify-between rounded border p-2 text-sm">
                        <span>
                          {item.weekdayLabel} - {item.openTime}
                          {item.closeTime ? ` ate ${item.closeTime}` : ''}
                        </span>
                        <button
                          className="rounded border border-red-300 bg-red-50 px-2 py-1 text-red-700"
                          onClick={() => void onDeactivateOfficeHour(item.id)}
                          disabled={busy}
                        >
                          Desativar
                        </button>
                      </div>
                    ))}
                  </div>
                </article>
              </section>
            </>
          )}
        </section>
      ) : null}

      {selectedNews ? (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="max-h-[90vh] w-full max-w-2xl overflow-auto rounded-2xl bg-white p-5">
            <h3 className="text-xl font-bold">{selectedNews.titulo}</h3>
            <p className="mt-1 text-xs text-zinc-500">
              {new Date(selectedNews.dataPublicacao).toLocaleString('pt-BR')} |{' '}
              {selectedNews.autorNome ?? 'Autor nao informado'}
            </p>
            <p className="mt-4 whitespace-pre-wrap text-sm text-zinc-700">{selectedNews.conteudo}</p>
            <div className="mt-4 flex gap-2">
              {canCreateContent ? (
                <>
                  <button
                    type="button"
                    className="rounded border px-3 py-1 text-sm hover:bg-zinc-50"
                    onClick={() => {
                      const titulo = window.prompt('Novo titulo da noticia:', selectedNews.titulo);
                      if (titulo == null || !titulo.trim()) return;
                      const conteudo = window.prompt('Novo conteudo da noticia:', selectedNews.conteudo);
                      if (conteudo == null || !conteudo.trim()) return;
                      void onUpdateNews(selectedNews.id, { titulo, conteudo });
                    }}
                  >
                    Editar
                  </button>
                  <button
                    type="button"
                    className="rounded border border-red-300 bg-red-50 px-3 py-1 text-sm text-red-700"
                    onClick={() => {
                      if (!window.confirm('Excluir esta noticia?')) return;
                      void onDeleteNews(selectedNews.id);
                      setSelectedNews(null);
                    }}
                  >
                    Excluir
                  </button>
                </>
              ) : null}
              <button
                type="button"
                className="rounded bg-zinc-800 px-3 py-1 text-sm text-white"
                onClick={() => setSelectedNews(null)}
              >
                Fechar
              </button>
            </div>
          </div>
        </div>
      ) : null}

      {selectedEvent ? (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="max-h-[90vh] w-full max-w-2xl overflow-auto rounded-2xl bg-white p-5">
            <h3 className="text-xl font-bold">{selectedEvent.nome}</h3>
            <p className="mt-1 text-xs text-zinc-500">
              {formatDateTime(selectedEvent.dataHora)} | {selectedEvent.autorNome ?? 'Autor nao informado'}
            </p>
            <p className="mt-1 text-xs text-vinho">{selectedEvent.tipo}</p>
            <p className="mt-1 text-sm text-zinc-600">{selectedEvent.local}</p>
            {selectedEvent.descricao ? (
              <p className="mt-4 whitespace-pre-wrap text-sm text-zinc-700">{selectedEvent.descricao}</p>
            ) : null}
            <div className="mt-4 flex gap-2">
              {canCreateContent ? (
                <>
                  <button
                    type="button"
                    className="rounded border px-3 py-1 text-sm hover:bg-zinc-50"
                    onClick={() => {
                      const nome = window.prompt('Novo nome do evento:', selectedEvent.nome);
                      if (nome == null || !nome.trim()) return;
                      const local = window.prompt('Novo local do evento:', selectedEvent.local);
                      if (local == null || !local.trim()) return;
                      void onUpdateEvent(selectedEvent.id, { nome, local });
                    }}
                  >
                    Editar
                  </button>
                  <button
                    type="button"
                    className="rounded border border-red-300 bg-red-50 px-3 py-1 text-sm text-red-700"
                    onClick={() => {
                      if (!window.confirm('Excluir este evento?')) return;
                      void onDeleteEvent(selectedEvent.id);
                      setSelectedEvent(null);
                    }}
                  >
                    Excluir
                  </button>
                </>
              ) : null}
              <button
                type="button"
                className="rounded bg-zinc-800 px-3 py-1 text-sm text-white"
                onClick={() => setSelectedEvent(null)}
              >
                Fechar
              </button>
            </div>
          </div>
        </div>
      ) : null}
    </>
  );
}
