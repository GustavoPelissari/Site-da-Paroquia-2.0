'use client';

import { FormEvent, Suspense, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? process.env.API_BASE_URL ?? 'http://localhost:3001/api';

type ValidateResponse = { valid?: boolean };

function ResetPasswordContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = useMemo(() => searchParams.get('token')?.trim() ?? '', [searchParams]);

  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [tokenValid, setTokenValid] = useState<boolean | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    const run = async () => {
      if (!token) {
        setTokenValid(false);
        return;
      }
      try {
        const response = await fetch(
          `${API_BASE_URL}/auth/reset-password/validate?token=${encodeURIComponent(token)}`,
          { cache: 'no-store' },
        );
        if (!active) return;
        if (!response.ok) {
          setTokenValid(false);
          return;
        }
        const data = (await response.json()) as ValidateResponse;
        setTokenValid(Boolean(data.valid));
      } catch {
        if (active) setTokenValid(false);
      }
    };

    setTokenValid(null);
    void run();
    return () => {
      active = false;
    };
  }, [token]);

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!token) {
      setError('Token ausente.');
      return;
    }
    if (password.length < 6) {
      setError('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    if (password !== confirmPassword) {
      setError('Senha e confirmacao precisam ser iguais.');
      return;
    }

    setError(null);
    setSubmitting(true);
    try {
      const response = await fetch(`${API_BASE_URL}/auth/reset-password`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          token,
          password,
          confirmPassword,
        }),
      });
      if (!response.ok) {
        setError('Nao foi possivel redefinir sua senha. Solicite um novo link.');
        return;
      }
      router.push('/reset-password/success');
    } catch {
      setError('Falha de conexao. Tente novamente.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="min-h-screen bg-gradient-to-b from-rose-50 to-white px-4 py-10">
      <section className="mx-auto w-full max-w-md rounded-2xl border bg-white p-6 shadow-sm">
        <h1 className="text-2xl font-bold" style={{ fontFamily: 'var(--font-playfair)' }}>
          Redefinir senha
        </h1>
        <p className="mt-2 text-sm text-zinc-600">
          Defina sua nova senha para voltar a acessar sua conta.
        </p>

        {tokenValid === null ? (
          <p className="mt-6 text-sm text-zinc-600">Validando link...</p>
        ) : null}

        {tokenValid === false ? (
          <div className="mt-6 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-700">
            Link invalido ou expirado. Solicite uma nova recuperacao de senha.
          </div>
        ) : null}

        {tokenValid ? (
          <form className="mt-6 space-y-3" onSubmit={onSubmit}>
            <label className="block">
              <span className="mb-1 block text-sm font-medium">Nova senha</span>
              <input
                type="password"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                className="w-full rounded-lg border border-zinc-300 px-3 py-2 outline-none ring-vinho focus:ring-2"
                placeholder="Minimo de 6 caracteres"
                autoComplete="new-password"
              />
            </label>

            <label className="block">
              <span className="mb-1 block text-sm font-medium">Confirmar senha</span>
              <input
                type="password"
                value={confirmPassword}
                onChange={(event) => setConfirmPassword(event.target.value)}
                className="w-full rounded-lg border border-zinc-300 px-3 py-2 outline-none ring-vinho focus:ring-2"
                placeholder="Repita a senha"
                autoComplete="new-password"
              />
            </label>

            {error ? (
              <div className="rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-700">
                {error}
              </div>
            ) : null}

            <button
              disabled={submitting}
              className="w-full rounded-lg bg-vinho px-4 py-2 font-medium text-white disabled:opacity-60"
              type="submit"
            >
              {submitting ? 'Salvando...' : 'Salvar nova senha'}
            </button>
          </form>
        ) : null}

        <div className="mt-6 text-sm">
          <Link href="/" className="text-vinho hover:underline">
            Voltar para a pagina inicial
          </Link>
        </div>
      </section>
    </main>
  );
}

export default function ResetPasswordPage() {
  return (
    <Suspense
      fallback={
        <main className="min-h-screen bg-gradient-to-b from-rose-50 to-white px-4 py-10">
          <section className="mx-auto w-full max-w-md rounded-2xl border bg-white p-6 shadow-sm">
            <p className="text-sm text-zinc-600">Carregando...</p>
          </section>
        </main>
      }
    >
      <ResetPasswordContent />
    </Suspense>
  );
}
