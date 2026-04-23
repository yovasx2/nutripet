import { Link } from 'react-router-dom';

const productLinks = [
  { label: 'Analizador de Croquetas', href: '/add-pet' },
  { label: 'Guía de Suplementos', href: '/supplements' },
  { label: 'Panel de Control', href: '/dashboard' },
  { label: 'Guía de Nutrición Canina', href: '/education' },
];

const resourceLinks = [
  { label: 'Datos PROFECO', href: 'https://paraperro.space/' },
  { label: 'AAFCO Oficial', href: 'https://www.aafco.org/' },
];

export default function Footer() {
  return (
    <footer className="bg-white border-t border-border-subtle">
      <div className="max-w-[1200px] mx-auto px-6 md:px-12 pt-12 pb-8">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="col-span-2 md:col-span-1">
            <Link to="/" className="flex items-center gap-2">
              <img src="/nutripet-icon.png" alt="NutriPet" className="h-7 w-auto" />
              <span className="font-display text-lg text-espresso">NutriPet</span>
            </Link>
            <p className="text-sm text-warm-gray mt-2 max-w-[200px]">
              Claridad nutricional para cada perro.
            </p>
          </div>

          {/* Product */}
          <div>
            <h4 className="text-sm font-semibold text-espresso mb-3">Producto</h4>
            <ul className="space-y-2">
              {productLinks.map((link) => (
                <li key={link.label}>
                  <Link to={link.href} className="text-sm text-taupe hover:text-espresso transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h4 className="text-sm font-semibold text-espresso mb-3">Recursos</h4>
            <ul className="space-y-2">
              {resourceLinks.map((link) => (
                <li key={link.label}>
                  <a href={link.href} target="_blank" rel="noopener noreferrer" className="text-sm text-taupe hover:text-espresso transition-colors">
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h4 className="text-sm font-semibold text-espresso mb-3">Contacto</h4>
            <ul className="space-y-2">
              <li>
                <a href="mailto:delirable@gmail.com" className="text-sm text-taupe hover:text-espresso transition-colors">
                  delirable@gmail.com
                </a>
              </li>
              <li>
                <a href="https://wa.me/+525510463075" target="_blank" rel="noopener noreferrer" className="text-sm text-taupe hover:text-espresso transition-colors">
                  +52 55 1046 3075
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-10 pt-6 border-t border-border-subtle">
          <p className="text-xs text-warm-gray text-center">
            &copy; 2025 NutriPet. Los datos de croquetas provienen del estudio PROFECO 2023 y paraperro.space. NutriPet no está afiliado a AAFCO.
          </p>
          <p className="text-xs text-warm-gray text-center mt-2">
            Esta herramienta es informativa. No está revisada por veterinarios y no sustituye el consejo veterinario profesional.
          </p>
        </div>
      </div>
    </footer>
  );
}
