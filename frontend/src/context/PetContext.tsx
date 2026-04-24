import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import { apiFetch } from '../lib/api';
import { useAuth } from '../hooks/useAuth';

export interface PetProfile {
  id: string;
  name: string;
  breed: string;
  ageYears: number;
  ageMonths: number;
  weight: number;
  sex: 'male' | 'female';
  activityLevel: 'low' | 'moderate' | 'high';
  lifeStage: 'puppy' | 'adult' | 'senior';
  eccScore: number;
  reproductiveStatus: 'none' | 'gestating' | 'lactating';
  selectedKibbleId: string | null;
  kibblePhotos: { tabla: string | null; ingredientes: string | null };
}

interface PetContextType {
  pets: PetProfile[];
  activePetId: string | null;
  pet: PetProfile | null;
  isLoading: boolean;
  setPet: (data: Omit<PetProfile, 'id' | 'selectedKibbleId' | 'kibblePhotos'> & { id?: string }) => Promise<void>;
  setActivePetId: (id: string) => void;
  removePet: (id: string) => Promise<void>;
  selectedKibbleId: string | null;
  setSelectedKibbleId: (id: string | null) => Promise<void>;
  kibblePhotos: { tabla: string | null; ingredientes: string | null };
  setKibblePhotos: (photos: { tabla: string | null; ingredientes: string | null }) => void;
  clearAll: () => void;
}

const ACTIVE_KEY = 'nutripet-active-pet';
const KIBBLE_PHOTOS_KEY = 'nutripet-kibble-photos';

function loadActivePetId(pets: PetProfile[]): string | null {
  const saved = localStorage.getItem(ACTIVE_KEY);
  return pets.find(p => p.id === saved) ? saved : (pets[0]?.id ?? null);
}

function loadKibblePhotos(petId: string): { tabla: string | null; ingredientes: string | null } {
  try {
    const all = JSON.parse(localStorage.getItem(KIBBLE_PHOTOS_KEY) || '{}');
    return all[petId] ?? { tabla: null, ingredientes: null };
  } catch {
    return { tabla: null, ingredientes: null };
  }
}

