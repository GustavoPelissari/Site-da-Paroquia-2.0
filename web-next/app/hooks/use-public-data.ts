'use client';

import { FormEvent, useCallback, useMemo, useState } from 'react';
import {
  EventItem,
  GroupItem,
  MassSchedule,
  NewsItem,
  NextMassResponse,
  OfficeHour,
} from '../components/home-page.types';
import { API_BASE_URL, fetchWithTimeout, getAuthHeaders, parseResponse } from '../services/api';

type UsePublicDataParams = {
  sessionToken: string | null;
};

export function usePublicData({ sessionToken }: UsePublicDataParams) {
  const [busy, setBusy] = useState(false);
  const [appError, setAppError] = useState<string | null>(null);
  const [events, setEvents] = useState<EventItem[]>([]);
  const [news, setNews] = useState<NewsItem[]>([]);
  const [massSchedules, setMassSchedules] = useState<MassSchedule[]>([]);
  const [officeHours, setOfficeHours] = useState<OfficeHour[]>([]);
  const [nextMass, setNextMass] = useState<NextMassResponse | null>(null);
  const [groups, setGroups] = useState<GroupItem[]>([]);

  const [newsTitle, setNewsTitle] = useState('');
  const [newsBody, setNewsBody] = useState('');
  const [eventName, setEventName] = useState('');
  const [eventLocal, setEventLocal] = useState('');
  const [eventType, setEventType] = useState<'MISSA' | 'REUNIAO' | 'FESTA'>('MISSA');
  const [eventDate, setEventDate] = useState('');
  const [newsSearch, setNewsSearch] = useState('');
  const [eventsSearch, setEventsSearch] = useState('');
  const [groupsSearch, setGroupsSearch] = useState('');

  const missas = useMemo(() => events.filter((item) => item.tipo === 'MISSA').slice(0, 6), [events]);
  const filteredNews = useMemo(() => {
    const query = newsSearch.trim().toLowerCase();
    if (!query) return news;
    return news.filter((item) => {
      return (
        item.titulo.toLowerCase().includes(query) ||
        item.conteudo.toLowerCase().includes(query) ||
        (item.autorNome ?? '').toLowerCase().includes(query)
      );
    });
  }, [news, newsSearch]);
  const filteredEvents = useMemo(() => {
    const query = eventsSearch.trim().toLowerCase();
    if (!query) return events;
    return events.filter((item) => {
      return (
        item.nome.toLowerCase().includes(query) ||
        item.local.toLowerCase().includes(query) ||
        (item.descricao ?? '').toLowerCase().includes(query)
      );
    });
  }, [events, eventsSearch]);
  const filteredGroups = useMemo(() => {
    const query = groupsSearch.trim().toLowerCase();
    if (!query) return groups;
    return groups.filter((item) => {
      return item.nome.toLowerCase().includes(query) || item.descricao.toLowerCase().includes(query);
    });
  }, [groups, groupsSearch]);

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

    setEvents(eventsData);
    setNews(newsData);
    setMassSchedules(massData);
    setOfficeHours(officeData);
    setNextMass(nextData);
    setGroups(groupsData);
  }, []);

  const onCreateNews = useCallback(async (event: FormEvent<HTMLFormElement>) => {
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
          conteudo: newsBody.trim(),
          publico: true,
        }),
      });
      await parseResponse<NewsItem>(response);
      setNewsTitle('');
      setNewsBody('');
      await loadPublicData();
    } catch (error) {
      setAppError(error instanceof Error ? error.message : 'Falha ao criar noticia.');
    } finally {
      setBusy(false);
    }
  }, [loadPublicData, newsBody, newsTitle, sessionToken]);

  const onCreateEvent = useCallback(async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!sessionToken) return;
    setBusy(true);
    setAppError(null);
    try {
      const dataHora = eventDate ? new Date(eventDate).toISOString() : new Date().toISOString();
      const response = await fetch(`${API_BASE_URL}/events`, {
        method: 'POST',
        headers: getAuthHeaders(sessionToken),
        body: JSON.stringify({
          nome: eventName.trim(),
          local: eventLocal.trim(),
          tipo: eventType,
          dataHora,
          publico: true,
        }),
      });
      await parseResponse<EventItem>(response);
      setEventName('');
      setEventLocal('');
      setEventDate('');
      setEventType('MISSA');
      await loadPublicData();
    } catch (error) {
      setAppError(error instanceof Error ? error.message : 'Falha ao criar evento.');
    } finally {
      setBusy(false);
    }
  }, [eventDate, eventLocal, eventName, eventType, loadPublicData, sessionToken]);

  const onUpdateNews = useCallback(async (id: number, payload: { titulo: string; conteudo: string }) => {
    if (!sessionToken) return;
    setBusy(true);
    setAppError(null);
    try {
      const response = await fetch(`${API_BASE_URL}/news/${id}`, {
        method: 'PATCH',
        headers: getAuthHeaders(sessionToken),
        body: JSON.stringify({
          titulo: payload.titulo.trim(),
          conteudo: payload.conteudo.trim(),
        }),
      });
      await parseResponse<NewsItem>(response);
      await loadPublicData();
    } catch (error) {
      setAppError(error instanceof Error ? error.message : 'Falha ao atualizar noticia.');
    } finally {
      setBusy(false);
    }
  }, [loadPublicData, sessionToken]);

  const onDeleteNews = useCallback(async (id: number) => {
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
  }, [loadPublicData, sessionToken]);

  const onUpdateEvent = useCallback(async (id: number, payload: { nome: string; local: string }) => {
    if (!sessionToken) return;
    setBusy(true);
    setAppError(null);
    try {
      const response = await fetch(`${API_BASE_URL}/events/${id}`, {
        method: 'PATCH',
        headers: getAuthHeaders(sessionToken),
        body: JSON.stringify({
          nome: payload.nome.trim(),
          local: payload.local.trim(),
        }),
      });
      await parseResponse<EventItem>(response);
      await loadPublicData();
    } catch (error) {
      setAppError(error instanceof Error ? error.message : 'Falha ao atualizar evento.');
    } finally {
      setBusy(false);
    }
  }, [loadPublicData, sessionToken]);

  const onDeleteEvent = useCallback(async (id: number) => {
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
  }, [loadPublicData, sessionToken]);

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
    newsSearch,
    setNewsSearch,
    eventsSearch,
    setEventsSearch,
    groupsSearch,
    setGroupsSearch,
    filteredGroups,
    loadPublicData,
    onCreateNews,
    onCreateEvent,
    onUpdateNews,
    onDeleteNews,
    onUpdateEvent,
    onDeleteEvent,
  };
}
