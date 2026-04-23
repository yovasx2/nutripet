import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

export default function ScrollToTop() {
  const { pathname, search } = useLocation();

  useEffect(() => {
    // Check for section query param (e.g. ?s=sources)
    const params = new URLSearchParams(search);
    const section = params.get('s');

    if (section) {
      const el = document.getElementById(section);
      if (el) {
        setTimeout(() => el.scrollIntoView({ behavior: 'smooth', block: 'start' }), 150);
        return;
      }
    }

    // Default: scroll to top
    window.scrollTo(0, 0);
  }, [pathname, search]);

  return null;
}