function saveKibblePhotos(petId: string, photos: { tabla: string | null; ingredientes: string | null }) {
  try {
    const all = JSON.parse(localStorage.getItem(KIBBLE_PHOTOS_KEY) || '{}');
    all[petId] = photos;
    localStorage.setItem(KIBBLE_PHOTOS_KEY, JSON.stringify(all));
  } catch { /* ignore */ }
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function petFromApi(p: any): PetProfile {
  return {
    id: String(p.id),
    name: p.name,
    breed: p.breed,
    sex: p.sex,
    ageYears: p.age_years,
    ageMonths: p.age_months,
    weight: parseFloat(p.weight),
    activityLevel: p.activity_level,
    lifeStage: p.life_stage,
    eccScore: p.ecc_score,
    reproductiveStatus: p.reproductive_status,
    selectedKibbleId: p.selected_kibble_id ?? null,
    kibblePhotos: loadKibblePhotos(String(p.id)),
  };
}

function petToApiPayload(data: Omit<PetProfile, 'id' | 'selectedKibbleId' | 'kibblePhotos'>) {
  return {
    name: data.name,
    breed: data.breed,
    sex: data.sex,
    age_years: data.ageYears,
    age_months: data.ageMonths,
    weight: data.weight,
    activity_level: data.activityLevel,
    life_stage: data.lifeStage,
    ecc_score: data.eccScore,
    reproductive_status: data.reproductiveStatus,
  };
}

const PetContext = createContext<PetContextType | null>(null);

export function PetProvider({ children }: { children: React.ReactNode }) {
  const { user, isLoading: authLoading } = useAuth();
  const [pets, setPetsState] = useState<PetProfile[]>([]);
  const [activePetId, setActivePetIdState] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Sync pets from API whenever auth state resolves
  useEffect(() => {
    if (authLoading) return;

    if (!user) {
      setPetsState([]);
      setActivePetIdState(null);
      setIsLoading(false);
      return;
    }

    setIsLoading(true);
    apiFetch('/pets')
      .then((data: unknown[]) => {
        const mapped = (data as any[]).map(petFromApi);
        setPetsState(mapped);
        setActivePetIdState(loadActivePetId(mapped));
      })
      .catch(() => {
        setPetsState([]);
      })
      .finally(() => setIsLoading(false));
  }, [user, authLoading]);

  const pet = pets.find(p => p.id === activePetId) ?? null;

  const setActivePetId = useCallback((id: string) => {
    localStorage.setItem(ACTIVE_KEY, id);
    setActivePetIdState(id);
  }, []);

  const setPet = useCallback(async (incoming: Omit<PetProfile, 'id' | 'selectedKibbleId' | 'kibblePhotos'> & { id?: string }) => {
    const payload = petToApiPayload(incoming);
    let saved: PetProfile;

    if (incoming.id) {
      const res = await apiFetch(`/pets/${incoming.id}`, {
        method: 'PATCH',
        body: JSON.stringify({ pet: payload }),
      });
      saved = petFromApi(res);
      setPetsState(prev => prev.map(p => p.id === saved.id ? { ...saved, kibblePhotos: p.kibblePhotos } : p));
    } else {
      const res = await apiFetch('/pets', {
        method: 'POST',
        body: JSON.stringify({ pet: payload }),
      });
      saved = petFromApi(res);
      setPetsState(prev => [...prev, saved]);
      localStorage.setItem(ACTIVE_KEY, saved.id);
      setActivePetIdState(saved.id);
    }
  }, []);

  const removePet = useCallback(async (id: string) => {
    await apiFetch(`/pets/${id}`, { method: 'DELETE' });
    setPetsState(prev => {
      const next = prev.filter(p => p.id !== id);
      setActivePetIdState(curr => {
        if (curr !== id) return curr;
        const newActive = next[0]?.id ?? null;
        if (newActive) localStorage.setItem(ACTIVE_KEY, newActive);
        else localStorage.removeItem(ACTIVE_KEY);
        return newActive;
      });
      return next;
    });
  }, []);

  const selectedKibbleId = pet?.selectedKibbleId ?? null;

  const setSelectedKibbleId = useCallback(async (id: string | null) => {
    const currentId = localStorage.getItem(ACTIVE_KEY);
    if (!currentId) return;
    await apiFetch(`/pets/${currentId}`, {
      method: 'PATCH',
      body: JSON.stringify({ pet: { selected_kibble_id: id } }),
    });
    setPetsState(prev => prev.map(p => p.id === currentId ? { ...p, selectedKibbleId: id } : p));
  }, []);

  const kibblePhotos = pet?.kibblePhotos ?? { tabla: null, ingredientes: null };

  const setKibblePhotos = useCallback((photos: { tabla: string | null; ingredientes: string | null }) => {
    const currentId = localStorage.getItem(ACTIVE_KEY);
    if (!currentId) return;
    saveKibblePhotos(currentId, photos);
    setPetsState(prev => prev.map(p => p.id === currentId ? { ...p, kibblePhotos: photos } : p));
  }, []);

  const clearAll = useCallback(() => {
    localStorage.removeItem(ACTIVE_KEY);
    setPetsState([]);
    setActivePetIdState(null);
  }, []);

  return (
    <PetContext.Provider value={{
      pets, activePetId, pet, isLoading,
      setPet, setActivePetId, removePet,
      selectedKibbleId, setSelectedKibbleId,
      kibblePhotos, setKibblePhotos,
      clearAll,
    }}>
      {children}
    </PetContext.Provider>
  );
}

export function usePet() {
  const ctx = useContext(PetContext);
  if (!ctx) throw new Error('usePet must be used within PetProvider');
  return ctx;
}
