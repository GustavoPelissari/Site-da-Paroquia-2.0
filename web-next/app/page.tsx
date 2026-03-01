export default function Home() {
  return (
    <div className="min-h-screen">
      <header className="bg-vinho text-white">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-4">
          <div className="flex items-center gap-3">
            {/* Copie a logo para: web-next/public/img/IMAGEM DE SÃO PAULO APOSTOLO MONOCROMATICA.png */}
            <img
              src="/img/IMAGEM DE SÃO PAULO APOSTOLO MONOCROMATICA.png"
              alt="Logo Paróquia São Paulo Apóstolo"
              className="h-10 w-10 object-contain"
            />

            <div className="leading-tight">
              <div
                className="text-lg font-bold"
                style={{ fontFamily: 'var(--font-playfair)' }}
              >
                Paróquia São Paulo Apóstolo
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
            <a className="opacity-90 hover:opacity-100" href="/admin">
              Admin
            </a>
          </nav>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-10">
        <section className="grid gap-6 md:grid-cols-2">
          <div className="rounded-2xl border p-6 shadow-sm">
            <h1
              className="text-2xl font-bold"
              style={{ fontFamily: 'var(--font-playfair)' }}
            >
              Horários de Missa e eventos em destaque
            </h1>
            <p className="mt-2 text-zinc-700">
              Aqui vai a landing focada em conversão (como a doc pede): horários,
              próxima missa e eventos principais.
            </p>
          </div>

          <div className="rounded-2xl border p-6 shadow-sm">
            <h2 id="missas" className="text-xl font-bold">
              Missas (placeholder)
            </h2>
            <p className="mt-2 text-zinc-700">
              No próximo passo a gente conecta isso no backend e lista eventos do
              tipo MISSA.
            </p>
          </div>

          <div className="rounded-2xl border p-6 shadow-sm md:col-span-2">
            <h2 id="eventos" className="text-xl font-bold">
              Eventos (placeholder)
            </h2>
            <p className="mt-2 text-zinc-700">
              No próximo passo a gente conecta e lista Events.
            </p>
          </div>
        </section>
      </main>

      <footer className="border-t">
        <div className="mx-auto max-w-6xl px-4 py-6 text-sm text-zinc-600">
          PDGP • Paróquia São Paulo Apóstolo — Diocese de Umuarama
        </div>
      </footer>
    </div>
  );
}