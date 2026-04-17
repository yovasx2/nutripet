# db/seeds.rb — NutriPet MVP
# 100+ ingredients: proteins, vegetables, carbs, fats + toxic entries

puts "Seeding ingredients..."

ingredients = [
  # ─────────────────────────────────────────
  # PROTEINS — dog & cat safe
  # ─────────────────────────────────────────
  { name: "Pechuga de pollo cocida",       category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 165, protein_g: 31,  fat_g: 3.6,  carbs_g: 0,    moisture_g: 65, raw_safe: false },
  { name: "Muslo de pollo cocido",          category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 177, protein_g: 25,  fat_g: 8.2,  carbs_g: 0,    moisture_g: 63, raw_safe: false },
  { name: "Corazón de pollo",               category: "protein", species_safe: "both",  safety_status: "caution", energy_kcal: 153, protein_g: 20,  fat_g: 8.5,  carbs_g: 0.1,  moisture_g: 67, raw_safe: false, safety_notes: "Las aves crudas tienen la mayor tasa de contaminación por Salmonella y Campylobacter. Cocinar siempre. (WSAVA Raw Diet Guidelines)" },
  { name: "Hígado de pollo",                category: "protein", species_safe: "both",  safety_status: "caution", energy_kcal: 119, protein_g: 17,  fat_g: 4.8,  carbs_g: 0.7,  moisture_g: 76, raw_safe: false, safety_notes: "Alto riesgo de Salmonella en crudo. Máx. 5% de la dieta por vitamina A; en exceso causa hipervitaminosis A. Cocinar siempre." },
  { name: "Pechuga de pavo cocida",         category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 135, protein_g: 30,  fat_g: 1.0,  carbs_g: 0,    moisture_g: 68, raw_safe: false },
  { name: "Molida de pavo",                 category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 148, protein_g: 27,  fat_g: 4.0,  carbs_g: 0,    moisture_g: 65, raw_safe: false },
  { name: "Carne molida de res magra",      category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 152, protein_g: 26,  fat_g: 5.0,  carbs_g: 0,    moisture_g: 66, raw_safe: true  },
  { name: "Filete de res cocido",           category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 250, protein_g: 26,  fat_g: 15,   carbs_g: 0,    moisture_g: 57, raw_safe: false },
  { name: "Corazón de res",                 category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 112, protein_g: 17,  fat_g: 4.7,  carbs_g: 0.1,  moisture_g: 74, raw_safe: true  },
  { name: "Hígado de res",                  category: "protein", species_safe: "both",  safety_status: "caution", energy_kcal: 135, protein_g: 21,  fat_g: 3.8,  carbs_g: 3.9,  moisture_g: 70, raw_safe: true  },
  { name: "Riñón de res",                   category: "protein", species_safe: "both",  safety_status: "caution", energy_kcal: 99,  protein_g: 17,  fat_g: 3.1,  carbs_g: 0.3,  moisture_g: 77, raw_safe: true  },
  { name: "Lomo de cerdo cocido",           category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 187, protein_g: 29,  fat_g: 7.0,  carbs_g: 0,    moisture_g: 61, raw_safe: false },
  { name: "Costilla de cerdo cocida",       category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 330, protein_g: 22,  fat_g: 27,   carbs_g: 0,    moisture_g: 50, raw_safe: false },
  { name: "Salmón al vapor",                category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 208, protein_g: 20,  fat_g: 13,   carbs_g: 0,    moisture_g: 64, raw_safe: false, safety_notes: "NUNCA servir crudo: el salmón del Pacífico crudo puede causar 'salmon poisoning disease' (Neorickettsia helminthoeca), potencialmente fatal. Cocinar siempre a temperatura interna ≥63°C." },
  { name: "Atún en agua escurrido",         category: "protein", species_safe: "both",  safety_status: "caution", energy_kcal: 116, protein_g: 26,  fat_g: 1.0,  carbs_g: 0,    moisture_g: 72, raw_safe: false },
  { name: "Sardinas en agua escurridas",    category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 208, protein_g: 25,  fat_g: 11,   carbs_g: 0,    moisture_g: 60, raw_safe: false },
  { name: "Tilapia cocida",                 category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 128, protein_g: 26,  fat_g: 2.7,  carbs_g: 0,    moisture_g: 70, raw_safe: false },
  { name: "Bacalao cocido",                 category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 105, protein_g: 23,  fat_g: 0.9,  carbs_g: 0,    moisture_g: 76, raw_safe: false },
  { name: "Huevo entero cocido",            category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 155, protein_g: 13,  fat_g: 11,   carbs_g: 1.1,  moisture_g: 75, raw_safe: false },
  { name: "Clara de huevo cocida",          category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 52,  protein_g: 11,  fat_g: 0.2,  carbs_g: 0.7,  moisture_g: 87, raw_safe: false },
  { name: "Cordero magro cocido",           category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 258, protein_g: 26,  fat_g: 17,   carbs_g: 0,    moisture_g: 57, raw_safe: false },
  { name: "Conejo cocido",                  category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 173, protein_g: 33,  fat_g: 3.5,  carbs_g: 0,    moisture_g: 63, raw_safe: false },
  { name: "Pato cocido sin piel",           category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 201, protein_g: 23,  fat_g: 11,   carbs_g: 0,    moisture_g: 62, raw_safe: false },
  { name: "Ternera cocida",                 category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 196, protein_g: 26,  fat_g: 10,   carbs_g: 0,    moisture_g: 61, raw_safe: false },
  { name: "Pulmón de res",                  category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 99,  protein_g: 17,  fat_g: 2.8,  carbs_g: 0,    moisture_g: 78, raw_safe: true  },
  { name: "Molleja de pollo cocida",        category: "protein", species_safe: "both",  safety_status: "safe",    energy_kcal: 94,  protein_g: 18,  fat_g: 2.1,  carbs_g: 0,    moisture_g: 79, raw_safe: false },

  # ─────────────────────────────────────────
  # VEGETABLES
  # ─────────────────────────────────────────
  { name: "Zanahoria",                      category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 35,  protein_g: 0.8,  fat_g: 0.2,  carbs_g: 8.2,  moisture_g: 90, raw_safe: true  },
  { name: "Calabaza de Castilla cocida",    category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 26,  protein_g: 1.0,  fat_g: 0.1,  carbs_g: 7.0,  moisture_g: 92, raw_safe: false },
  { name: "Calabacita",                     category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 17,  protein_g: 1.2,  fat_g: 0.3,  carbs_g: 3.1,  moisture_g: 95, raw_safe: true  },
  { name: "Espinaca cocida",                category: "vegetable", species_safe: "both",  safety_status: "caution", energy_kcal: 23,  protein_g: 2.9,  fat_g: 0.4,  carbs_g: 3.6,  moisture_g: 91, raw_safe: false },
  { name: "Brócoli al vapor",               category: "vegetable", species_safe: "both",  safety_status: "caution", energy_kcal: 35,  protein_g: 2.4,  fat_g: 0.4,  carbs_g: 7.2,  moisture_g: 87, raw_safe: false },
  { name: "Coliflor al vapor",              category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 25,  protein_g: 1.9,  fat_g: 0.3,  carbs_g: 5.0,  moisture_g: 92, raw_safe: false },
  { name: "Chayote cocido",                 category: "vegetable", species_safe: "dog",   safety_status: "safe",    energy_kcal: 19,  protein_g: 0.8,  fat_g: 0.1,  carbs_g: 4.5,  moisture_g: 94, raw_safe: false },
  { name: "Nopal cocido",                   category: "vegetable", species_safe: "dog",   safety_status: "safe",    energy_kcal: 22,  protein_g: 1.5,  fat_g: 0.0,  carbs_g: 5.1,  moisture_g: 92, raw_safe: false },
  { name: "Ejotes al vapor",                category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 31,  protein_g: 1.8,  fat_g: 0.1,  carbs_g: 7.0,  moisture_g: 91, raw_safe: false },
  { name: "Chícharos cocidos",              category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 84,  protein_g: 5.4,  fat_g: 0.4,  carbs_g: 15,   moisture_g: 79, raw_safe: false },
  { name: "Jícama",                         category: "vegetable", species_safe: "dog",   safety_status: "safe",    energy_kcal: 38,  protein_g: 0.7,  fat_g: 0.1,  carbs_g: 9.0,  moisture_g: 90, raw_safe: true  },
  { name: "Betabel cocido",                 category: "vegetable", species_safe: "dog",   safety_status: "caution", energy_kcal: 44,  protein_g: 1.7,  fat_g: 0.2,  carbs_g: 10,   moisture_g: 87, raw_safe: false },
  { name: "Pepino",                         category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 15,  protein_g: 0.7,  fat_g: 0.1,  carbs_g: 3.6,  moisture_g: 96, raw_safe: true  },
  { name: "Apio",                           category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 16,  protein_g: 0.7,  fat_g: 0.2,  carbs_g: 3.0,  moisture_g: 95, raw_safe: true  },
  { name: "Espárrago al vapor",             category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 20,  protein_g: 2.2,  fat_g: 0.1,  carbs_g: 3.9,  moisture_g: 93, raw_safe: false },
  { name: "Kale al vapor",                  category: "vegetable", species_safe: "dog",   safety_status: "caution", energy_kcal: 49,  protein_g: 4.3,  fat_g: 0.9,  carbs_g: 8.8,  moisture_g: 84, raw_safe: false },
  { name: "Repollo cocido",                 category: "vegetable", species_safe: "dog",   safety_status: "caution", energy_kcal: 25,  protein_g: 1.1,  fat_g: 0.1,  carbs_g: 5.8,  moisture_g: 92, raw_safe: false },
  { name: "Lechuga romana",                 category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 17,  protein_g: 1.2,  fat_g: 0.3,  carbs_g: 3.3,  moisture_g: 95, raw_safe: true  },
  { name: "Pimiento rojo",                  category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 31,  protein_g: 1.0,  fat_g: 0.3,  carbs_g: 7.5,  moisture_g: 92, raw_safe: true  },
  { name: "Jitomate",                       category: "vegetable", species_safe: "dog",   safety_status: "caution", energy_kcal: 18,  protein_g: 0.9,  fat_g: 0.2,  carbs_g: 3.9,  moisture_g: 95, raw_safe: true  },
  { name: "Berros",                         category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 11,  protein_g: 2.3,  fat_g: 0.1,  carbs_g: 1.3,  moisture_g: 95, raw_safe: true  },
  { name: "Arándano azul",                  category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 57,  protein_g: 0.7,  fat_g: 0.3,  carbs_g: 14,   moisture_g: 84, raw_safe: true  },
  { name: "Manzana sin semillas",           category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 52,  protein_g: 0.3,  fat_g: 0.2,  carbs_g: 14,   moisture_g: 86, raw_safe: true  },
  { name: "Sandía sin semillas",            category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 30,  protein_g: 0.6,  fat_g: 0.2,  carbs_g: 7.5,  moisture_g: 92, raw_safe: true  },
  { name: "Papaya madura",                  category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 43,  protein_g: 0.5,  fat_g: 0.3,  carbs_g: 11,   moisture_g: 88, raw_safe: true  },
  { name: "Mango sin hueso",                category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 60,  protein_g: 0.8,  fat_g: 0.4,  carbs_g: 15,   moisture_g: 83, raw_safe: true  },
  { name: "Pera sin semillas",              category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 57,  protein_g: 0.4,  fat_g: 0.1,  carbs_g: 15,   moisture_g: 84, raw_safe: true  },
  { name: "Fresas",                         category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 32,  protein_g: 0.7,  fat_g: 0.3,  carbs_g: 7.7,  moisture_g: 91, raw_safe: true  },
  { name: "Frambuesas",                     category: "vegetable", species_safe: "both",  safety_status: "safe",    energy_kcal: 52,  protein_g: 1.2,  fat_g: 0.7,  carbs_g: 12,   moisture_g: 86, raw_safe: true  },
  { name: "Plátano",                        category: "vegetable", species_safe: "both",  safety_status: "caution", energy_kcal: 89,  protein_g: 1.1,  fat_g: 0.3,  carbs_g: 23,   moisture_g: 75, raw_safe: true  },
  { name: "Amaranto cocido",                category: "vegetable", species_safe: "dog",   safety_status: "safe",    energy_kcal: 102, protein_g: 3.8,  fat_g: 1.6,  carbs_g: 19,   moisture_g: 75, raw_safe: false },
  { name: "Brotes de alfalfa",              category: "vegetable", species_safe: "dog",   safety_status: "safe",    energy_kcal: 23,  protein_g: 4.0,  fat_g: 0.7,  carbs_g: 2.1,  moisture_g: 91, raw_safe: true  },
  { name: "Remolacha de hoja cocida",       category: "vegetable", species_safe: "dog",   safety_status: "safe",    energy_kcal: 19,  protein_g: 1.9,  fat_g: 0.1,  carbs_g: 3.7,  moisture_g: 91, raw_safe: false },

  # ─────────────────────────────────────────
  # CARBOHYDRATES
  # ─────────────────────────────────────────
  { name: "Arroz blanco cocido",            category: "carb", species_safe: "both",  safety_status: "safe",    energy_kcal: 130, protein_g: 2.7,  fat_g: 0.3,  carbs_g: 28,   moisture_g: 68, raw_safe: false },
  { name: "Arroz integral cocido",          category: "carb", species_safe: "both",  safety_status: "safe",    energy_kcal: 111, protein_g: 2.6,  fat_g: 0.9,  carbs_g: 23,   moisture_g: 73, raw_safe: false },
  { name: "Avena cocida",                   category: "carb", species_safe: "both",  safety_status: "safe",    energy_kcal: 71,  protein_g: 2.5,  fat_g: 1.5,  carbs_g: 12,   moisture_g: 84, raw_safe: false },
  { name: "Camote cocido",                  category: "carb", species_safe: "both",  safety_status: "safe",    energy_kcal: 86,  protein_g: 1.6,  fat_g: 0.1,  carbs_g: 20,   moisture_g: 77, raw_safe: false },
  { name: "Papa cocida sin piel",           category: "carb", species_safe: "both",  safety_status: "safe",    energy_kcal: 87,  protein_g: 1.9,  fat_g: 0.1,  carbs_g: 20,   moisture_g: 77, raw_safe: false },
  { name: "Quinoa cocida",                  category: "carb", species_safe: "both",  safety_status: "safe",    energy_kcal: 120, protein_g: 4.4,  fat_g: 1.9,  carbs_g: 21,   moisture_g: 72, raw_safe: false },
  { name: "Cebada perlada cocida",          category: "carb", species_safe: "dog",   safety_status: "safe",    energy_kcal: 123, protein_g: 2.3,  fat_g: 0.4,  carbs_g: 28,   moisture_g: 69, raw_safe: false },
  { name: "Mijo cocido",                    category: "carb", species_safe: "dog",   safety_status: "safe",    energy_kcal: 119, protein_g: 3.5,  fat_g: 1.0,  carbs_g: 23,   moisture_g: 71, raw_safe: false },
  { name: "Yuca cocida",                    category: "carb", species_safe: "dog",   safety_status: "safe",    energy_kcal: 160, protein_g: 1.4,  fat_g: 0.3,  carbs_g: 38,   moisture_g: 60, raw_safe: false },
  { name: "Maíz cocido",                    category: "carb", species_safe: "dog",   safety_status: "safe",    energy_kcal: 96,  protein_g: 3.4,  fat_g: 1.5,  carbs_g: 21,   moisture_g: 73, raw_safe: false },
  { name: "Trigo sarraceno cocido",         category: "carb", species_safe: "dog",   safety_status: "safe",    energy_kcal: 92,  protein_g: 3.4,  fat_g: 0.6,  carbs_g: 20,   moisture_g: 75, raw_safe: false },
  { name: "Plátano macho cocido",           category: "carb", species_safe: "dog",   safety_status: "safe",    energy_kcal: 122, protein_g: 1.3,  fat_g: 0.4,  carbs_g: 32,   moisture_g: 65, raw_safe: false },
  { name: "Lentejas cocidas",               category: "carb", species_safe: "both",  safety_status: "safe",    energy_kcal: 116, protein_g: 9.0,  fat_g: 0.4,  carbs_g: 20,   moisture_g: 70, raw_safe: false },
  { name: "Garbanzos cocidos",              category: "carb", species_safe: "both",  safety_status: "safe",    energy_kcal: 164, protein_g: 8.9,  fat_g: 2.6,  carbs_g: 27,   moisture_g: 60, raw_safe: false },
  { name: "Frijoles negros cocidos",        category: "carb", species_safe: "dog",   safety_status: "safe",    energy_kcal: 132, protein_g: 8.9,  fat_g: 0.5,  carbs_g: 24,   moisture_g: 66, raw_safe: false },
  { name: "Habas cocidas",                  category: "carb", species_safe: "dog",   safety_status: "safe",    energy_kcal: 110, protein_g: 7.9,  fat_g: 0.4,  carbs_g: 20,   moisture_g: 71, raw_safe: false },
  { name: "Edamame cocido",                 category: "carb", species_safe: "both",  safety_status: "safe",    energy_kcal: 121, protein_g: 11,   fat_g: 5.2,  carbs_g: 8.9,  moisture_g: 73, raw_safe: false },
  { name: "Frijoles pintos cocidos",        category: "carb", species_safe: "dog",   safety_status: "safe",    energy_kcal: 143, protein_g: 9.0,  fat_g: 0.6,  carbs_g: 27,   moisture_g: 63, raw_safe: false },
  { name: "Frijoles blancos cocidos",       category: "carb", species_safe: "dog",   safety_status: "safe",    energy_kcal: 139, protein_g: 9.7,  fat_g: 0.4,  carbs_g: 25,   moisture_g: 64, raw_safe: false },

  # ─────────────────────────────────────────
  # FATS
  # ─────────────────────────────────────────
  { name: "Aceite de salmón",               category: "fat", species_safe: "both",  safety_status: "safe",    energy_kcal: 902, protein_g: 0,    fat_g: 100,  carbs_g: 0,    moisture_g: 0,  raw_safe: true  },
  { name: "Aceite de oliva extra virgen",   category: "fat", species_safe: "both",  safety_status: "safe",    energy_kcal: 884, protein_g: 0,    fat_g: 100,  carbs_g: 0,    moisture_g: 0,  raw_safe: true  },
  { name: "Aceite de girasol",              category: "fat", species_safe: "both",  safety_status: "safe",    energy_kcal: 884, protein_g: 0,    fat_g: 100,  carbs_g: 0,    moisture_g: 0,  raw_safe: true  },
  { name: "Aceite de canola",               category: "fat", species_safe: "both",  safety_status: "safe",    energy_kcal: 884, protein_g: 0,    fat_g: 100,  carbs_g: 0,    moisture_g: 0,  raw_safe: true  },
  { name: "Aceite de coco",                 category: "fat", species_safe: "dog",   safety_status: "caution", energy_kcal: 862, protein_g: 0,    fat_g: 100,  carbs_g: 0,    moisture_g: 0,  raw_safe: true  },
  { name: "Semillas de chía",               category: "fat", species_safe: "both",  safety_status: "safe",    energy_kcal: 486, protein_g: 17,   fat_g: 31,   carbs_g: 42,   moisture_g: 6,  raw_safe: true  },
  { name: "Semillas de linaza molida",      category: "fat", species_safe: "both",  safety_status: "safe",    energy_kcal: 534, protein_g: 18,   fat_g: 42,   carbs_g: 29,   moisture_g: 7,  raw_safe: true  },
  { name: "Aguacate pulpa",                 category: "fat", species_safe: "none",  safety_status: "toxic",   energy_kcal: 160, protein_g: 2.0,  fat_g: 15,   carbs_g: 9.0,  moisture_g: 73, raw_safe: false, safety_notes: "Contiene persina; tóxico para perros aunque en menor concentración que piel y hueso. Evitar por completo. (ASPCA)" },

  # ─────────────────────────────────────────
  # TOXIC — safety_status: toxic (NEVER serve)
  # ─────────────────────────────────────────
  { name: "Cebolla",                        category: "vegetable", species_safe: "none", safety_status: "toxic", energy_kcal: 40,  protein_g: 1.1,  fat_g: 0.1,  carbs_g: 9.3,  moisture_g: 89, raw_safe: false },
  { name: "Ajo",                            category: "vegetable", species_safe: "none", safety_status: "toxic", energy_kcal: 149, protein_g: 6.4,  fat_g: 0.5,  carbs_g: 33,   moisture_g: 59, raw_safe: false },
  { name: "Puerro",                         category: "vegetable", species_safe: "none", safety_status: "toxic", energy_kcal: 61,  protein_g: 1.5,  fat_g: 0.3,  carbs_g: 14,   moisture_g: 83, raw_safe: false },
  { name: "Uvas",                           category: "vegetable", species_safe: "none", safety_status: "toxic", energy_kcal: 69,  protein_g: 0.7,  fat_g: 0.2,  carbs_g: 18,   moisture_g: 81, raw_safe: false },
  { name: "Pasas",                          category: "carb",      species_safe: "none", safety_status: "toxic", energy_kcal: 299, protein_g: 3.1,  fat_g: 0.5,  carbs_g: 79,   moisture_g: 15, raw_safe: false },
  { name: "Chocolate amargo",               category: "carb",      species_safe: "none", safety_status: "toxic", energy_kcal: 598, protein_g: 12,   fat_g: 43,   carbs_g: 46,   moisture_g: 1,  raw_safe: false },
  { name: "Nuez de macadamia",              category: "fat",       species_safe: "none", safety_status: "toxic", energy_kcal: 718, protein_g: 7.9,  fat_g: 76,   carbs_g: 14,   moisture_g: 1,  raw_safe: false },
  { name: "Xilitol",                        category: "carb",      species_safe: "none", safety_status: "toxic", energy_kcal: 240, protein_g: 0,    fat_g: 0,    carbs_g: 60,   moisture_g: 5,  raw_safe: false },
  { name: "Nuez pecana",                    category: "fat",       species_safe: "none", safety_status: "toxic", energy_kcal: 691, protein_g: 9.2,  fat_g: 72,   carbs_g: 14,   moisture_g: 4,  raw_safe: false },
  { name: "Nuez de nogal",                  category: "fat",       species_safe: "none", safety_status: "toxic", energy_kcal: 654, protein_g: 15,   fat_g: 65,   carbs_g: 14,   moisture_g: 4,  raw_safe: false },
  { name: "Café",                           category: "carb",      species_safe: "none", safety_status: "toxic", energy_kcal: 2,   protein_g: 0.3,  fat_g: 0,    carbs_g: 0,    moisture_g: 99, raw_safe: false },
  { name: "Aguacate hueso y cáscara",       category: "fat",       species_safe: "none", safety_status: "toxic", energy_kcal: 0,   protein_g: 0,    fat_g: 0,    carbs_g: 0,    moisture_g: 0,  raw_safe: false },
]

common_attrs = { is_custom: false, source: "INIFAP" }

count = 0
ingredients.each do |attrs|
  Ingredient.find_or_initialize_by(name: attrs[:name]).tap do |ing|
    ing.assign_attributes(common_attrs.merge(attrs))
    ing.save!
  end
  count += 1
end

puts "Seeded #{count} ingredients"
puts "  Safe/Caution: #{Ingredient.non_toxic.count}"
puts "  Toxic: #{Ingredient.where(safety_status: 'toxic').count}"
puts "  Proteins: #{Ingredient.proteins.non_toxic.count}"
puts "  Vegetables: #{Ingredient.vegetables.non_toxic.count}"
puts "  Carbs: #{Ingredient.carbs.non_toxic.count}"
puts "  Fats: #{Ingredient.fats.non_toxic.count}"

# Demo user
puts "\nSeeding demo user..."
user = User.find_or_create_by!(email: "user@nutripet") do |u|
  u.password = "nutri1234"
end

puts "Seeded demo user: #{user.email}"
