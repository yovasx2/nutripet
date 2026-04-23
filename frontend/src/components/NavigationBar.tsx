import { useState, useEffect } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { usePet } from '../context/PetContext';
import { useAuth } from '../hooks/useAuth';
import { Menu, X, User } from 'lucide-react';

const navLinks = [
  { label: 'Cómo Funciona', href: '/#como-funciona' },
  { label: 'Ciencia', href: '/#ciencia' },
];

export default function NavigationBar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();
  const { pet } = usePet();
  const { user, logout } = useAuth();

  const isLanding = location.pathname === '/';
  const isAuthPage = location.pathname === '/login' || location.pathname === '/register';

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 100);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  const handleNavClick = (href: string) => {
    setMobileOpen(false);
    if (isLanding) {
      const id = href.replace('/#', '');
      const el = document.getElementById(id);
      if (el) el.scrollIntoView({ behavior: 'smooth' });
    } else {
      navigate('/');
      setTimeout(() => {
        const id = href.replace('/#', '');
        const el = document.getElementById(id);
        if (el) el.scrollIntoView({ behavior: 'smooth' });
      }, 300);
    }
  };

  const handleLogout = async () => {
    setMobileOpen(false);
    await logout();
    navigate('/');
  };

  return (
    <nav
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled ? 'bg-white/95 backdrop-blur-[24px] shadow-sm' : 'bg-white/80 backdrop-blur-[16px]'
      }`}
      style={{ borderBottom: '1px solid #e8e5de' }}
    >
      <div className="max-w-[1200px] mx-auto flex items-center justify-between h-16 px-6 md:px-12">
        <Link to="/" className="flex items-center gap-2 group">
          <img src="/nutripet-icon.png" alt="NutriPet" className="h-9 w-auto" />
        </Link>

        {isLanding && (
          <div className="hidden md:flex items-center gap-8">
            {navLinks.map((link) => (
              <button key={link.label} onClick={() => handleNavClick(link.href)}
                className="relative text-sm text-taupe hover:text-espresso transition-colors duration-300 tracking-[0.05em] uppercase font-medium group">
                {link.label}
                <span className="absolute -bottom-1 left-0 w-0 h-0.5 bg-terracotta transition-all duration-300 group-hover:w-full" />
              </button>
            ))}
          </div>
        )}

        {!isLanding && !isAuthPage && (
          <div className="hidden md:flex items-center gap-6">
            <Link to="/dashboard" className="text-sm text-taupe hover:text-espresso transition-colors font-medium">Panel</Link>
            <Link to="/plan" className="text-sm text-taupe hover:text-espresso transition-colors font-medium">Plan</Link>
            <Link to="/supplements" className="text-sm text-taupe hover:text-espresso transition-colors font-medium">Suplementos</Link>
          </div>
        )}

        <div className="hidden md:flex items-center gap-3">
          {user ? (
            <>
              <Link
                to="/profile"
                className="flex items-center gap-2 text-sm text-taupe hover:text-espresso transition-colors font-medium px-3 py-2 rounded-full hover:bg-cream"
              >
                <User className="w-4 h-4" />
                {user.email.split('@')[0]}
              </Link>
              {pet ? (
                <Link to="/dashboard" className="bg-terracotta text-white text-sm font-medium px-5 py-2 rounded-full hover:bg-terracotta-dark hover:shadow-glow transition-all duration-300 hover:scale-[1.03]">
                  Perfil de {pet.name}
                </Link>
              ) : (
                <Link to="/add-pet" className="bg-terracotta text-white text-sm font-medium px-5 py-2 rounded-full hover:bg-terracotta-dark hover:shadow-glow transition-all duration-300 hover:scale-[1.03]">
                  Analizar Croquetas
                </Link>
              )}
            </>
          ) : (
            <>
              <Link to="/login" className="text-sm text-taupe hover:text-espresso transition-colors font-medium px-3 py-2">
                Iniciar Sesión
              </Link>
              <Link to="/register" className="bg-terracotta text-white text-sm font-medium px-5 py-2 rounded-full hover:bg-terracotta-dark hover:shadow-glow transition-all duration-300 hover:scale-[1.03]">
                Registrarse
              </Link>
            </>
          )}
        </div>

        <button className="md:hidden p-2" onClick={() => setMobileOpen(!mobileOpen)}>
          {mobileOpen ? <X className="w-5 h-5 text-espresso" /> : <Menu className="w-5 h-5 text-espresso" />}
        </button>
      </div>

      {mobileOpen && (
        <div className="md:hidden bg-white/95 backdrop-blur-[24px] border-t border-border-subtle px-6 py-4 space-y-3">
          {isLanding && navLinks.map((link) => (
            <button key={link.label} onClick={() => handleNavClick(link.href)}
              className="block w-full text-left text-sm text-taupe hover:text-espresso transition-colors tracking-[0.05em] uppercase font-medium py-2">
              {link.label}
            </button>
          ))}
          {!isLanding && !isAuthPage && (
            <>
              <Link to="/dashboard" onClick={() => setMobileOpen(false)} className="block text-sm text-taupe hover:text-espresso py-2">Panel</Link>
              <Link to="/plan" onClick={() => setMobileOpen(false)} className="block text-sm text-taupe hover:text-espresso py-2">Plan</Link>
              <Link to="/supplements" onClick={() => setMobileOpen(false)} className="block text-sm text-taupe hover:text-espresso py-2">Suplementos</Link>
            </>
          )}
          {user ? (
            <>
              <Link to="/profile" onClick={() => setMobileOpen(false)} className="block text-sm text-taupe hover:text-espresso py-2">Mi Perfil</Link>
              <button onClick={handleLogout} className="block w-full text-left text-sm text-red-600 py-2">Cerrar sesión</button>
              <Link to={pet ? '/dashboard' : '/add-pet'} onClick={() => setMobileOpen(false)}
                className="block text-center bg-terracotta text-white text-sm font-medium px-5 py-2.5 rounded-full mt-2">
                {pet ? `Perfil de ${pet.name}` : 'Analizar Croquetas'}
              </Link>
            </>
          ) : (
            <>
              <Link to="/login" onClick={() => setMobileOpen(false)} className="block text-sm text-taupe hover:text-espresso py-2">Iniciar Sesión</Link>
              <Link to="/register" onClick={() => setMobileOpen(false)}
                className="block text-center bg-terracotta text-white text-sm font-medium px-5 py-2.5 rounded-full mt-2">
                Registrarse
              </Link>
            </>
          )}
        </div>
      )}
    </nav>
  );
}
