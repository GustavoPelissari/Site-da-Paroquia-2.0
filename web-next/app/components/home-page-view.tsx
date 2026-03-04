'use client';

import { Dispatch, FormEvent, SetStateAction } from 'react';
import {
  EventItem,
  GroupItem,
  MassSchedule,
  MediaFolder,
  MediaItem,
  NewsItem,
  NextMassResponse,
  OfficeHour,
  TabKey,
  User,
} from './home-page.types';

type AuthMode = 'login' | 'register';

type HomeHeaderProps = { user: User; accessLevelLabel: (level: number) => string };
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
  newsSubtitle: string;
  setNewsSubtitle: Dispatch<SetStateAction<string>>;
  newsBody: string;
  setNewsBody: Dispatch<SetStateAction<string>>;
  newsCategory: string;
  setNewsCategory: Dispatch<SetStateAction<string>>;
  newsImageUrl: string;
  setNewsImageUrl: Dispatch<SetStateAction<string>>;
  newsExternalLink: string;
  setNewsExternalLink: Dispatch<SetStateAction<string>>;
  newsHighlight: boolean;
  setNewsHighlight: Dispatch<SetStateAction<boolean>>;
  newsParishNotice: boolean;
  setNewsParishNotice: Dispatch<SetStateAction<boolean>>;
  eventName: string;
  setEventName: Dispatch<SetStateAction<string>>;
  eventLocal: string;
  setEventLocal: Dispatch<SetStateAction<string>>;
  eventType: 'MISSA' | 'REUNIAO' | 'FESTA' | 'RETIRO';
  setEventType: Dispatch<SetStateAction<'MISSA' | 'REUNIAO' | 'FESTA' | 'RETIRO'>>;
  eventDate: string;
  setEventDate: Dispatch<SetStateAction<string>>;
  eventDateEnd: string;
  setEventDateEnd: Dispatch<SetStateAction<string>>;
  eventDescription: string;
  setEventDescription: Dispatch<SetStateAction<string>>;
  eventImageUrl: string;
  setEventImageUrl: Dispatch<SetStateAction<string>>;
  eventSignupLink: string;
  setEventSignupLink: Dispatch<SetStateAction<string>>;
  eventCapacity: string;
  setEventCapacity: Dispatch<SetStateAction<string>>;
  onCreateNews: (event: FormEvent<HTMLFormElement>) => Promise<void>;
  onCreateEvent: (event: FormEvent<HTMLFormElement>) => Promise<void>;
  onUpdateNews: (id: number, payload: Partial<NewsItem>) => Promise<void>;
  onDeleteNews: (id: number) => Promise<void>;
  onUpdateEvent: (id: number, payload: Partial<EventItem>) => Promise<void>;
  onDeleteEvent: (id: number) => Promise<void>;
  onDuplicateEvent: (id: number) => Promise<void>;
  newsSearch: string;
  setNewsSearch: Dispatch<SetStateAction<string>>;
  eventsSearch: string;
  setEventsSearch: Dispatch<SetStateAction<string>>;
  groupsSearch: string;
  setGroupsSearch: Dispatch<SetStateAction<string>>;
  globalSearch: string;
  setGlobalSearch: Dispatch<SetStateAction<string>>;
  globalResults: Array<{ type: string; id: number; title: string; subtitle: string }>;
  categories: string[];
  newsCategoryFilter: string;
  setNewsCategoryFilter: Dispatch<SetStateAction<string>>;
  eventTypeFilter: 'ALL' | 'MISSA' | 'REUNIAO' | 'FESTA' | 'RETIRO';
  setEventTypeFilter: Dispatch<SetStateAction<'ALL' | 'MISSA' | 'REUNIAO' | 'FESTA' | 'RETIRO'>>;
  parishNotice: NewsItem | null;
  mediaFolder: MediaFolder;
  setMediaFolder: Dispatch<SetStateAction<MediaFolder>>;
  mediaItems: MediaItem[];
  mediaFile: File | null;
  setMediaFile: Dispatch<SetStateAction<File | null>>;
  onUploadMedia: () => Promise<void>;
  onLoadMediaGallery: () => Promise<void>;
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

const short = (text: string, max = 140) => (text.length <= max ? text : `${text.slice(0, max).trim()}...`);
const plain = (text: string) => text.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();

