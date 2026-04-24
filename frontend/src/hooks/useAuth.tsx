import { useState, useEffect, useCallback, createContext, useContext } from "react";
import { apiFetch, setToken, removeToken } from "@/lib/api";

interface User {
  id: number;
  email: string;
  name?: string | null;
  created_at: string;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string, passwordConfirmation: string, name?: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const fetchMe = useCallback(async () => {
    try {
      const data = await apiFetch("/users/me");
      setUser(data);
    } catch {
      setUser(null);
    }
  }, []);

  useEffect(() => {
    fetchMe().finally(() => setIsLoading(false));
  }, [fetchMe]);

  const login = useCallback(async (email: string, password: string) => {
    const res = await apiFetch("/login", {
      method: "POST",
      body: JSON.stringify({ user: { email, password } }),
    });
    if (res.token) setToken(res.token);
    setUser(res.data);
  }, []);

  const register = useCallback(async (email: string, password: string, passwordConfirmation: string, name?: string) => {
    const payload: Record<string, string> = { email, password, password_confirmation: passwordConfirmation };
    if (name?.trim()) payload.name = name.trim();
    const res = await apiFetch("/register", {
      method: "POST",
      body: JSON.stringify({ user: payload }),
    });
    if (res.token) setToken(res.token);
    setUser(res.data);
  }, []);

  const logout = useCallback(async () => {
    try {
      await apiFetch("/logout", { method: "DELETE" });
    } finally {
      removeToken();
      setUser(null);
    }
  }, []);

  return (
    <AuthContext.Provider value={{ user, isLoading, login, register, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextType {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
