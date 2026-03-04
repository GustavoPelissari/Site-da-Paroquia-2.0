'use client';

import { FormEvent, useCallback, useState } from 'react';
import { SessionResponse, User } from '../components/home-page.types';
import { API_BASE_URL, fetchWithTimeout, parseResponse } from '../services/api';

const TOKEN_KEY = 'pdgp_web_token';
const REFRESH_TOKEN_KEY = 'pdgp_web_refresh_token';

type AuthMode = 'login' | 'register';

export function useAuth() {
  const [busy, setBusy] = useState(false);
  const [authError, setAuthError] = useState<string | null>(null);
  const [authMode, setAuthMode] = useState<AuthMode>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [registerName, setRegisterName] = useState('');
  const [sessionToken, setSessionToken] = useState<string | null>(null);
  const [refreshToken, setRefreshToken] = useState<string | null>(null);
  const [user, setUser] = useState<User | null>(null);

  const clearSession = useCallback((onCleared?: () => void) => {
    window.localStorage.removeItem(TOKEN_KEY);
    window.localStorage.removeItem(REFRESH_TOKEN_KEY);
    setSessionToken(null);
    setRefreshToken(null);
    setUser(null);
    if (onCleared) onCleared();
  }, []);

  const loadMe = useCallback(async (token: string) => {
    const response = await fetchWithTimeout(`${API_BASE_URL}/auth/me`, 7000, {
      headers: { authorization: `Bearer ${token}` },
      cache: 'no-store',
    });
    const me = await parseResponse<User>(response);
    setUser(me);
  }, []);

  const restoreSession = useCallback(async (onCleared?: () => void) => {
    const localToken = window.localStorage.getItem(TOKEN_KEY);
    const localRefreshToken = window.localStorage.getItem(REFRESH_TOKEN_KEY);
    if (!localToken) return;

    setSessionToken(localToken);
    setRefreshToken(localRefreshToken);
    try {
      await loadMe(localToken);
    } catch {
      clearSession(onCleared);
    }
  }, [clearSession, loadMe]);

  const onLogin = useCallback(async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setAuthError(null);
    setBusy(true);
    try {
      const response = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ email, senha: password }),
      });
      const data = await parseResponse<SessionResponse>(response);
      window.localStorage.setItem(TOKEN_KEY, data.token);
      window.localStorage.setItem(REFRESH_TOKEN_KEY, data.refreshToken);
      setSessionToken(data.token);
      setRefreshToken(data.refreshToken);
      setUser(data.user);
      setEmail('');
      setPassword('');
    } catch (error) {
      setAuthError(error instanceof Error ? error.message : 'Falha no login.');
    } finally {
      setBusy(false);
    }
  }, [email, password]);

  const onRegister = useCallback(async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setAuthError(null);
    setBusy(true);
    try {
      const response = await fetch(`${API_BASE_URL}/auth/register`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ name: registerName, email, password }),
      });
      const data = await parseResponse<SessionResponse>(response);
      window.localStorage.setItem(TOKEN_KEY, data.token);
      window.localStorage.setItem(REFRESH_TOKEN_KEY, data.refreshToken);
      setSessionToken(data.token);
      setRefreshToken(data.refreshToken);
      setUser(data.user);
      setEmail('');
      setPassword('');
      setRegisterName('');
    } catch (error) {
      setAuthError(error instanceof Error ? error.message : 'Falha no cadastro.');
    } finally {
      setBusy(false);
    }
  }, [email, password, registerName]);

  const onForgotPassword = useCallback(async () => {
    if (!email.trim()) {
      setAuthError('Informe seu email para recuperar a senha.');
      return;
    }
    setBusy(true);
    setAuthError(null);
    try {
      const response = await fetch(`${API_BASE_URL}/auth/forgot-password`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ email: email.trim() }),
      });
      await parseResponse<{ message: string }>(response);
      window.alert('Se o e-mail estiver cadastrado, voce recebera instrucoes para redefinir sua senha.');
    } catch (error) {
      setAuthError(
        error instanceof Error ? error.message : 'Nao foi possivel solicitar recuperacao de senha.',
      );
    } finally {
      setBusy(false);
    }
  }, [email]);

  const onLogout = useCallback(async (onCleared?: () => void) => {
    try {
      if (sessionToken) {
        await fetch(`${API_BASE_URL}/auth/logout`, {
          method: 'POST',
          headers: { authorization: `Bearer ${sessionToken}` },
        });
      }
    } catch {
      // noop
    }
    clearSession(onCleared);
  }, [clearSession, sessionToken]);

  return {
    busy,
    authError,
    authMode,
    email,
    password,
    registerName,
    sessionToken,
    refreshToken,
    user,
    setUser,
    setAuthMode,
    setEmail,
    setPassword,
    setRegisterName,
    restoreSession,
    onLogin,
    onRegister,
    onForgotPassword,
    onLogout,
  };
}
