import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import { apiFetch } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';
import { AlertCircle, User, Trash2, LogOut } from 'lucide-react';

export default function ProfileScreen() {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [newPasswordConfirmation, setNewPasswordConfirmation] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loadingUpdate, setLoadingUpdate] = useState(false);
  const [loadingDelete, setLoadingDelete] = useState(false);

  if (!user) return null;

  const handleUpdatePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    if (newPassword !== newPasswordConfirmation) {
      setError('Las contraseñas no coinciden');
      return;
    }
    setLoadingUpdate(true);
    try {
      await apiFetch('/register', {
        method: 'PUT',
        body: JSON.stringify({
          user: {
            current_password: currentPassword,
            password: newPassword,
            password_confirmation: newPasswordConfirmation,
          },
        }),
      });
      setSuccess('Contraseña actualizada correctamente');
      setCurrentPassword('');
      setNewPassword('');
      setNewPasswordConfirmation('');
    } catch (err: any) {
      setError(err.message || 'Error al actualizar contraseña');
    } finally {
      setLoadingUpdate(false);
    }
  };

  const handleDeleteAccount = async () => {
    if (!confirm('¿Estás seguro? Esta acción eliminará tu cuenta permanentemente.')) return;
    setLoadingDelete(true);
    try {
      await apiFetch('/register', { method: 'DELETE' });
      logout();
      navigate('/');
    } catch (err: any) {
      setError(err.message || 'Error al eliminar cuenta');
      setLoadingDelete(false);
    }
  };

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  return (
    <div className="min-h-[100dvh] bg-cream pt-20 pb-12 px-4">
      <div className="max-w-md mx-auto space-y-6">
        <Card className="bg-white rounded-2xl border border-border-subtle shadow-sm">
          <CardHeader className="pb-4">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-full bg-terracotta/10 flex items-center justify-center">
                <User className="w-6 h-6 text-terracotta" />
              </div>
              <div>
                <CardTitle className="font-display text-2xl text-espresso tracking-tight">
                  Mi Perfil
                </CardTitle>
                <CardDescription className="text-taupe text-sm">
                  {user.email ?? 'No email'}
                </CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div className="bg-cream rounded-xl p-3">
                <p className="text-taupe">Miembro desde</p>
                <p className="text-espresso font-medium">
                  {user.created_at ? new Date(user.created_at).toLocaleDateString('es-MX') : '-'}
                </p>
              </div>
              <div className="bg-cream rounded-xl p-3">
                <p className="text-taupe">ID de usuario</p>
                <p className="text-espresso font-medium">#{user.id}</p>
              </div>
            </div>
            <Button
              onClick={handleLogout}
              variant="outline"
              className="w-full rounded-full border-border-subtle text-espresso hover:bg-cream"
            >
              <LogOut className="w-4 h-4 mr-2" />
              Cerrar sesión
            </Button>
          </CardContent>
        </Card>

        <Card className="bg-white rounded-2xl border border-border-subtle shadow-sm">
          <CardHeader className="pb-4">
            <CardTitle className="font-display text-xl text-espresso tracking-tight">
              Cambiar Contraseña
            </CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleUpdatePassword} className="space-y-4">
              {error && (
                <div className="flex items-center gap-2 text-sm text-red-600 bg-red-50 px-4 py-3 rounded-xl">
                  <AlertCircle className="w-4 h-4 shrink-0" />
                  {error}
                </div>
              )}
              {success && (
                <div className="text-sm text-green-700 bg-green-50 px-4 py-3 rounded-xl">
                  {success}
                </div>
              )}
              <div className="space-y-2">
                <Label className="text-espresso text-sm font-medium">Contraseña actual</Label>
                <Input
                  type="password"
                  value={currentPassword}
                  onChange={(e) => setCurrentPassword(e.target.value)}
                  required
                  className="w-full px-4 py-3 rounded-xl border border-border-subtle bg-white focus:border-terracotta"
                />
              </div>
              <div className="space-y-2">
                <Label className="text-espresso text-sm font-medium">Nueva contraseña</Label>
                <Input
                  type="password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  required
                  className="w-full px-4 py-3 rounded-xl border border-border-subtle bg-white focus:border-terracotta"
                />
              </div>
              <div className="space-y-2">
                <Label className="text-espresso text-sm font-medium">Confirmar nueva contraseña</Label>
                <Input
                  type="password"
                  value={newPasswordConfirmation}
                  onChange={(e) => setNewPasswordConfirmation(e.target.value)}
                  required
                  className="w-full px-4 py-3 rounded-xl border border-border-subtle bg-white focus:border-terracotta"
                />
              </div>
              <Button
                type="submit"
                disabled={loadingUpdate}
                className="w-full bg-terracotta text-white font-medium py-3 rounded-full hover:bg-terracotta-dark hover:shadow-glow transition-all duration-300 disabled:opacity-50"
              >
                {loadingUpdate ? 'Actualizando...' : 'Actualizar contraseña'}
              </Button>
            </form>
          </CardContent>
        </Card>

        <Separator className="bg-border-subtle" />

        <div className="pb-4">
          <Button
            onClick={handleDeleteAccount}
            disabled={loadingDelete}
            variant="outline"
            className="w-full rounded-full border-red-200 text-red-600 hover:bg-red-50 hover:text-red-700"
          >
            <Trash2 className="w-4 h-4 mr-2" />
            {loadingDelete ? 'Eliminando...' : 'Eliminar mi cuenta'}
          </Button>
        </div>
      </div>
    </div>
  );
}
