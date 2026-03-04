export type TabKey = 'home' | 'conteudo' | 'horarios' | 'grupos' | 'eventos' | 'perfil' | 'admin';

export type User = {
  id: number;
  nome: string;
  email: string;
  nivelAcesso: number;
};

export type SessionResponse = {
  token: string;
  refreshToken: string;
  user: User;
};

export type EventItem = {
  id: number;
  nome: string;
  dataHora: string;
  local: string;
  tipo: 'MISSA' | 'REUNIAO' | 'FESTA';
  descricao?: string | null;
  imagemUrl?: string | null;
  linkExterno?: string | null;
  autorNome?: string | null;
};

export type NewsItem = {
  id: number;
  titulo: string;
  conteudo: string;
  dataPublicacao: string;
  imagemUrl?: string | null;
  linkExterno?: string | null;
  autorNome?: string | null;
};

export type MassSchedule = {
  id: number;
  weekday: number;
  weekdayLabel: string;
  time: string;
  locationName: string;
  notes?: string | null;
};

export type OfficeHour = {
  id: number;
  weekday: number;
  weekdayLabel: string;
  openTime: string;
  closeTime?: string | null;
  label?: string | null;
  notes?: string | null;
};

export type NextMassResponse = {
  serverNow: string;
  nextMass?: {
    weekdayLabel: string;
    time: string;
    locationName: string;
    startsAt: string;
  } | null;
};

export type GroupItem = {
  id: number;
  nome: string;
  descricao: string;
  coordenadorUserId?: number | null;
  permitePdfUpload: boolean;
  permiteFormularios: boolean;
  permiteNoticias: boolean;
  permiteEventos: boolean;
};

export const WEEKDAY_OPTIONS = [
  { value: 0, label: 'Domingo' },
  { value: 1, label: 'Segunda' },
  { value: 2, label: 'Terca' },
  { value: 3, label: 'Quarta' },
  { value: 4, label: 'Quinta' },
  { value: 5, label: 'Sexta' },
  { value: 6, label: 'Sabado' },
];
