import React, { createContext, useContext, useState, useCallback } from 'react';

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
  setPet: (data: Omit<PetProfile, 'id' | 'selectedKibbleId' | 'kibblePhotos'> & { id?: string }) => void;
  setActivePetId: (id: string) => void;
  removePet: (id: string) => void;
  selectedKibbleId: string | null;
  setSelectedKibbleId: (id: string | null) => void;
  kibblePhotos: { tabla: string | null; ingredientes: string | null };
  setKibblePhotos: (photos: { tabla: string | null; ingredientes: string | null }) => void;
  clearAll: () => void;
}

const STORAGE_KEY = 'nutripet-pets';
const ACTIVE_KEY = 'nutripet-active-pet';

function loadPets(): PetProfile[] {
  try { return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]'); }
  catch { return []; }
}

function loadActivePetId(pets: PetProfile[]): string | null {
  const saved = localStorage.getItem(ACTIVE_KEY);
  return pets.find(p => p.id === saved) ? saved : (pets[0]?.id ?? null);
}

function savePetsToStorage(pets: PetProfile[]) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(pets));
}

const PetContext = createContext<PetContextType | null>(null);

export function PetProvider({ children }: { children: React.ReactNode }) {
  const [pets, setPetsState] = useState<PetProfile[]>(() => loadPets());
  const [activePetId, setActivePetIdState] = useState<string | null>(() => loadActivePetId(loadPets()));

  const pet = pets.find(p => p.id === activePetId) ?? null;

  const setActivePetId = useCallback((id: string) => {
    localStorage.setItem(ACTIVE_KEY, id);
    setActivePetIdState(id);
  }, []);

  const setPet = useCallback((incoming: Omit<PetProfile, 'id' | 'selectedKibbleId' | 'kibblePhotos'> & { id?: string }) => {
    setPetsState(prev => {
      const existingIdx = incoming.id ? prev.findIndex(p => p.id === incoming.id) : -1;
      let next: PetProfile[];
      let resolvedId: string;

      if (existingIdx >= 0) {
        resolvedId = incoming.id!;
        next = prev.map(p =>
          p.id === resolvedId
            ? { ...p, ...incoming, id: resolvedId }
            : p
        );
      } else {
        resolvedId = crypto.randomUUID();
        const newPet: PetProfile = {
          ...incoming,
          id: resolvedId,
          selectedKibbleId: null,
          kibblePhotos: { tabla: null, ingredientes: null },
        };
        next = [...prev, newPet];
      }

      savePetsToStorage(next);
      localStorage.setItem(ACTIVE_KEY, resolvedId);
      setActivePetIdState(resolvedId);
      return next;
    });
  }, []);

  const removePet = useCallback((id: string) => {
    setPetsState(prev => {
      const next = prev.filter(p => p.id !== id);
      savePetsToStorage(next);
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

  const setSelectedKibbleId = useCallback((id: string | null) => {
    setPetsState(prev => {
      const curr = localStorage.getItem(ACTIVE_KEY);
      if (!curr) return prev;
      const next = prev.map(p => p.id === curr ? { ...p, selectedKibbleId: id } : p);
      savePetsToStorage(next);
      return next;
    });
  }, []);

  const kibblePhotos = pet?.kibblePhotos ?? { tabla: null, ingredientes: null };

  const setKibblePhotos = useCallback((photos: { tabla: string | null; ingredientes: string | null }) => {
    setPetsState(prev => {
      const curr = localStorage.getItem(ACTIVE_KEY);
      if (!curr) return prev;
      const next = prev.map(p => p.id === curr ? { ...p, kibblePhotos: photos } : p);
      savePetsToStorage(next);
      return next;
    });
  }, []);

  const clearAll = useCallback(() => {
    localStorage.removeItem(STORAGE_KEY);
    localStorage.removeItem(ACTIVE_KEY);
    setPetsState([]);
    setActivePetIdState(null);
  }, []);

  return (
    <PetContext.Provider value={{
      pets, activePetId, pet,
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
