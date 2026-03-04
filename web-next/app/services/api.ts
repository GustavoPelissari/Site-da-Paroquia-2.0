const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? process.env.API_BASE_URL ?? 'http://localhost:3001/api';

export { API_BASE_URL };

export async function parseResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    let message = `Erro HTTP ${response.status}`;
    try {
      const raw = (await response.json()) as { message?: string | string[]; error?: string };
      if (typeof raw.message === 'string' && raw.message.trim()) message = raw.message;
      if (Array.isArray(raw.message) && raw.message[0]) message = raw.message[0];
      if (raw.error && message.startsWith('Erro HTTP')) message = raw.error;
    } catch {
      // noop
    }
    throw new Error(message);
  }
  return response.json() as Promise<T>;
}

export async function fetchWithTimeout(input: string, timeoutMs = 7000, init?: RequestInit) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  try {
    return await fetch(input, { ...init, signal: controller.signal });
  } finally {
    clearTimeout(timeout);
  }
}

export function getAuthHeaders(token: string) {
  return {
    'content-type': 'application/json',
    authorization: `Bearer ${token}`,
  };
}
