import { useState, useEffect } from 'react';
import { Link, useSearchParams, useNavigate } from 'react-router-dom';
import { apiFetch } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { AlertCircle, CheckCircle2 } from 'lucide-react';

export default function ResetPasswordScreen() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const token = searchParams.get('token');

  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!token) {
      setError('Token de recuperación no válido o faltante.');
    }
  }, [token]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    if (!token) {
      setError('Token de recuperación no válido.');
      return;
    }
    if (password !== passwordConfirmation) {
      setError('Las contraseñas no coinciden');
      return;
    }
    setLoading(true);
    try {
      await apiFetch('/password', {
        method: 'PUT',
        body: JSON.stringify({
          user: {
            reset_password_token: token,
            password,
            password_confirmation: passwordConfirmation,
          },
        }),
      });
      setSuccess('Tu contraseña ha sido actualizada correctamente.');
      setTimeout(() => navigate('/login'), 2500);
    } catch (err: any) {
      setError(err.message || 'Error al restablecer la contraseña');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[100dvh] bg-cream flex items-center justify-center px-4 pt-20 pb-12">
      <Card className="w-full max-w-md bg-white rounded-2xl border border-border-subtle shadow-sm">
        <CardHeader className="space-y-1 text-center pb-6">
          <CardTitle className="font-display text-3xl text-espresso tracking-tight">
            Nueva Contraseña
          </CardTitle>
          <CardDescription className="text-taupe text-sm">
            Crea una nueva contraseña para tu cuenta
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            {error && (
              <div className="flex items-center gap-2 text-sm text-red-600 bg-red-50 px-4 py-3 rounded-xl">
                <AlertCircle className="w-4 h-4 shrink-0" />
                {error}
              </div>
            )}
            {success && (
              <div className="flex items-center gap-2 text-sm text-green-700 bg-green-50 px-4 py-3 rounded-xl">
                <CheckCircle2 className="w-4 h-4 shrink-0" />
                {success}
              </div>
            )}
            <div className="space-y-2">
              <Label htmlFor="password" className="text-espresso text-sm font-medium">Nueva contraseña</Label>
              <Input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                placeholder="••••••••"
                className="w-full px-4 py-3 rounded-xl border border-border-subtle bg-white focus:border-terracotta focus:ring-terracotta/20"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="passwordConfirmation" className="text-espresso text-sm font-medium">Confirmar contraseña</Label>
              <Input
                id="passwordConfirmation"
                type="password"
                value={passwordConfirmation}
                onChange={(e) => setPasswordConfirmation(e.target.value)}
                required
                placeholder="••••••••"
                className="w-full px-4 py-3 rounded-xl border border-border-subtle bg-white focus:border-terracotta focus:ring-terracotta/20"
              />
            </div>
            <Button
              type="submit"
              disabled={loading || !!success || !token}
              className="w-full bg-terracotta text-white font-medium py-3 rounded-full hover:bg-terracotta-dark hover:shadow-glow transition-all duration-300 hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Actualizando...' : 'Restablecer contraseña'}
            </Button>
          </form>
          <p className="text-center text-sm text-taupe mt-6">
            <Link to="/login" className="text-terracotta font-medium hover:underline">
              Volver al inicio de sesión
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
