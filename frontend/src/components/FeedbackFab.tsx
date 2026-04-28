import { useState, useEffect } from 'react';
import { X, HelpCircle, Lightbulb, Bug, Camera } from 'lucide-react';

const WHATSAPP_NUMBER = '+525510463075';
const WHATSAPP_BASE = `https://wa.me/${WHATSAPP_NUMBER}`;

export default function FeedbackFab() {
  const [open, setOpen] = useState(false);
  const [showLabel, setShowLabel] = useState(true);

  useEffect(() => {
    const dismissed = localStorage.getItem('nutripet-fab-dismissed');
    if (dismissed) setShowLabel(false);
  }, []);

  const handleOpen = () => {
    setOpen(!open);
    setShowLabel(false);
    localStorage.setItem('nutripet-fab-dismissed', '1');
  };

  const options = [
    {
      icon: <Camera className="w-4 h-4" />,
      label: 'Análisis de marca',
      desc: 'Tu croqueta no está en la base de datos',
      href: `${WHATSAPP_BASE}?text=Hola,%20quiero%20un%20análisis%20personalizado%20de%20mi%20croqueta.`,
    },
    {
      icon: <HelpCircle className="w-4 h-4" />,
      label: 'Dudas',
      desc: 'Cualquier pregunta sobre nutrición canina',
      href: `${WHATSAPP_BASE}?text=Hola,%20tengo%20una%20duda:`,
    },
    {
      icon: <Lightbulb className="w-4 h-4" />,
      label: 'Sugerencias',
      desc: 'Ideas para mejorar la app',
      href: `${WHATSAPP_BASE}?text=Hola,%20tengo%20una%20sugerencia%20para%20NutriPet:`,
    },
    {
      icon: <Bug className="w-4 h-4" />,
      label: 'Reportar problema',
      desc: 'Algo no funciona correctamente',
      href: `${WHATSAPP_BASE}?text=Hola,%20quiero%20reportar%20un%20problema%20en%20NutriPet:`,
    },
  ];

  return (
    <>
      {open && (
        <div
          className="fixed inset-0 z-[90] bg-black/20 backdrop-blur-[2px]"
          onClick={() => setOpen(false)}
        />
      )}

      {open && (
        <div className="fixed bottom-20 right-4 md:right-8 z-[95] bg-white rounded-2xl border border-border-subtle shadow-xl p-4 w-[280px]">
          <div className="flex items-center justify-between mb-3">
            <h4 className="text-sm font-semibold text-espresso">¿En qué podemos ayudarte?</h4>
            <button onClick={() => setOpen(false)} className="w-6 h-6 rounded-full bg-cream flex items-center justify-center hover:bg-border-subtle transition-colors">
              <X className="w-3 h-3 text-espresso" />
            </button>
          </div>
          <div className="space-y-2">
            {options.map((opt) => (
              <a
                key={opt.label}
                href={opt.href}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-3 p-2.5 rounded-xl hover:bg-cream transition-colors group"
              >
                <div className="w-8 h-8 rounded-lg bg-sage/15 flex items-center justify-center text-olive group-hover:bg-terracotta/10 group-hover:text-terracotta transition-colors">
                  {opt.icon}
                </div>
                <div>
                  <div className="text-sm font-medium text-espresso">{opt.label}</div>
                  <div className="text-[10px] text-warm-gray">{opt.desc}</div>
                </div>
              </a>
            ))}
          </div>
          <p className="text-[10px] text-warm-gray text-center mt-3 pt-2 border-t border-border-subtle">
            WhatsApp · Respuesta en menos de 12 horas
          </p>
        </div>
      )}

      <button
        onClick={handleOpen}
        className={`fixed bottom-4 right-4 md:bottom-8 md:right-8 z-[100] w-14 h-14 rounded-full shadow-lg flex items-center justify-center transition-all duration-300 hover:scale-110 ${
          open
            ? 'bg-espresso text-white'
            : 'bg-[#25D366] text-white hover:bg-[#128C7E]'
        }`}
        aria-label="Contacto y feedback"
      >
        {open ? (
          <X className="w-5 h-5" />
        ) : (
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="currentColor"
            className="w-5 h-5"
          >
            <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" />
          </svg>
        )}
      </button>

      {showLabel && !open && (
        <div className="fixed bottom-[72px] right-4 md:bottom-[88px] md:right-8 z-[99] bg-[#25D366] text-white text-[10px] font-medium px-2.5 py-1 rounded-full shadow-sm animate-bounce">
          ¿Dudas?
        </div>
      )}
    </>
  );
}
