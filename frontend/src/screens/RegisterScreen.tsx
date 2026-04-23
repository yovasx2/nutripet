import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import { validateRegister } from '@/lib/validators';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { AlertCircle } from 'lucide-react';

export default function RegisterScreen() {
  const navigate = useNavigate();
  const { register } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    const validationError = validateRegister(email, password, passwordConfirmation);
    if (validationError) {
      setError(validationError);
      return;
    }
    setLoading(true);
    try {
      await register(email, password, passwordConfirmation);
      navigate('/dashboard');
    } catch (err: any) {
      setError(err.message || 'Error al registrarse');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[100dvh] bg-cream flex items-center justify-center px-4 pt-20 pb-12">
      <Card className="w-full max-w-md bg-white rounded-2xl border border-border-subtle shadow-sm">
        <CardHeader className="space-y-1 text-center pb-6">
          <CardTitle className="font-display text-3xl text-espresso tracking-tight">
            Crear Cuenta
          </CardTitle>
          <CardDescription className="text-taupe text-sm">
            Únete a NutriPet y mejora la nutrición de tu perro
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
            <div className="space-y-2">
              <Label htmlFor="email" className="text-espresso text-sm font-medium">Correo electrónico</Label>
              <Input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                placeholder="tu@email.com"
                className="w-full px-4 py-3 rounded-xl border border-border-subtle bg-white focus:border-terracotta focus:ring-terracotta/20"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password" className="text-espresso text-sm font-medium">Contraseña</Label>
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
              disabled={loading}
              className="w-full bg-terracotta text-white font-medium py-3 rounded-full hover:bg-terracotta-dark hover:shadow-glow transition-all duration-300 hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Creando cuenta...' : 'Crear cuenta'}
            </Button>
          </form>
          <p className="text-center text-sm text-taupe mt-6">
            ¿Ya tienes cuenta?{' '}
            <Link to="/login" className="text-terracotta font-medium hover:underline">
              Inicia sesión
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
