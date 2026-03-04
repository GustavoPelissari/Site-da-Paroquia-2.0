'use client';

import { FormEvent, useCallback, useMemo, useState } from 'react';
import {
  EventItem,
  GroupItem,
  MassSchedule,
  MediaFolder,
  MediaItem,
  NewsItem,
  NextMassResponse,
  OfficeHour,
} from '../components/home-page.types';
import { API_BASE_URL, fetchWithTimeout, getAuthHeaders, parseResponse } from '../services/api';

type UsePublicDataParams = {
  sessionToken: string | null;
};

type GalleryResponse = {
  folder: MediaFolder;
  items: MediaItem[];
};

function getApiOrigin() {
  try {
    const url = new URL(API_BASE_URL);
    return `${url.protocol}//${url.host}`;
  } catch {
    return 'http://localhost:3001';
  }
}

function resolveAssetUrl(raw?: string | null) {
  if (!raw) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  if (raw.startsWith('/')) return `${getApiOrigin()}${raw}`;
  return `${getApiOrigin()}/${raw}`;
}

export function usePublicData({ sessionToken }: UsePublicDataParams) {
  const [busy, setBusy] = useState(false);
  const [appError, setAppError] = useState<string | null>(null);
  const [events, setEvents] = useState<EventItem[]>([]);
  const [news, setNews] = useState<NewsItem[]>([]);
  const [massSchedules, setMassSchedules] = useState<MassSchedule[]>([]);
  const [officeHours, setOfficeHours] = useState<OfficeHour[]>([]);
  const [nextMass, setNextMass] = useState<NextMassResponse | null>(null);
  const [groups, setGroups] = useState<GroupItem[]>([]);
  const [mediaFolder, setMediaFolder] = useState<MediaFolder>('noticias');
  const [mediaItems, setMediaItems] = useState<MediaItem[]>([]);
  const [mediaFile, setMediaFile] = useState<File | null>(null);

  const [newsTitle, setNewsTitle] = useState('');
  const [newsSubtitle, setNewsSubtitle] = useState('');
  const [newsBody, setNewsBody] = useState('');
  const [newsCategory, setNewsCategory] = useState('Geral');
  const [newsImageUrl, setNewsImageUrl] = useState('');
  const [newsExternalLink, setNewsExternalLink] = useState('');
  const [newsHighlight, setNewsHighlight] = useState(false);
  const [newsParishNotice, setNewsParishNotice] = useState(false);

  const [eventName, setEventName] = useState('');
  const [eventLocal, setEventLocal] = useState('');
  const [eventType, setEventType] = useState<'MISSA' | 'REUNIAO' | 'FESTA' | 'RETIRO'>('MISSA');
  const [eventDate, setEventDate] = useState('');
  const [eventDateEnd, setEventDateEnd] = useState('');
  const [eventDescription, setEventDescription] = useState('');
  const [eventImageUrl, setEventImageUrl] = useState('');
  const [eventSignupLink, setEventSignupLink] = useState('');
  const [eventCapacity, setEventCapacity] = useState('');

  const [newsSearch, setNewsSearch] = useState('');
  const [eventsSearch, setEventsSearch] = useState('');
  const [groupsSearch, setGroupsSearch] = useState('');
  const [globalSearch, setGlobalSearch] = useState('');
  const [newsCategoryFilter, setNewsCategoryFilter] = useState('');
  const [eventTypeFilter, setEventTypeFilter] = useState<'ALL' | 'MISSA' | 'REUNIAO' | 'FESTA' | 'RETIRO'>('ALL');

  const missas = useMemo(() => events.filter((item) => item.tipo === 'MISSA').slice(0, 6), [events]);

  const filteredNews = useMemo(() => {
    const query = newsSearch.trim().toLowerCase();
    return news.filter((item) => {
      const matchesText =
        !query ||
        item.titulo.toLowerCase().includes(query) ||
          (item.subtitulo ?? '').toLowerCase().includes(query) ||
          item.conteudo.toLowerCase().includes(query) ||
          (item.autorNome ?? '').toLowerCase().includes(query);
      const matchesCategory =
        !newsCategoryFilter.trim() ||
        (item.categoria ?? '').toLowerCase() === newsCategoryFilter.trim().toLowerCase();
      return matchesText && matchesCategory;
    });
  }, [news, newsCategoryFilter, newsSearch]);

  const filteredEvents = useMemo(() => {
    const query = eventsSearch.trim().toLowerCase();
    return events.filter((item) => {
      const matchesText =
        !query ||
        item.nome.toLowerCase().includes(query) ||
          item.local.toLowerCase().includes(query) ||
          (item.descricao ?? '').toLowerCase().includes(query);
      const matchesType = eventTypeFilter === 'ALL' || item.tipo === eventTypeFilter;
      return matchesText && matchesType;
    });
  }, [eventTypeFilter, events, eventsSearch]);

  const filteredGroups = useMemo(() => {
    const query = groupsSearch.trim().toLowerCase();
    if (!query) return groups;
    return groups.filter((item) => {
      return (
        item.nome.toLowerCase().includes(query) ||
        item.descricao.toLowerCase().includes(query) ||
        (item.responsavel ?? '').toLowerCase().includes(query)
      );
    });
  }, [groups, groupsSearch]);

  const globalResults = useMemo(() => {
    const query = globalSearch.trim().toLowerCase();
    if (!query) return [] as Array<{ type: string; id: number; title: string; subtitle: string }>;
    const newsResults = news
      .filter((item) => item.titulo.toLowerCase().includes(query) || item.conteudo.toLowerCase().includes(query))
      .slice(0, 4)
      .map((item) => ({ type: 'Noticia', id: item.id, title: item.titulo, subtitle: item.categoria ?? 'Sem categoria' }));
    const eventResults = events
      .filter((item) => item.nome.toLowerCase().includes(query) || item.local.toLowerCase().includes(query))
      .slice(0, 4)
      .map((item) => ({ type: 'Evento', id: item.id, title: item.nome, subtitle: item.local }));
    const groupResults = groups
      .filter((item) => item.nome.toLowerCase().includes(query) || item.descricao.toLowerCase().includes(query))
      .slice(0, 4)
      .map((item) => ({ type: 'Grupo', id: item.id, title: item.nome, subtitle: item.descricao }));
    return [...newsResults, ...eventResults, ...groupResults];
  }, [events, globalSearch, groups, news]);

  const mapNews = useCallback((item: NewsItem): NewsItem => {
    return {
      ...item,
      imagemUrl: resolveAssetUrl(item.imagemUrl),
      galeriaUrls: (item.galeriaUrls ?? []).map((url) => resolveAssetUrl(url) ?? '').filter(Boolean),
    };
  }, []);

  const mapEvent = useCallback((item: EventItem): EventItem => {
    return {
      ...item,
      imagemUrl: resolveAssetUrl(item.imagemUrl),
    };
  }, []);

  const mapGroup = useCallback((item: GroupItem): GroupItem => {
    return {
      ...item,
      imagemUrl: resolveAssetUrl(item.imagemUrl),
    };
  }, []);

  const loadPublicData = useCallback(async () => {
    const safe = async <T,>(path: string, fallback: T): Promise<T> => {
      try {
        const response = await fetchWithTimeout(`${API_BASE_URL}${path}`, 7000, { cache: 'no-store' });
        return await parseResponse<T>(response);
      } catch {
        return fallback;
      }
    };

    const [eventsData, newsData, massData, officeData, nextData, groupsData] = await Promise.all([
      safe<EventItem[]>('/events', []),
      safe<NewsItem[]>('/news', []),
      safe<MassSchedule[]>('/public/mass-schedules', []),
      safe<OfficeHour[]>('/public/office-hours', []),
      safe<NextMassResponse>('/public/masses/next', { serverNow: new Date().toISOString(), nextMass: null }),
      safe<GroupItem[]>('/groups', []),
    ]);

    setEvents(eventsData.map(mapEvent));
    setNews(newsData.map(mapNews));
    setMassSchedules(massData);
    setOfficeHours(officeData);
    setNextMass(nextData);
    setGroups(groupsData.map(mapGroup));
  }, [mapEvent, mapGroup, mapNews]);

  const loadMediaGallery = useCallback(async () => {
    if (!sessionToken) return;
    try {
      const response = await fetch(`${API_BASE_URL}/uploads/gallery?folder=${mediaFolder}`, {
        headers: { authorization: `Bearer ${sessionToken}` },
        cache: 'no-store',
      });
      const payload = await parseResponse<GalleryResponse>(response);
      setMediaItems(
        payload.items.map((item) => ({
          ...item,
          url: resolveAssetUrl(item.url) ?? item.url,
        })),
      );
    } catch (error) {
      setAppError(error instanceof Error ? error.message : 'Falha ao carregar galeria.');
    }
  }, [mediaFolder, sessionToken]);

  const onUploadMedia = useCallback(async () => {
    if (!sessionToken || !mediaFile) return;
    setBusy(true);
    setAppError(null);
    try {
      const formData = new FormData();
      formData.append('file', mediaFile);
      const response = await fetch(`${API_BASE_URL}/uploads/image?folder=${mediaFolder}`, {
        method: 'POST',
        headers: { authorization: `Bearer ${sessionToken}` },
        body: formData,
      });
      await parseResponse<{ url: string }>(response);
      setMediaFile(null);
      await loadMediaGallery();
    } catch (error) {
      setAppError(error instanceof Error ? error.message : 'Falha ao enviar imagem.');
    } finally {
      setBusy(false);
    }
  }, [loadMediaGallery, mediaFile, mediaFolder, sessionToken]);

  const onCreateNews = useCallback(
    async (event: FormEvent<HTMLFormElement>) => {
      event.preventDefault();
      if (!sessionToken) return;
      setBusy(true);
      setAppError(null);
      try {
        const response = await fetch(`${API_BASE_URL}/news`, {
          method: 'POST',
          headers: getAuthHeaders(sessionToken),
          body: JSON.stringify({
            titulo: newsTitle.trim(),
            subtitulo: newsSubtitle.trim() || undefined,
            categoria: newsCategory.trim() || undefined,
            conteudo: newsBody.trim(),
            imagemUrl: newsImageUrl.trim() || undefined,
            linkExterno: newsExternalLink.trim() || undefined,
            publico: true,
            destaque: newsHighlight,
            avisoParoquial: newsParishNotice,
          }),
        });
        await parseResponse<NewsItem>(response);
        setNewsTitle('');
        setNewsSubtitle('');
        setNewsBody('');
        setNewsCategory('Geral');
        setNewsImageUrl('');
        setNewsExternalLink('');
        setNewsHighlight(false);
        setNewsParishNotice(false);
        await loadPublicData();
      } catch (error) {
        setAppError(error instanceof Error ? error.message : 'Falha ao criar noticia.');
      } finally {
        setBusy(false);
      }
    },
    [
      loadPublicData,
      newsBody,
      newsCategory,
      newsExternalLink,
      newsHighlight,
      newsImageUrl,
      newsParishNotice,
      newsSubtitle,
      newsTitle,
      sessionToken,
    ],
  );

  const onCreateEvent = useCallback(
    async (event: FormEvent<HTMLFormElement>) => {
      event.preventDefault();
      if (!sessionToken) return;
      setBusy(true);
      setAppError(null);
      try {
        const dataHora = eventDate ? new Date(eventDate).toISOString() : new Date().toISOString();
        const dataFinal = eventDateEnd ? new Date(eventDateEnd).toISOString() : undefined;
        const response = await fetch(`${API_BASE_URL}/events`, {
          method: 'POST',
          headers: getAuthHeaders(sessionToken),
          body: JSON.stringify({
            nome: eventName.trim(),
            local: eventLocal.trim(),
            tipo: eventType,
            dataHora,
            dataFinal,
            descricao: eventDescription.trim() || undefined,
            imagemUrl: eventImageUrl.trim() || undefined,
            linkInscricao: eventSignupLink.trim() || undefined,
            limiteParticipantes: eventCapacity ? Number(eventCapacity) : undefined,
            publico: true,
          }),
        });
        await parseResponse<EventItem>(response);
        setEventName('');
        setEventLocal('');
        setEventDate('');
        setEventDateEnd('');
        setEventType('MISSA');
        setEventDescription('');
        setEventImageUrl('');
        setEventSignupLink('');
        setEventCapacity('');
        await loadPublicData();
      } catch (error) {
        setAppError(error instanceof Error ? error.message : 'Falha ao criar evento.');
      } finally {
        setBusy(false);
      }
    },
    [
      eventCapacity,
      eventDate,
      eventDateEnd,
      eventDescription,
      eventImageUrl,
      eventLocal,
      eventName,
      eventSignupLink,
      eventType,
      loadPublicData,
      sessionToken,
    ],
  );

  const onUpdateNews = useCallback(
    async (id: number, payload: Partial<NewsItem>) => {
      if (!sessionToken) return;
      setBusy(true);
      setAppError(null);
      try {
        const response = await fetch(`${API_BASE_URL}/news/${id}`, {
          method: 'PATCH',
          headers: getAuthHeaders(sessionToken),
          body: JSON.stringify(payload),
        });
        await parseResponse<NewsItem>(response);
        await loadPublicData();
      } catch (error) {
        setAppError(error instanceof Error ? error.message : 'Falha ao atualizar noticia.');
      } finally {
        setBusy(false);
      }
    },
    [loadPublicData, sessionToken],
  );

  const onDeleteNews = useCallback(
    async (id: number) => {
      if (!sessionToken) return;
      setBusy(true);
      setAppError(null);
      try {
        const response = await fetch(`${API_BASE_URL}/news/${id}`, {
          method: 'DELETE',
          headers: { authorization: `Bearer ${sessionToken}` },
        });
        await parseResponse<{ message: string }>(response);
        await loadPublicData();
      } catch (error) {
        setAppError(error instanceof Error ? error.message : 'Falha ao excluir noticia.');
      } finally {
        setBusy(false);
      }
    },
    [loadPublicData, sessionToken],
  );

  const onUpdateEvent = useCallback(
    async (id: number, payload: Partial<EventItem>) => {
      if (!sessionToken) return;
      setBusy(true);
      setAppError(null);
      try {
        const response = await fetch(`${API_BASE_URL}/events/${id}`, {
          method: 'PATCH',
          headers: getAuthHeaders(sessionToken),
          body: JSON.stringify(payload),
        });
        await parseResponse<EventItem>(response);
        await loadPublicData();
      } catch (error) {
        setAppError(error instanceof Error ? error.message : 'Falha ao atualizar evento.');
      } finally {
        setBusy(false);
      }
    },
    [loadPublicData, sessionToken],
  );

  const onDeleteEvent = useCallback(
    async (id: number) => {
      if (!sessionToken) return;
      setBusy(true);
      setAppError(null);
      try {
        const response = await fetch(`${API_BASE_URL}/events/${id}`, {
          method: 'DELETE',
          headers: { authorization: `Bearer ${sessionToken}` },
        });
        await parseResponse<{ message: string }>(response);
        await loadPublicData();
      } catch (error) {
        setAppError(error instanceof Error ? error.message : 'Falha ao excluir evento.');
      } finally {
        setBusy(false);
      }
    },
    [loadPublicData, sessionToken],
  );

  const onDuplicateEvent = useCallback(
    async (id: number) => {
      if (!sessionToken) return;
      setBusy(true);
      setAppError(null);
      try {
        const response = await fetch(`${API_BASE_URL}/events/${id}/duplicate`, {
          method: 'POST',
          headers: { authorization: `Bearer ${sessionToken}` },
        });
        await parseResponse<EventItem>(response);
        await loadPublicData();
      } catch (error) {
        setAppError(error instanceof Error ? error.message : 'Falha ao duplicar evento.');
      } finally {
        setBusy(false);
      }
    },
    [loadPublicData, sessionToken],
  );

  const categories = useMemo(() => {
    const set = new Set<string>();
    for (const item of news) {
      if (item.categoria?.trim()) set.add(item.categoria.trim());
    }
    return Array.from(set).sort((a, b) => a.localeCompare(b, 'pt-BR'));
  }, [news]);

  const parishNotice = useMemo(() => {
    return news.find((item) => item.avisoParoquial) ?? null;
  }, [news]);

  return {
    busy,
    appError,
    setAppError,
    events,
    news,
    filteredEvents,
    filteredNews,
    massSchedules,
    officeHours,
    nextMass,
    groups,
    missas,
    mediaFolder,
    setMediaFolder,
    mediaItems,
    mediaFile,
    setMediaFile,
    loadMediaGallery,
    onUploadMedia,
    newsTitle,
    setNewsTitle,
    newsSubtitle,
    setNewsSubtitle,
    newsBody,
    setNewsBody,
    newsCategory,
    setNewsCategory,
    newsImageUrl,
    setNewsImageUrl,
    newsExternalLink,
    setNewsExternalLink,
    newsHighlight,
    setNewsHighlight,
    newsParishNotice,
    setNewsParishNotice,
    eventName,
    setEventName,
    eventLocal,
    setEventLocal,
    eventType,
    setEventType,
    eventDate,
    setEventDate,
    eventDateEnd,
    setEventDateEnd,
    eventDescription,
    setEventDescription,
    eventImageUrl,
    setEventImageUrl,
    eventSignupLink,
    setEventSignupLink,
    eventCapacity,
    setEventCapacity,
    newsSearch,
    setNewsSearch,
    eventsSearch,
    setEventsSearch,
    groupsSearch,
    setGroupsSearch,
    globalSearch,
    setGlobalSearch,
    globalResults,
    newsCategoryFilter,
    setNewsCategoryFilter,
    eventTypeFilter,
    setEventTypeFilter,
    filteredGroups,
    categories,
    parishNotice,
    loadPublicData,
    onCreateNews,
    onCreateEvent,
    onUpdateNews,
    onDeleteNews,
    onUpdateEvent,
    onDeleteEvent,
    onDuplicateEvent,
  };
}
