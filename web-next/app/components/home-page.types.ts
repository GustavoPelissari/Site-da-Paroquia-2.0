export type TabKey =
  | 'dashboard'
  | 'noticias'
  | 'eventos'
  | 'avisos'
  | 'grupos'
  | 'pastorais'
  | 'horarios'
  | 'localizacao'
  | 'usuarios'
  | 'perfil'
  | 'midia'
  | 'calendario';

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
  dataFinal?: string | null;
  local: string;
  tipo: 'MISSA' | 'REUNIAO' | 'FESTA' | 'RETIRO';
  descricao?: string | null;
  imagemUrl?: string | null;
  linkExterno?: string | null;
  linkInscricao?: string | null;
  limiteParticipantes?: number | null;
  autorNome?: string | null;
  groupId?: number | null;
};

export type NewsItem = {
  id: number;
  titulo: string;
  subtitulo?: string | null;
  categoria?: string | null;
  conteudo: string;
  dataPublicacao: string;
  agendamentoPublicacao?: string | null;
  dataExpiracao?: string | null;
  imagemUrl?: string | null;
  galeriaUrls?: string[];
  linkExterno?: string | null;
  autorNome?: string | null;
  destaque?: boolean;
  avisoParoquial?: boolean;
  groupId?: number | null;
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
  responsavel?: string | null;
  horarioEncontros?: string | null;
  localEncontro?: string | null;
  imagemUrl?: string | null;
  contato?: string | null;
  whatsappLink?: string | null;
  coordenadorUserId?: number | null;
  permitePdfUpload: boolean;
  permiteFormularios: boolean;
  permiteNoticias: boolean;
  permiteEventos: boolean;
};

export type MediaFolder = 'noticias' | 'eventos' | 'grupos' | 'geral';

export type MediaItem = {
  filename: string;
  folder: MediaFolder;
  url: string;
  size: number;
  updatedAt: string;
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
