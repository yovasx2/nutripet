const API_BASE = import.meta.env.VITE_API_URL || "/api";

function getToken(): string | null {
  return localStorage.getItem("token");
}

function authHeaders(): Record<string, string> {
  const token = getToken();
  return token ? { Authorization: `Bearer ${token}` } : {};
}

function extractErrorMessage(data: any, status: number): string {
  if (typeof data === "string") return data;

  // Devise custom controllers format: { status: { message: "..." }, errors: [...] }
  if (data?.status?.message) {
    const base = data.status.message;
    if (Array.isArray(data.errors) && data.errors.length > 0) {
      return `${base}: ${data.errors.join(", ")}`;
    }
    return base;
  }

  // Rails default error format: { errors: [...] } or { error: "..." }
  if (Array.isArray(data?.errors) && data.errors.length > 0) {
    return data.errors.join(", ");
  }
  if (data?.error) {
    return data.error;
  }
  if (data?.message) {
    return data.message;
  }

  return `HTTP ${status}`;
}

export async function apiFetch(path: string, options: RequestInit = {}) {
  const url = `${API_BASE.replace(/\/$/, "")}/${path.replace(/^\//, "")}`;
  const res = await fetch(url, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      ...authHeaders(),
      ...(options.headers || {}),
    },
  });

  if (!res.ok) {
    const data = await res.json().catch(() => null);
    throw new Error(extractErrorMessage(data, res.status));
  }

  return res.json();
}

export function setToken(token: string) {
  localStorage.setItem("token", token);
}

export function removeToken() {
  localStorage.removeItem("token");
}
