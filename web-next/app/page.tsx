type EventItem = {
  id: number;
  nome: string;
  dataHora: string;
  local: string;
  tipo: 'MISSA' | 'REUNIAO' | 'FESTA';
};

type NewsItem = {
  id: number;
  titulo: string;
  conteudo: string;
  dataPublicacao: string;
};

const API_BASE_URL =
  process.env.API_BASE_URL ?? process.env.NEXT_PUBLIC_API_BASE_URL ?? 'http://localhost:3001/api';

async function fetchJson<T>(path: string): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    cache: 'no-store',
  });

  if (!response.ok) {
    throw new Error(`Falha em ${path}: HTTP ${response.status}`);
  }

  return response.json() as Promise<T>;
}

async function loadHomeData() {
  try {
    const [events, news] = await Promise.all([
      fetchJson<EventItem[]>('/events'),
      fetchJson<NewsItem[]>('/news'),
    ]);

    return { events, news, apiOnline: true };
  } catch {
    return { events: [], news: [], apiOnline: false };
  }
}

function formatDateTime(value: string) {
  return new Date(value).toLocaleString('pt-BR');
}

export default async function Home() {
  const { events, news, apiOnline } = await loadHomeData();

  const missas = events.filter((item) => item.tipo === 'MISSA').slice(0, 5);
  const proximosEventos = events.slice(0, 6);
  const ultimasNoticias = news.slice(0, 4);

  return (
    <div className="min-h-screen bg-gradient-to-b from-rose-50 to-white">
      <header className="bg-vinho text-white">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-4">
          <div className="flex items-center gap-3">
            <img
              src="/img/IMAGEM DE SÃO PAULO APOSTOLO MONOCROMATICA.png"
              alt="Logo da Paroquia"
              className="h-10 w-10 object-contain"
            />
            <div className="leading-tight">
              <div className="text-lg font-bold" style={{ fontFamily: 'var(--font-playfair)' }}>
                Paroquia Sao Paulo Apostolo
              </div>
              <div className="text-sm opacity-85">Diocese de Umuarama</div>
            </div>
          </div>
          <nav className="flex items-center gap-4 text-sm">
            <a className="opacity-90 hover:opacity-100" href="#missas">
              Missas
            </a>
            <a className="opacity-90 hover:opacity-100" href="#eventos">
              Eventos
            </a>
            <a className="opacity-90 hover:opacity-100" href="#noticias">
              Noticias
            </a>
          </nav>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-10">
        {!apiOnline ? (
          <div className="mb-6 rounded-xl border border-amber-300 bg-amber-50 px-4 py-3 text-sm text-amber-900">
            API offline no momento. Inicie o backend em `http://localhost:3001`.
          </div>
        ) : null}

        <section className="grid gap-6 md:grid-cols-2">
          <div className="rounded-2xl border p-6 shadow-sm md:col-span-2">
            <h1 className="text-2xl font-bold" style={{ fontFamily: 'var(--font-playfair)' }}>
              Horarios de missa e destaques da semana
            </h1>
            <p className="mt-2 text-zinc-700">
              Conteudo carregado da API oficial do projeto.
            </p>
          </div>

          <div id="missas" className="rounded-2xl border p-6 shadow-sm">
            <h2 className="text-xl font-bold">Missas</h2>
            <div className="mt-4 space-y-3">
              {missas.length === 0 ? (
                <p className="text-zinc-600">Nenhuma missa cadastrada.</p>
              ) : (
                missas.map((item) => (
                  <article key={item.id} className="rounded-xl border border-zinc-200 p-3">
                    <p className="font-semibold">{item.nome}</p>
                    <p className="text-sm text-zinc-600">{item.local}</p>
                    <p className="text-sm text-zinc-600">{formatDateTime(item.dataHora)}</p>
                  </article>
                ))
              )}
            </div>
          </div>

          <div id="eventos" className="rounded-2xl border p-6 shadow-sm">
            <h2 className="text-xl font-bold">Proximos eventos</h2>
            <div className="mt-4 space-y-3">
              {proximosEventos.length === 0 ? (
                <p className="text-zinc-600">Nenhum evento cadastrado.</p>
              ) : (
                proximosEventos.map((item) => (
                  <article key={item.id} className="rounded-xl border border-zinc-200 p-3">
                    <p className="font-semibold">{item.nome}</p>
                    <p className="text-sm text-zinc-600">{item.tipo}</p>
                    <p className="text-sm text-zinc-600">{formatDateTime(item.dataHora)}</p>
                  </article>
                ))
              )}
            </div>
          </div>

          <div id="noticias" className="rounded-2xl border p-6 shadow-sm md:col-span-2">
            <h2 className="text-xl font-bold">Noticias</h2>
            <div className="mt-4 grid gap-3 md:grid-cols-2">
              {ultimasNoticias.length === 0 ? (
                <p className="text-zinc-600">Nenhuma noticia publicada.</p>
              ) : (
                ultimasNoticias.map((item) => (
                  <article key={item.id} className="rounded-xl border border-zinc-200 p-4">
                    <p className="font-semibold">{item.titulo}</p>
                    <p className="mt-2 text-sm text-zinc-700">{item.conteudo}</p>
                    <p className="mt-2 text-xs text-zinc-500">{formatDateTime(item.dataPublicacao)}</p>
                  </article>
                ))
              )}
            </div>
          </div>
        </section>
      </main>

      <footer className="border-t">
        <div className="mx-auto max-w-6xl px-4 py-6 text-sm text-zinc-600">
          PDGP | Paroquia Sao Paulo Apostolo | Diocese de Umuarama
        </div>
      </footer>
    </div>
  );
}
