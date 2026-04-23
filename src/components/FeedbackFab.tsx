import { useState, useEffect } from 'react';
import { MessageCircle, X, HelpCircle, Lightbulb, Bug, Camera } from 'lucide-react';

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
        {open ? <X className="w-5 h-5" /> : <MessageCircle className="w-5 h-5" />}
      </button>

      {showLabel && !open && (
        <div className="fixed bottom-[72px] right-4 md:bottom-[88px] md:right-8 z-[99] bg-[#25D366] text-white text-[10px] font-medium px-2.5 py-1 rounded-full shadow-sm animate-bounce">
          ¿Dudas?
        </div>
      )}
    </>
  );
}
