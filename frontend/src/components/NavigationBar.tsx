import { useState, useEffect, useRef } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { usePet } from '../context/PetContext';
import { useAuth } from '../hooks/useAuth';
import { Menu, X, User, LogOut, ChevronDown } from 'lucide-react';

const landingLinks = [
  { label: 'Cómo Funciona', href: 'como-funciona' },
  { label: 'Ciencia', href: 'ciencia' },
];

const appLinks = [
  { label: 'Panel', to: '/dashboard' },
  { label: 'Plan', to: '/plan' },
  { label: 'Suplementos', to: '/supplements' },
];

export default function NavigationBar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const userMenuRef = useRef<HTMLDivElement>(null);

  const location = useLocation();
  const navigate = useNavigate();
  const { pet } = usePet();
  const { user, logout, isLoading } = useAuth();

  const isLanding = location.pathname === '/';
  const isAuthPage = ['/login', '/register', '/forgot-password', '/reset-password'].includes(location.pathname);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 100);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  // Close user dropdown when clicking outside
  useEffect(() => {
    if (!userMenuOpen) return;
    const handler = (e: MouseEvent) => {
      if (userMenuRef.current && !userMenuRef.current.contains(e.target as Node)) {
        setUserMenuOpen(false);
      }
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, [userMenuOpen]);

  // Close mobile menu on route change
  useEffect(() => { setMobileOpen(false); }, [location.pathname]);

  const scrollToSection = (id: string) => {
    setMobileOpen(false);
    if (isLanding) {
      document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });
    } else {
      navigate('/');
      setTimeout(() => document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' }), 300);
    }
  };

  const handleLogout = async () => {
    setMobileOpen(false);
    setUserMenuOpen(false);
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

        {/* Logo */}
        <Link to="/" className="flex items-center gap-2.5 shrink-0">
          <img src="/logo.png" alt="NutriPet" className="h-[51px] w-auto" />
          <span className="font-display text-xl text-espresso">NutriPet</span>
        </Link>

        {/* Desktop center links */}
        {!isAuthPage && !isLoading && (
          <div className="hidden md:flex items-center gap-8">
            {isLanding
              ? landingLinks.map(link => (
                  <button key={link.href} onClick={() => scrollToSection(link.href)}
                    className="relative text-sm text-taupe hover:text-espresso transition-colors tracking-[0.05em] uppercase font-medium group">
                    {link.label}
                    <span className="absolute -bottom-1 left-0 w-0 h-0.5 bg-terracotta transition-all duration-300 group-hover:w-full" />
                  </button>
                ))
              : user
                ? appLinks.map(link => (
                    <Link key={link.to} to={link.to}
                      className="relative text-sm text-taupe hover:text-espresso transition-colors duration-300 tracking-[0.05em] uppercase font-medium group">
                      {link.label}
                      <span className="absolute -bottom-1 left-0 w-0 h-0.5 bg-terracotta transition-all duration-300 group-hover:w-full" />
                    </Link>
                  ))
                : null
            }
          </div>
        )}

        {/* Desktop right side */}
        {!isAuthPage && !isLoading && (
          <div className="hidden md:flex items-center gap-3">
            {user ? (
              <>
                {/* CTA: only on landing (go to panel) or when no pet yet */}
                {isLanding ? (
                  <Link to="/dashboard"
                    className="bg-terracotta text-white text-sm font-medium px-5 py-2 rounded-full hover:bg-terracotta-dark hover:shadow-glow transition-all duration-300 hover:scale-[1.03]">
                    Mi Panel
                  </Link>
                ) : !pet ? (
                  <Link to="/add-pet"
                    className="bg-terracotta text-white text-sm font-medium px-5 py-2 rounded-full hover:bg-terracotta-dark hover:shadow-glow transition-all duration-300 hover:scale-[1.03]">
                    Agregar Mascota
                  </Link>
                ) : null}

                {/* User dropdown */}
                <div ref={userMenuRef} className="relative">
                  <button
                    onClick={() => setUserMenuOpen(o => !o)}
                    className="flex items-center gap-2 text-sm text-taupe hover:text-espresso font-medium px-3 py-2 rounded-full hover:bg-cream transition-colors"
                  >
                    <User className="w-4 h-4" />
                    {user.name}
                    <ChevronDown className={`w-3.5 h-3.5 transition-transform duration-200 ${userMenuOpen ? 'rotate-180' : ''}`} />
                  </button>
                  {userMenuOpen && (
                    <div className="absolute right-0 top-full mt-2 w-48 bg-white rounded-xl border border-border-subtle shadow-md py-1 z-50">
                      <Link to="/profile" onClick={() => setUserMenuOpen(false)}
                        className="flex items-center gap-2.5 px-4 py-2.5 text-sm text-espresso hover:bg-cream transition-colors">
                        <User className="w-4 h-4 text-taupe" />
                        Mi Perfil
                      </Link>
                      <div className="border-t border-border-subtle mx-3 my-1" />
                      <button onClick={handleLogout}
                        className="w-full flex items-center gap-2.5 px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 transition-colors rounded-b-xl">
                        <LogOut className="w-4 h-4" />
                        Cerrar sesión
                      </button>
                    </div>
                  )}
                </div>
              </>
            ) : (
              <>
                <Link to="/login"
                  className="text-sm text-taupe hover:text-espresso transition-colors font-medium px-3 py-2">
                  Iniciar Sesión
                </Link>
                <Link to="/register"
                  className="bg-terracotta text-white text-sm font-medium px-5 py-2 rounded-full hover:bg-terracotta-dark hover:shadow-glow transition-all duration-300 hover:scale-[1.03]">
                  Registrarse
                </Link>
              </>
            )}
          </div>
        )}

        {/* Mobile hamburger button */}
        {!isAuthPage && (
          <button className="md:hidden p-2" onClick={() => setMobileOpen(o => !o)}>
            {mobileOpen ? <X className="w-5 h-5 text-espresso" /> : <Menu className="w-5 h-5 text-espresso" />}
          </button>
        )}
      </div>

      {/* Mobile menu */}
      {mobileOpen && !isAuthPage && !isLoading && (
        <div className="md:hidden bg-white/98 backdrop-blur-[24px] border-t border-border-subtle px-6 py-4 space-y-1">
          {/* Context nav links */}
          {isLanding
            ? landingLinks.map(link => (
                <button key={link.href} onClick={() => scrollToSection(link.href)}
                  className="block w-full text-left text-sm text-taupe hover:text-espresso uppercase tracking-wide font-medium py-2.5">
                  {link.label}
                </button>
              ))
            : user
              ? appLinks.map(link => (
                  <Link key={link.to} to={link.to}
                    className="block text-sm text-taupe hover:text-espresso font-medium py-2.5">
                    {link.label}
                  </Link>
                ))
              : null
          }

          {user ? (
            <>
              <div className="border-t border-border-subtle pt-3 mt-1 space-y-1">
                {/* CTA */}
                {!pet && !isLanding && (
                  <Link to="/add-pet"
                    className="block text-center bg-terracotta text-white text-sm font-medium px-5 py-2.5 rounded-full mb-3">
                    Agregar Mascota
                  </Link>
                )}
                {isLanding && (
                  <Link to="/dashboard"
                    className="block text-center bg-terracotta text-white text-sm font-medium px-5 py-2.5 rounded-full mb-3">
                    Mi Panel
                  </Link>
                )}
                {/* User section */}
                <div className="text-xs text-warm-gray uppercase tracking-wider px-1 pb-1">{user.name}</div>
                <Link to="/profile"
                  className="flex items-center gap-2.5 text-sm text-espresso py-2.5">
                  <User className="w-4 h-4 text-taupe" /> Mi Perfil
                </Link>
                <button onClick={handleLogout}
                  className="flex items-center gap-2.5 w-full text-left text-sm text-red-600 py-2.5">
                  <LogOut className="w-4 h-4" /> Cerrar sesión
                </button>
              </div>
            </>
          ) : (
            <div className="border-t border-border-subtle pt-3 mt-1 space-y-1">
              <Link to="/login"
                className="block text-sm text-taupe hover:text-espresso font-medium py-2.5">
                Iniciar Sesión
              </Link>
              <Link to="/register"
                className="block text-center bg-terracotta text-white text-sm font-medium px-5 py-2.5 rounded-full mt-2">
                Registrarse
              </Link>
            </div>
          )}
        </div>
      )}
    </nav>
  );
}
