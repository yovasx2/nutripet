import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import { apiFetch } from '@/lib/api';
import { isValidPassword } from '@/lib/validators';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';
import {
  AlertCircle,
  User,
  Trash2,
  LogOut,
  Shield,
  Calendar,
  Mail,
  Lock,
  CheckCircle2,
  Eye,
  EyeOff
} from 'lucide-react';

export default function ProfileScreen() {
  const navigate = useNavigate();
  const { user, logout } = useAuth();

  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [newPasswordConfirmation, setNewPasswordConfirmation] = useState('');
  const [showCurrent, setShowCurrent] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);

  const [passwordError, setPasswordError] = useState('');
  const [passwordSuccess, setPasswordSuccess] = useState('');
  const [loadingUpdate, setLoadingUpdate] = useState(false);
  const [loadingDelete, setLoadingDelete] = useState(false);

  if (!user) return null;

  const displayName = user.name;

  const handleUpdatePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setPasswordError('');
    setPasswordSuccess('');

    if (!isValidPassword(newPassword)) {
      setPasswordError('La nueva contraseña debe tener al menos 8 caracteres');
      return;
    }
    if (newPassword !== newPasswordConfirmation) {
      setPasswordError('Las contraseñas no coinciden');
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
      setPasswordSuccess('Contraseña actualizada correctamente');
      setCurrentPassword('');
      setNewPassword('');
      setNewPasswordConfirmation('');
    } catch (err: any) {
      setPasswordError(err.message || 'Error al actualizar contraseña');
    } finally {
      setLoadingUpdate(false);
    }
  };

  const handleDeleteAccount = async () => {
    if (!confirm('¿Estás seguro? Esta acción eliminará tu cuenta y todos tus datos permanentemente.')) return;
    setLoadingDelete(true);
    try {
      await apiFetch('/register', { method: 'DELETE' });
      logout();
      navigate('/', { replace: true });
    } catch (err: any) {
      setPasswordError(err.message || 'Error al eliminar cuenta');
      setLoadingDelete(false);
    }
  };

  const handleLogout = async () => {
    await logout();
    navigate('/', { replace: true });
  };

  return (
    <div className="min-h-[100dvh] bg-cream pt-20 pb-12 px-4">
      <div className="max-w-lg mx-auto space-y-6">
        {/* Profile Header */}
        <Card className="bg-white rounded-2xl border border-border-subtle shadow-sm overflow-hidden">
          <div className="bg-gradient-to-r from-terracotta/15 via-sage/15 to-olive/15 px-6 py-5">
            <div className="flex items-center gap-4">
              <div className="w-16 h-16 rounded-2xl bg-white/80 shadow-sm flex items-center justify-center shrink-0">
                <User className="w-8 h-8 text-terracotta" />
              </div>
              <div>
                <CardTitle className="font-display text-2xl text-espresso tracking-tight">
                  {displayName}
                </CardTitle>
                <CardDescription className="text-taupe text-sm flex items-center gap-1 mt-0.5">
                  <Mail className="w-3.5 h-3.5" />
                  {user.email ?? 'Sin correo'}
                </CardDescription>
              </div>
            </div>
          </div>
          <CardContent className="space-y-4 pt-4">
            <div className="grid grid-cols-2 gap-3 text-sm">
              <div className="bg-cream rounded-xl p-3 text-center">
                <Calendar className="w-4 h-4 text-taupe mx-auto mb-1.5" />
                <p className="text-taupe text-[11px] uppercase tracking-wider">Miembro desde</p>
                <p className="text-espresso font-semibold text-sm mt-0.5">
                  {user.created_at ? new Date(user.created_at).toLocaleDateString('es-MX', { month: 'short', year: 'numeric' }) : '-'}
                </p>
              </div>
              <div className="bg-cream rounded-xl p-3 text-center">
                <Shield className="w-4 h-4 text-taupe mx-auto mb-1.5" />
                <p className="text-taupe text-[11px] uppercase tracking-wider">Cuenta</p>
                <p className="text-espresso font-semibold text-sm mt-0.5">Activa</p>
              </div>
            </div>
            <Button
              onClick={handleLogout}
              variant="outline"
              className="w-full rounded-full border-border-subtle text-espresso hover:bg-cream transition-colors"
            >
              <LogOut className="w-4 h-4 mr-2" />
              Cerrar sesión
            </Button>
          </CardContent>
        </Card>

        {/* Change Password */}
        <Card className="bg-white rounded-2xl border border-border-subtle shadow-sm">
          <CardHeader className="pb-4">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-terracotta/10 flex items-center justify-center">
                <Lock className="w-4 h-4 text-terracotta" />
              </div>
              <div>
                <CardTitle className="font-display text-xl text-espresso tracking-tight">
                  Cambiar Contraseña
                </CardTitle>
                <CardDescription className="text-xs text-warm-gray">
                  Actualiza tu contraseña de seguridad
                </CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleUpdatePassword} className="space-y-4">
              {passwordError && (
                <div className="flex items-center gap-2 text-sm text-red-600 bg-red-50 px-4 py-3 rounded-xl">
                  <AlertCircle className="w-4 h-4 shrink-0" />
                  {passwordError}
                </div>
              )}
              {passwordSuccess && (
                <div className="flex items-center gap-2 text-sm text-green-700 bg-green-50 px-4 py-3 rounded-xl">
                  <CheckCircle2 className="w-4 h-4 shrink-0" />
                  {passwordSuccess}
                </div>
              )}

              <div className="space-y-2">
                <Label className="text-espresso text-sm font-medium">Contraseña actual</Label>
                <div className="relative">
                  <Input
                    type={showCurrent ? 'text' : 'password'}
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    required
                    placeholder="••••••••"
                    className="w-full px-4 py-3 pr-10 rounded-xl border border-border-subtle bg-white focus:border-terracotta"
                  />
                  <button
                    type="button"
                    onClick={() => setShowCurrent(!showCurrent)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-warm-gray hover:text-espresso"
                  >
                    {showCurrent ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <Label className="text-espresso text-sm font-medium">Nueva contraseña</Label>
                <div className="relative">
                  <Input
                    type={showNew ? 'text' : 'password'}
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    required
                    placeholder="Mínimo 8 caracteres"
                    className="w-full px-4 py-3 pr-10 rounded-xl border border-border-subtle bg-white focus:border-terracotta"
                  />
                  <button
                    type="button"
                    onClick={() => setShowNew(!showNew)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-warm-gray hover:text-espresso"
                  >
                    {showNew ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
                {newPassword && (
                  <div className="flex gap-1 mt-1">
                    {Array.from({ length: 4 }).map((_, i) => (
                      <div
                        key={i}
                        className={`h-1 flex-1 rounded-full transition-colors ${
                          i < (newPassword.length >= 12 ? 4 : newPassword.length >= 8 ? 3 : newPassword.length >= 6 ? 2 : 1)
                            ? i === 3 ? 'bg-green-500' : i === 2 ? 'bg-sage' : 'bg-terracotta'
                            : 'bg-border-subtle'
                        }`}
                      />
                    ))}
                  </div>
                )}
              </div>

              <div className="space-y-2">
                <Label className="text-espresso text-sm font-medium">Confirmar nueva contraseña</Label>
                <div className="relative">
                  <Input
                    type={showConfirm ? 'text' : 'password'}
                    value={newPasswordConfirmation}
                    onChange={(e) => setNewPasswordConfirmation(e.target.value)}
                    required
                    placeholder="••••••••"
                    className="w-full px-4 py-3 pr-10 rounded-xl border border-border-subtle bg-white focus:border-terracotta"
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirm(!showConfirm)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-warm-gray hover:text-espresso"
                  >
                    {showConfirm ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
                {newPasswordConfirmation && newPassword === newPasswordConfirmation && (
                  <p className="text-xs text-green-600 flex items-center gap-1">
                    <CheckCircle2 className="w-3 h-3" /> Las contraseñas coinciden
                  </p>
                )}
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

        {/* Delete Account */}
        <div className="pb-4">
          <Button
            onClick={handleDeleteAccount}
            disabled={loadingDelete}
            variant="outline"
            className="w-full rounded-full border-red-200 text-red-600 hover:bg-red-50 hover:text-red-700 transition-colors"
          >
            <Trash2 className="w-4 h-4 mr-2" />
            {loadingDelete ? 'Eliminando...' : 'Eliminar mi cuenta'}
          </Button>
          <p className="text-xs text-warm-gray text-center mt-2">
            Esta acción es irreversible y eliminará todos tus datos.
          </p>
        </div>
      </div>
    </div>
  );
}
