import React, { createContext, useContext, useState, useCallback } from 'react';

export interface PetProfile {
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
}

interface PetContextType {
  pet: PetProfile | null;
  setPet: (pet: PetProfile) => void;
  selectedKibbleId: string | null;
  setSelectedKibbleId: (id: string | null) => void;
  kibblePhotos: { tabla: string | null; ingredientes: string | null };
  setKibblePhotos: (photos: { tabla: string | null; ingredientes: string | null }) => void;
  clearAll: () => void;
}

const PetContext = createContext<PetContextType | null>(null);

export function PetProvider({ children }: { children: React.ReactNode }) {
  const [pet, setPetState] = useState<PetProfile | null>(null);
  const [selectedKibbleId, setSelectedKibbleId] = useState<string | null>(null);
  const [kibblePhotos, setKibblePhotos] = useState<{ tabla: string | null; ingredientes: string | null }>({ tabla: null, ingredientes: null });

  const setPet = useCallback((newPet: PetProfile) => {
    setPetState(newPet);
  }, []);

  const clearAll = useCallback(() => {
    setPetState(null);
    setSelectedKibbleId(null);
    setKibblePhotos({ tabla: null, ingredientes: null });
  }, []);

  return (
    <PetContext.Provider value={{ pet, setPet, selectedKibbleId, setSelectedKibbleId, kibblePhotos, setKibblePhotos, clearAll }}>
      {children}
    </PetContext.Provider>
  );
}

export function usePet() {
  const ctx = useContext(PetContext);
  if (!ctx) throw new Error('usePet must be used within PetProvider');
  return ctx;
}