function NewsCard({ item }: { item: NewsItem }) {
  return (
    <article className="overflow-hidden rounded-2xl border bg-white shadow-sm">
      <div className="h-44 bg-zinc-100">
        <img
          src={item.imagemUrl || '/img/IMAGEM DA PAROQUIA.jpeg'}
          alt={item.titulo}
          className="h-full w-full object-cover"
          loading="lazy"
        />
      </div>
      <div className="space-y-2 p-4">
        <p className="text-xs font-semibold uppercase text-vinho">{item.categoria || 'Noticia'}</p>
        <h3 className="text-lg font-semibold">{item.titulo}</h3>
        <p className="text-sm text-zinc-600">{short(plain(item.subtitulo || item.conteudo))}</p>
        <p className="text-xs text-zinc-500">{new Date(item.dataPublicacao).toLocaleDateString('pt-BR')}</p>
        <button className="rounded-lg border px-3 py-1.5 text-sm">Ler mais</button>
      </div>
    </article>
  );
}

export function HomeHeader({ user, accessLevelLabel }: HomeHeaderProps) {
  return (
    <header className="bg-vinho text-white">
      <div className="mx-auto flex w-full max-w-6xl items-center justify-between px-4 py-4">
        <div>
          <p className="text-lg font-bold">Paroquia Sao Paulo Apostolo</p>
          <p className="text-xs opacity-85">Painel Web</p>
        </div>
        <div className="text-right text-sm">
          <p className="font-semibold">{user.nome}</p>
          <p className="opacity-80">{accessLevelLabel(user.nivelAcesso)}</p>
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
        <h1 className="text-center text-3xl font-bold">Plataforma Paroquial</h1>
        <form className="mt-6 space-y-3" onSubmit={authMode === 'login' ? onLogin : onRegister}>
          {authMode === 'register' ? <input className="w-full rounded-xl border px-3 py-3" placeholder="Nome" value={registerName} onChange={(e) => setRegisterName(e.target.value)} required /> : null}
          <input className="w-full rounded-xl border px-3 py-3" placeholder="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
          <input className="w-full rounded-xl border px-3 py-3" placeholder="Senha" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
          {authError ? <div className="rounded-xl border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">{authError}</div> : null}
          <button type="submit" disabled={busy} className="w-full rounded-xl bg-vinho px-4 py-3 font-semibold text-white">
            {busy ? 'Processando...' : authMode === 'login' ? 'Entrar' : 'Cadastrar'}
          </button>
        </form>
        <div className="mt-3 flex justify-center gap-2 text-sm">
          <button className="rounded-lg border px-3 py-1.5" onClick={() => setAuthMode(authMode === 'login' ? 'register' : 'login')}>
            {authMode === 'login' ? 'Criar conta' : 'Ja tenho conta'}
          </button>
          <button className="rounded-lg border px-3 py-1.5" onClick={() => void onForgotPassword()}>
            Esqueci senha
          </button>
        </div>
      </div>
    </section>
  );
}

