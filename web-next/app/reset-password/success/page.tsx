import Link from 'next/link';

export default function ResetPasswordSuccessPage() {
  return (
    <main className="min-h-screen bg-gradient-to-b from-rose-50 to-white px-4 py-10">
      <section className="mx-auto w-full max-w-md rounded-2xl border bg-white p-6 shadow-sm">
        <h1 className="text-2xl font-bold" style={{ fontFamily: 'var(--font-playfair)' }}>
          Senha atualizada
        </h1>
        <p className="mt-2 text-sm text-zinc-700">
          Sua senha foi alterada com sucesso. Agora entre novamente no app com a nova senha.
        </p>
        <div className="mt-6 text-sm">
          <Link href="/" className="text-vinho hover:underline">
            Voltar para a pagina inicial
          </Link>
        </div>
      </section>
    </main>
  );
}