export function AuthenticatedArea(props: AuthenticatedAreaProps) {
  const menu: Array<{ title: string; items: Array<{ key: TabKey; label: string }> }> = [
    { title: 'Dashboard', items: [{ key: 'dashboard', label: 'Dashboard' }] },
    { title: 'Conteudo', items: [{ key: 'noticias', label: 'Noticias' }, { key: 'eventos', label: 'Eventos' }, { key: 'avisos', label: 'Avisos' }] },
    { title: 'Comunidade', items: [{ key: 'grupos', label: 'Grupos' }, { key: 'pastorais', label: 'Pastorais' }] },
    { title: 'Paroquia', items: [{ key: 'horarios', label: 'Horarios' }, { key: 'localizacao', label: 'Localizacao' }, { key: 'calendario', label: 'Calendario' }] },
    { title: 'Sistema', items: [{ key: 'midia', label: 'Midia' }, { key: 'usuarios', label: 'Usuarios' }, { key: 'perfil', label: 'Perfil' }] },
  ];

  return (
    <div className="space-y-5">
      <div className="rounded-2xl border bg-white p-4 shadow-sm">
        <input
          className="w-full rounded-lg border px-3 py-2 text-sm"
          placeholder="Busca global..."
          value={props.globalSearch}
          onChange={(e) => props.setGlobalSearch(e.target.value)}
        />
        {props.globalResults.length > 0 ? (
          <div className="mt-2 grid gap-2 md:grid-cols-2">
            {props.globalResults.map((item) => (
              <div key={`${item.type}-${item.id}`} className="rounded border px-3 py-2 text-xs">
                <p className="font-semibold">{item.title}</p>
                <p className="text-zinc-500">
                  {item.type} - {item.subtitle}
                </p>
              </div>
            ))}
          </div>
        ) : null}
      </div>

      <nav className="grid gap-3 md:grid-cols-5">
        {menu.map((group) => (
          <div key={group.title} className="rounded-xl border bg-white p-3 shadow-sm">
            <p className="mb-2 text-xs font-bold uppercase text-zinc-500">{group.title}</p>
            <div className="space-y-1">
              {group.items.map((item) => (
                <button
                  key={item.key}
                  type="button"
                  onClick={() => props.setTab(item.key)}
                  className={`block w-full rounded px-2 py-1 text-left text-sm ${
                    props.tab === item.key ? 'bg-vinho text-white' : 'hover:bg-zinc-50'
                  }`}
                >
                  {item.label}
                </button>
              ))}
            </div>
          </div>
        ))}
      </nav>

      {props.tab === 'dashboard' ? (
        <section className="space-y-4">
          {props.parishNotice ? (
            <article className="rounded-2xl border border-amber-200 bg-amber-50 p-4">
              <p className="text-xs font-bold uppercase text-amber-700">Aviso Paroquial</p>
              <h3 className="text-lg font-bold text-amber-900">{props.parishNotice.titulo}</h3>
              <p className="text-sm text-amber-800">{short(plain(props.parishNotice.conteudo), 200)}</p>
            </article>
          ) : null}
          <article className="rounded-2xl border bg-vinho p-5 text-white shadow-sm">
            <h2 className="text-lg font-semibold">Proxima missa</h2>
            <p className="mt-2 text-sm">
              {props.nextMass?.nextMass
                ? `${props.formatDateTime(props.nextMass.nextMass.startsAt)} - ${props.nextMass.nextMass.locationName}`
                : 'Nenhuma missa futura cadastrada.'}
            </p>
          </article>
          <div className="grid gap-4 lg:grid-cols-3">
            {props.news.slice(0, 3).map((item) => (
              <NewsCard key={item.id} item={item} />
            ))}
          </div>
        </section>
      ) : null}

      {props.tab === 'noticias' ? (
        <section className="space-y-4">
          {props.canCreateContent ? (
            <form onSubmit={props.onCreateNews} className="rounded-2xl border bg-white p-4 shadow-sm">
              <h2 className="text-lg font-bold">Nova noticia</h2>
              <div className="mt-2 grid gap-2 md:grid-cols-2">
                <input className="rounded border px-3 py-2" placeholder="Titulo" value={props.newsTitle} onChange={(e) => props.setNewsTitle(e.target.value)} required />
                <input className="rounded border px-3 py-2" placeholder="Subtitulo" value={props.newsSubtitle} onChange={(e) => props.setNewsSubtitle(e.target.value)} />
                <input className="rounded border px-3 py-2" placeholder="Categoria" value={props.newsCategory} onChange={(e) => props.setNewsCategory(e.target.value)} />
                <input className="rounded border px-3 py-2" placeholder="Imagem URL" value={props.newsImageUrl} onChange={(e) => props.setNewsImageUrl(e.target.value)} />
                <input className="md:col-span-2 rounded border px-3 py-2" placeholder="Link externo" value={props.newsExternalLink} onChange={(e) => props.setNewsExternalLink(e.target.value)} />
              </div>
              <textarea className="mt-2 min-h-32 w-full rounded border px-3 py-2" placeholder="Conteudo (aceita HTML)" value={props.newsBody} onChange={(e) => props.setNewsBody(e.target.value)} required />
              <div className="mt-2 flex gap-4 text-sm">
                <label className="inline-flex items-center gap-2">
                  <input type="checkbox" checked={props.newsHighlight} onChange={(e) => props.setNewsHighlight(e.target.checked)} />
                  Destaque
                </label>
                <label className="inline-flex items-center gap-2">
                  <input type="checkbox" checked={props.newsParishNotice} onChange={(e) => props.setNewsParishNotice(e.target.checked)} />
                  Aviso Paroquial
                </label>
              </div>
              <button className="mt-3 rounded bg-vinho px-4 py-2 text-sm font-semibold text-white">Publicar noticia</button>
            </form>
          ) : null}
          <div className="grid gap-2 md:grid-cols-3">
            <input className="rounded border px-3 py-2 text-sm" placeholder="Buscar noticias..." value={props.newsSearch} onChange={(e) => props.setNewsSearch(e.target.value)} />
            <select className="rounded border px-3 py-2 text-sm" value={props.newsCategoryFilter} onChange={(e) => props.setNewsCategoryFilter(e.target.value)}>
              <option value="">Todas categorias</option>
              {props.categories.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
          </div>
          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
            {props.filteredNews.map((item) => (
              <div key={item.id} className="space-y-2">
                <NewsCard item={item} />
                {props.canCreateContent ? (
                  <div className="flex gap-2">
                    <button
                      type="button"
                      className="rounded border px-3 py-1 text-sm"
                      onClick={() => {
                        const titulo = window.prompt('Novo titulo:', item.titulo);
                        if (!titulo) return;
                        const conteudo = window.prompt('Novo conteudo:', item.conteudo);
                        if (!conteudo) return;
                        void props.onUpdateNews(item.id, { titulo, conteudo });
                      }}
                    >
                      Editar
                    </button>
                    <button type="button" className="rounded border border-red-300 bg-red-50 px-3 py-1 text-sm text-red-700" onClick={() => void props.onDeleteNews(item.id)}>
                      Excluir
                    </button>
                  </div>
                ) : null}
              </div>
            ))}
          </div>
        </section>
      ) : null}

      {props.tab === 'eventos' ? (
        <section className="space-y-4">
          {props.canCreateContent ? (
            <form onSubmit={props.onCreateEvent} className="rounded-2xl border bg-white p-4 shadow-sm">
              <h2 className="text-lg font-bold">Novo evento</h2>
              <div className="mt-2 grid gap-2 md:grid-cols-2">
                <input className="rounded border px-3 py-2" placeholder="Nome" value={props.eventName} onChange={(e) => props.setEventName(e.target.value)} required />
                <input className="rounded border px-3 py-2" placeholder="Local" value={props.eventLocal} onChange={(e) => props.setEventLocal(e.target.value)} required />
                <select className="rounded border px-3 py-2" value={props.eventType} onChange={(e) => props.setEventType(e.target.value as 'MISSA' | 'REUNIAO' | 'FESTA' | 'RETIRO')}>
                  <option value="MISSA">Missa</option>
                  <option value="REUNIAO">Reuniao</option>
                  <option value="FESTA">Festa</option>
                  <option value="RETIRO">Retiro</option>
                </select>
                <input className="rounded border px-3 py-2" type="datetime-local" value={props.eventDate} onChange={(e) => props.setEventDate(e.target.value)} />
                <input className="rounded border px-3 py-2" type="datetime-local" value={props.eventDateEnd} onChange={(e) => props.setEventDateEnd(e.target.value)} />
                <input className="rounded border px-3 py-2" placeholder="Imagem URL" value={props.eventImageUrl} onChange={(e) => props.setEventImageUrl(e.target.value)} />
                <input className="rounded border px-3 py-2" placeholder="Link inscricao" value={props.eventSignupLink} onChange={(e) => props.setEventSignupLink(e.target.value)} />
                <input className="rounded border px-3 py-2" placeholder="Limite participantes" value={props.eventCapacity} onChange={(e) => props.setEventCapacity(e.target.value)} />
              </div>
              <textarea className="mt-2 min-h-20 w-full rounded border px-3 py-2" placeholder="Descricao" value={props.eventDescription} onChange={(e) => props.setEventDescription(e.target.value)} />
              <button className="mt-3 rounded bg-vinho px-4 py-2 text-sm font-semibold text-white">Publicar evento</button>
            </form>
          ) : null}
          <div className="grid gap-2 md:grid-cols-3">
            <input className="rounded border px-3 py-2 text-sm" placeholder="Buscar eventos..." value={props.eventsSearch} onChange={(e) => props.setEventsSearch(e.target.value)} />
            <select className="rounded border px-3 py-2 text-sm" value={props.eventTypeFilter} onChange={(e) => props.setEventTypeFilter(e.target.value as 'ALL' | 'MISSA' | 'REUNIAO' | 'FESTA' | 'RETIRO')}>
              <option value="ALL">Todos</option>
              <option value="MISSA">Missa</option>
              <option value="REUNIAO">Reuniao</option>
              <option value="FESTA">Festa</option>
              <option value="RETIRO">Retiro</option>
            </select>
          </div>
          <div className="space-y-2">
            {props.filteredEvents.map((item) => (
              <div key={item.id} className="rounded-xl border bg-white p-3">
                <p className="font-semibold">{item.nome}</p>
                <p className="text-sm text-zinc-600">
                  {item.tipo} - {item.local}
                </p>
                <div className="mt-2 flex gap-2">
                  <button type="button" className="rounded border px-2 py-1 text-xs" onClick={() => void props.onUpdateEvent(item.id, { nome: item.nome })}>
                    Editar
                  </button>
                  <button type="button" className="rounded border px-2 py-1 text-xs" onClick={() => void props.onDuplicateEvent(item.id)}>
                    Duplicar
                  </button>
                  <button type="button" className="rounded border border-red-300 bg-red-50 px-2 py-1 text-xs text-red-700" onClick={() => void props.onDeleteEvent(item.id)}>
                    Excluir
                  </button>
                </div>
              </div>
            ))}
          </div>
        </section>
      ) : null}

      {props.tab === 'avisos' ? <section className="grid gap-4 md:grid-cols-2">{props.news.filter((n) => n.avisoParoquial).map((item) => <NewsCard key={item.id} item={item} />)}</section> : null}

      {props.tab === 'grupos' || props.tab === 'pastorais' ? (
        <section className="space-y-4">
          <input className="w-full rounded border px-3 py-2 text-sm" placeholder="Buscar grupos..." value={props.groupsSearch} onChange={(e) => props.setGroupsSearch(e.target.value)} />
          <div className="grid gap-3 md:grid-cols-2">
            {props.filteredGroups.map((group) => (
              <article key={group.id} className="rounded-xl border bg-white p-3">
                <p className="font-semibold">{group.nome}</p>
                <p className="text-sm text-zinc-600">{group.descricao}</p>
                <p className="text-xs text-zinc-500">{group.responsavel || 'Sem responsavel informado'}</p>
              </article>
            ))}
          </div>
        </section>
      ) : null}

      {props.tab === 'horarios' ? (
        <section className="grid gap-4 md:grid-cols-2">
          <article className="rounded-2xl border bg-white p-4">
            <h2 className="font-semibold">Horarios de missa</h2>
            {props.massSchedules.map((m) => (
              <p key={m.id} className="mt-2 text-sm">
                {m.weekdayLabel} - {m.time} ({m.locationName})
              </p>
            ))}
          </article>
          <article className="rounded-2xl border bg-white p-4">
            <h2 className="font-semibold">Horarios da secretaria</h2>
            {props.officeHours.map((m) => (
              <p key={m.id} className="mt-2 text-sm">
                {m.weekdayLabel} - {m.openTime}
                {m.closeTime ? ` ate ${m.closeTime}` : ''}
              </p>
            ))}
          </article>
        </section>
      ) : null}

      {props.tab === 'localizacao' ? <section className="rounded-2xl border bg-white p-4">Paroquia Sao Paulo Apostolo - Umuarama/PR.</section> : null}

      {props.tab === 'calendario' ? (
        <section className="rounded-2xl border bg-white p-4">
          <h2 className="font-semibold">Calendario Paroquial</h2>
          <div className="mt-2 grid gap-2 md:grid-cols-2">
            {props.events.map((e) => (
              <div key={e.id} className="rounded border px-3 py-2 text-sm">
                {new Date(e.dataHora).toLocaleDateString('pt-BR')} - {e.nome}
              </div>
            ))}
          </div>
        </section>
      ) : null}

      {props.tab === 'midia' ? (
        <section className="space-y-3">
          <div className="rounded-2xl border bg-white p-4">
            <div className="grid gap-2 md:grid-cols-[220px_1fr_auto_auto]">
              <select className="rounded border px-3 py-2" value={props.mediaFolder} onChange={(e) => props.setMediaFolder(e.target.value as MediaFolder)}>
                <option value="noticias">/uploads/noticias</option>
                <option value="eventos">/uploads/eventos</option>
                <option value="grupos">/uploads/grupos</option>
                <option value="geral">/uploads/geral</option>
              </select>
              <input type="file" accept=".png,.jpg,.jpeg" className="rounded border px-3 py-2" onChange={(e) => props.setMediaFile(e.target.files?.[0] ?? null)} />
              <button type="button" className="rounded border px-3 py-2 text-sm" onClick={() => void props.onLoadMediaGallery()}>
                Atualizar
              </button>
              <button type="button" className="rounded bg-vinho px-3 py-2 text-sm font-semibold text-white" onClick={() => void props.onUploadMedia()}>
                Upload
              </button>
            </div>
          </div>
          <div className="grid gap-3 md:grid-cols-3">
            {props.mediaItems.map((item) => (
              <article key={`${item.folder}-${item.filename}`} className="overflow-hidden rounded-xl border bg-white">
                <img src={item.url} alt={item.filename} className="h-40 w-full object-cover" />
                <p className="p-2 text-xs">{item.filename}</p>
              </article>
            ))}
          </div>
        </section>
      ) : null}

      {props.tab === 'perfil' ? (
        <section className="rounded-2xl border bg-white p-5 shadow-sm">
          <p className="text-sm">
            {props.user.nome} - {props.user.email}
          </p>
          <p className="text-sm">Nivel: {props.accessLevelLabel(props.user.nivelAcesso)}</p>
          <p className="text-sm">{props.refreshToken ? 'Sessao ativa' : 'Sem refresh token'}</p>
          <button className="mt-3 rounded border border-red-300 bg-red-50 px-3 py-1 text-sm text-red-700" onClick={() => void props.onLogout()}>
            Sair
          </button>
        </section>
      ) : null}

      {props.tab === 'usuarios' ? (
        <section className="space-y-4">
          {!props.canManageAdmin ? <article className="rounded-2xl border bg-white p-5">Sem permissao.</article> : <AdminSection {...props} />}
        </section>
      ) : null}
    </div>
  );
}

function AdminSection(props: AuthenticatedAreaProps) {
  return (
    <>
      {props.adminNotice ? <div className="rounded border border-blue-200 bg-blue-50 px-3 py-2 text-sm text-blue-800">{props.adminNotice}</div> : null}
      <article className="rounded-2xl border bg-white p-4">
        <h3 className="font-semibold">Criar usuario</h3>
        <form className="mt-2 grid gap-2 md:grid-cols-4" onSubmit={props.onCreateUserByAdmin}>
          <input className="rounded border px-2 py-2" placeholder="Nome" value={props.newUserName} onChange={(e) => props.setNewUserName(e.target.value)} required />
          <input className="rounded border px-2 py-2" placeholder="Email" value={props.newUserEmail} onChange={(e) => props.setNewUserEmail(e.target.value)} required />
          <input className="rounded border px-2 py-2" placeholder="Senha" type="password" value={props.newUserPassword} onChange={(e) => props.setNewUserPassword(e.target.value)} required />
          <div className="flex gap-2">
            <select className="w-full rounded border px-2 py-2" value={props.newUserLevel} onChange={(e) => props.setNewUserLevel(Number(e.target.value))}>
              <option value={0}>Usuario</option>
              <option value={1}>Membro</option>
              <option value={2}>Coordenador</option>
              <option value={3}>Admin</option>
            </select>
            <button className="rounded bg-vinho px-3 py-2 text-sm font-semibold text-white">Criar</button>
          </div>
        </form>
      </article>
      <article className="rounded-2xl border bg-white p-4">
        <div className="mb-2 flex justify-between">
          <h3 className="font-semibold">Usuarios</h3>
          <button className="rounded border px-2 py-1 text-xs" onClick={props.onRefreshUsers}>
            Atualizar
          </button>
        </div>
        {props.usersLoading ? <p className="text-sm">Carregando...</p> : props.usersManagement.map((u) => (
          <div key={u.id} className="mb-2 grid gap-2 rounded border p-2 text-sm md:grid-cols-[1fr_auto_auto]">
            <div>{u.nome} - {u.email}</div>
            <select className="rounded border px-2 py-1" value={u.nivelAcesso} onChange={(e) => void props.onUpdateUserAccessLevel(u.id, Number(e.target.value))}>
              <option value={0}>Usuario</option>
              <option value={1}>Membro</option>
              <option value={2}>Coord</option>
              <option value={3}>Admin</option>
            </select>
            <button className="rounded border border-red-300 bg-red-50 px-2 py-1 text-red-700" onClick={() => void props.onDeleteUser(u.id)} disabled={u.id === props.user.id}>
              Excluir
            </button>
          </div>
        ))}
      </article>
      <section className="grid gap-3 md:grid-cols-2">
        <article className="rounded-2xl border bg-white p-4">
          <h3 className="font-semibold">Novo horario de missa</h3>
          <form className="mt-2 space-y-2" onSubmit={props.onCreateMassSchedule}>
            <select className="w-full rounded border px-3 py-2" value={props.massWeekday} onChange={(e) => props.setMassWeekday(Number(e.target.value))}>
              {props.weekdayOptions.map((w) => <option key={w.value} value={w.value}>{w.label}</option>)}
            </select>
            <input className="w-full rounded border px-3 py-2" type="time" value={props.massTime} onChange={(e) => props.setMassTime(e.target.value)} required />
            <input className="w-full rounded border px-3 py-2" placeholder="Local" value={props.massLocation} onChange={(e) => props.setMassLocation(e.target.value)} required />
            <textarea className="w-full rounded border px-3 py-2" placeholder="Observacoes" value={props.massNotes} onChange={(e) => props.setMassNotes(e.target.value)} />
            <button className="rounded bg-vinho px-3 py-2 text-sm font-semibold text-white">Criar horario</button>
          </form>
          {props.massSchedules.map((m) => (
            <div key={m.id} className="mt-2 flex items-center justify-between rounded border p-2 text-xs">
              <span>{m.weekdayLabel} {m.time}</span>
              <button className="rounded border border-red-300 bg-red-50 px-2 py-1 text-red-700" onClick={() => void props.onDeactivateMassSchedule(m.id)}>Desativar</button>
            </div>
          ))}
        </article>
        <article className="rounded-2xl border bg-white p-4">
          <h3 className="font-semibold">Novo horario secretaria</h3>
          <form className="mt-2 space-y-2" onSubmit={props.onCreateOfficeHour}>
            <select className="w-full rounded border px-3 py-2" value={props.officeWeekday} onChange={(e) => props.setOfficeWeekday(Number(e.target.value))}>
              {props.weekdayOptions.map((w) => <option key={w.value} value={w.value}>{w.label}</option>)}
            </select>
            <div className="grid grid-cols-2 gap-2">
              <input className="w-full rounded border px-3 py-2" type="time" value={props.officeOpenTime} onChange={(e) => props.setOfficeOpenTime(e.target.value)} required />
              <input className="w-full rounded border px-3 py-2" type="time" value={props.officeCloseTime} onChange={(e) => props.setOfficeCloseTime(e.target.value)} />
            </div>
            <input className="w-full rounded border px-3 py-2" placeholder="Label" value={props.officeLabel} onChange={(e) => props.setOfficeLabel(e.target.value)} />
            <textarea className="w-full rounded border px-3 py-2" placeholder="Observacoes" value={props.officeNotes} onChange={(e) => props.setOfficeNotes(e.target.value)} />
            <button className="rounded bg-vinho px-3 py-2 text-sm font-semibold text-white">Criar horario</button>
          </form>
          {props.officeHours.map((m) => (
            <div key={m.id} className="mt-2 flex items-center justify-between rounded border p-2 text-xs">
              <span>{m.weekdayLabel} {m.openTime}</span>
              <button className="rounded border border-red-300 bg-red-50 px-2 py-1 text-red-700" onClick={() => void props.onDeactivateOfficeHour(m.id)}>Desativar</button>
            </div>
          ))}
        </article>
      </section>
    </>
  );
}
