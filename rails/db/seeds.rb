# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user_email = ENV.fetch("DEFAULT_USER_EMAIL", "user@nutripet")
user_password = ENV.fetch("DEFAULT_USER_PASSWORD", "user1234")

default_user = User.find_or_initialize_by(email: user_email)
default_user.assign_attributes(
  first_name: "Usuario",
  last_name: "NutriPet",
  password: user_password,
  password_confirmation: user_password
)
default_user.save!
puts "Created or updated default user: #{default_user.email}"

# =============================================================================
# NUTRITIONAL STANDARDS — AAFCO 2023 (dogs) + FEDIAF 2023 (cats)
# Source: AAFCO 2023 Official Publication; FEDIAF 2023 Nutritional Guidelines for Complete & Complementary
# Values in % dry matter (DM) unless noted; energy in kcal ME/kg DM
#
# extra_constraints (JSONB) keys (all % DM):
#   calcium_min_pct, calcium_max_pct, phosphorus_min_pct, phosphorus_max_pct,
#   sodium_min_pct, sodium_max_pct, linoleic_acid_min_pct,
#   taurine_min_pct (cats only), arginine_min_pct (cats only)
# =============================================================================

# Helper: upsert-with-update so repeat db:seed refreshes max values too
def upsert_standard(attrs)
  s = NutritionalStandard.find_or_initialize_by(
    standard_name: attrs[:standard_name],
    species:       attrs[:species],
    life_stage:    attrs[:life_stage]
  )
  s.assign_attributes(attrs)
  s.save!
end

# ─── AAFCO 2023 — DOGS ────────────────────────────────────────────────────────

# Adult maintenance (≥1 year, non-reproducing)
upsert_standard(
  standard_name: "AAFCO", version: "2023", species: "dog", life_stage: "adult",
  protein_min_pct:  18.0, protein_max_pct:  nil,
  fat_min_pct:       5.5, fat_max_pct:      nil,
  fiber_max_pct:     5.0,                              # practical upper limit for digestibility
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 3500, energy_max_kcal_kg: 4500,
  extra_constraints: {
    calcium_min_pct:      0.50, calcium_max_pct:      2.50,
    phosphorus_min_pct:   0.40, phosphorus_max_pct:   1.60,
    ca_p_ratio_min:       1.0,  ca_p_ratio_max:       2.0,
    sodium_min_pct:       0.08, sodium_max_pct:       nil,
    linoleic_acid_min_pct: 1.1
  }
)

# Growth & Reproduction (puppy, pregnant, lactating — share the same AAFCO profile)
%w[puppy pregnant lactating].each do |stage|
  upsert_standard(
    standard_name: "AAFCO", version: "2023", species: "dog", life_stage: stage,
    protein_min_pct:  22.5, protein_max_pct:  nil,
    fat_min_pct:       8.5, fat_max_pct:      nil,
    fiber_max_pct:     5.0,
    moisture_max_pct: 78.0,
    energy_min_kcal_kg: 3500, energy_max_kcal_kg: 4500,
    extra_constraints: {
      calcium_min_pct:      1.20, calcium_max_pct:      2.50,
      phosphorus_min_pct:   1.00, phosphorus_max_pct:   1.60,
      ca_p_ratio_min:       1.0,  ca_p_ratio_max:       2.0,
      sodium_min_pct:       0.08, sodium_max_pct:       nil,
      linoleic_acid_min_pct: 1.1
    }
  )
end

# Senior — follows adult maintenance per AAFCO (no separate geriatric profile),
# but fiber upper limit relaxed to help motility
upsert_standard(
  standard_name: "AAFCO", version: "2023", species: "dog", life_stage: "senior",
  protein_min_pct:  18.0, protein_max_pct:  nil,
  fat_min_pct:       5.5, fat_max_pct:      nil,
  fiber_max_pct:     8.0,
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 3000, energy_max_kcal_kg: 4000,
  extra_constraints: {
    calcium_min_pct:      0.50, calcium_max_pct:      2.50,
    phosphorus_min_pct:   0.40, phosphorus_max_pct:   1.60,
    ca_p_ratio_min:       1.0,  ca_p_ratio_max:       2.0,
    sodium_min_pct:       0.06, sodium_max_pct:       nil,
    linoleic_acid_min_pct: 1.1
  }
)

# All life stages — must satisfy growth/reproduction requirements
upsert_standard(
  standard_name: "AAFCO", version: "2023", species: "dog", life_stage: "all_life_stages",
  protein_min_pct:  22.5, protein_max_pct:  nil,
  fat_min_pct:       8.5, fat_max_pct:      nil,
  fiber_max_pct:     5.0,
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 3500, energy_max_kcal_kg: 4500,
  extra_constraints: {
    calcium_min_pct:      1.20, calcium_max_pct:      2.50,
    phosphorus_min_pct:   1.00, phosphorus_max_pct:   1.60,
    ca_p_ratio_min:       1.0,  ca_p_ratio_max:       2.0,
    sodium_min_pct:       0.08, sodium_max_pct:       nil,
    linoleic_acid_min_pct: 1.1
  }
)

# ─── FEDIAF 2023 — CATS ──────────────────────────────────────────────────────
# FEDIAF values are expressed as % DM for dry food (≤14% moisture)
# Taurine min_pct provided for dry formulation; wet food threshold is ~0.10% DM

# Adult maintenance
upsert_standard(
  standard_name: "FEDIAF", version: "2023", species: "cat", life_stage: "adult",
  protein_min_pct:  25.0, protein_max_pct:  nil,
  fat_min_pct:       9.0, fat_max_pct:      nil,
  fiber_max_pct:     5.0,
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 3500, energy_max_kcal_kg: 5000,
  extra_constraints: {
    calcium_min_pct:      0.50, calcium_max_pct:      2.50,
    phosphorus_min_pct:   0.40, phosphorus_max_pct:   1.60,
    ca_p_ratio_min:       1.0,  ca_p_ratio_max:       2.0,
    sodium_min_pct:       0.08, sodium_max_pct:       nil,
    taurine_min_pct:      0.20,                        # dry matter basis (dry food)
    arginine_min_pct:     1.04,
    linoleic_acid_min_pct: 0.55,
    arachidonic_acid_min_pct: 0.02
  }
)

# Growth & Reproduction (kitten, pregnant, lactating)
%w[kitten pregnant lactating].each do |stage|
  upsert_standard(
    standard_name: "FEDIAF", version: "2023", species: "cat", life_stage: stage,
    protein_min_pct:  28.0, protein_max_pct:  nil,
    fat_min_pct:       9.0, fat_max_pct:      nil,
    fiber_max_pct:     5.0,
    moisture_max_pct: 78.0,
    energy_min_kcal_kg: 4000, energy_max_kcal_kg: 5500,
    extra_constraints: {
      calcium_min_pct:      1.00, calcium_max_pct:      2.50,
      phosphorus_min_pct:   0.80, phosphorus_max_pct:   1.60,
      ca_p_ratio_min:       1.0,  ca_p_ratio_max:       2.0,
      sodium_min_pct:       0.10, sodium_max_pct:       nil,
      taurine_min_pct:      0.25,
      arginine_min_pct:     1.25,
      linoleic_acid_min_pct: 0.55,
      arachidonic_acid_min_pct: 0.04
    }
  )
end

# Senior — FEDIAF recommends higher protein for lean mass preservation
upsert_standard(
  standard_name: "FEDIAF", version: "2023", species: "cat", life_stage: "senior",
  protein_min_pct:  28.0, protein_max_pct:  nil,
  fat_min_pct:       9.0, fat_max_pct:      nil,
  fiber_max_pct:     8.0,
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 3250, energy_max_kcal_kg: 4500,
  extra_constraints: {
    calcium_min_pct:      0.50, calcium_max_pct:      2.50,
    phosphorus_min_pct:   0.40, phosphorus_max_pct:   1.20,   # reduced P for aging kidneys
    ca_p_ratio_min:       1.0,  ca_p_ratio_max:       2.0,
    sodium_min_pct:       0.06, sodium_max_pct:       nil,
    taurine_min_pct:      0.20,
    arginine_min_pct:     1.04,
    linoleic_acid_min_pct: 0.55,
    arachidonic_acid_min_pct: 0.02
  }
)

# All life stages
upsert_standard(
  standard_name: "FEDIAF", version: "2023", species: "cat", life_stage: "all_life_stages",
  protein_min_pct:  28.0, protein_max_pct:  nil,
  fat_min_pct:       9.0, fat_max_pct:      nil,
  fiber_max_pct:     5.0,
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 4000, energy_max_kcal_kg: 5500,
  extra_constraints: {
    calcium_min_pct:      1.00, calcium_max_pct:      2.50,
    phosphorus_min_pct:   0.80, phosphorus_max_pct:   1.60,
    ca_p_ratio_min:       1.0,  ca_p_ratio_max:       2.0,
    sodium_min_pct:       0.10, sodium_max_pct:       nil,
    taurine_min_pct:      0.25,
    arginine_min_pct:     1.25,
    linoleic_acid_min_pct: 0.55,
    arachidonic_acid_min_pct: 0.04
  }
)

# ─── NRC 2006 — DOGS & CATS ──────────────────────────────────────────────────
# Source: National Research Council, "Nutrient Requirements of Dogs and Cats" (2006).
# National Academies Press. ISBN 0-309-08628-2.
# Values are Recommended Allowances (RA) in % DM at a reference energy density
# of 4,000 kcal ME/kg DM (typical dry food). The NRC RA includes a safety margin
# above the Minimum Requirement (MR) to account for ingredient bioavailability
# variation and is the basis used by AAFCO, FEDIAF, and most clinical guidelines.

# NRC 2006 — Dogs adult maintenance
upsert_standard(
  standard_name: "NRC", version: "2006", species: "dog", life_stage: "adult",
  protein_min_pct:  21.8, protein_max_pct:  nil,
  fat_min_pct:      13.8, fat_max_pct:      nil,
  fiber_max_pct:     5.0,
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 3500, energy_max_kcal_kg: 4500,
  extra_constraints: {
    calcium_min_pct:        0.52, calcium_max_pct:        2.50,
    phosphorus_min_pct:     0.42, phosphorus_max_pct:     1.60,
    ca_p_ratio_min:         1.0,  ca_p_ratio_max:         2.0,
    sodium_min_pct:         0.06, sodium_max_pct:         nil,
    linoleic_acid_min_pct:  1.1,
    alpha_linolenic_min_pct: 0.044
  }
)

# NRC 2006 — Dogs growth/reproduction (RA values; fat RA higher for energy density)
%w[puppy pregnant lactating].each do |stage|
  upsert_standard(
    standard_name: "NRC", version: "2006", species: "dog", life_stage: stage,
    protein_min_pct:  22.5, protein_max_pct:  nil,
    fat_min_pct:      21.3, fat_max_pct:      nil,
    fiber_max_pct:     5.0,
    moisture_max_pct: 78.0,
    energy_min_kcal_kg: 3500, energy_max_kcal_kg: 4500,
    extra_constraints: {
      calcium_min_pct:        1.20, calcium_max_pct:        2.50,
      phosphorus_min_pct:     1.00, phosphorus_max_pct:     1.60,
      ca_p_ratio_min:         1.0,  ca_p_ratio_max:         2.0,
      sodium_min_pct:         0.06, sodium_max_pct:         nil,
      linoleic_acid_min_pct:  1.1,
      alpha_linolenic_min_pct: 0.044
    }
  )
end

# NRC 2006 — Dogs senior (same RA as adult; NRC 2006 has no separate geriatric table)
upsert_standard(
  standard_name: "NRC", version: "2006", species: "dog", life_stage: "senior",
  protein_min_pct:  21.8, protein_max_pct:  nil,
  fat_min_pct:      13.8, fat_max_pct:      nil,
  fiber_max_pct:     8.0,
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 3000, energy_max_kcal_kg: 4000,
  extra_constraints: {
    calcium_min_pct:        0.52, calcium_max_pct:        2.50,
    phosphorus_min_pct:     0.42, phosphorus_max_pct:     1.60,
    ca_p_ratio_min:         1.0,  ca_p_ratio_max:         2.0,
    sodium_min_pct:         0.06, sodium_max_pct:         nil,
    linoleic_acid_min_pct:  1.1,
    alpha_linolenic_min_pct: 0.044
  }
)

# NRC 2006 — Dogs all life stages
upsert_standard(
  standard_name: "NRC", version: "2006", species: "dog", life_stage: "all_life_stages",
  protein_min_pct:  22.5, protein_max_pct:  nil,
  fat_min_pct:      21.3, fat_max_pct:      nil,
  fiber_max_pct:     5.0,
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 3500, energy_max_kcal_kg: 4500,
  extra_constraints: {
    calcium_min_pct:        1.20, calcium_max_pct:        2.50,
    phosphorus_min_pct:     1.00, phosphorus_max_pct:     1.60,
    ca_p_ratio_min:         1.0,  ca_p_ratio_max:         2.0,
    sodium_min_pct:         0.06, sodium_max_pct:         nil,
    linoleic_acid_min_pct:  1.1,
    alpha_linolenic_min_pct: 0.044
  }
)

# NRC 2006 — Cats adult maintenance
# Note: NRC provides taurine RA as free taurine 0.065% DM; practical formulation
# uses 0.10–0.20% to account for food-processing losses (taurine is labile to heat).
upsert_standard(
  standard_name: "NRC", version: "2006", species: "cat", life_stage: "adult",
  protein_min_pct:  26.0, protein_max_pct:  nil,
  fat_min_pct:       9.0, fat_max_pct:      nil,
  fiber_max_pct:     5.0,
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 3500, energy_max_kcal_kg: 5000,
  extra_constraints: {
    calcium_min_pct:             0.29, calcium_max_pct:             2.50,
    phosphorus_min_pct:          0.26, phosphorus_max_pct:          1.60,
    ca_p_ratio_min:              0.9,  ca_p_ratio_max:              2.0,
    sodium_min_pct:              0.068, sodium_max_pct:             nil,
    taurine_min_pct:             0.065,  # RA free taurine (add processing buffer in formulation)
    arginine_min_pct:            1.04,
    linoleic_acid_min_pct:       0.55,
    arachidonic_acid_min_pct:    0.02
  }
)

# NRC 2006 — Cats growth/reproduction
%w[kitten pregnant lactating].each do |stage|
  upsert_standard(
    standard_name: "NRC", version: "2006", species: "cat", life_stage: stage,
    protein_min_pct:  30.0, protein_max_pct:  nil,
    fat_min_pct:       9.0, fat_max_pct:      nil,
    fiber_max_pct:     5.0,
    moisture_max_pct: 78.0,
    energy_min_kcal_kg: 4000, energy_max_kcal_kg: 5500,
    extra_constraints: {
      calcium_min_pct:             0.96, calcium_max_pct:             2.50,
      phosphorus_min_pct:          0.77, phosphorus_max_pct:          1.60,
      ca_p_ratio_min:              1.0,  ca_p_ratio_max:              2.0,
      sodium_min_pct:              0.068, sodium_max_pct:             nil,
      taurine_min_pct:             0.10,
      arginine_min_pct:            1.25,
      linoleic_acid_min_pct:       0.55,
      arachidonic_acid_min_pct:    0.04
    }
  )
end

# NRC 2006 — Cats senior (NRC 2006 recommends higher protein for aging cats)
upsert_standard(
  standard_name: "NRC", version: "2006", species: "cat", life_stage: "senior",
  protein_min_pct:  28.0, protein_max_pct:  nil,
  fat_min_pct:       9.0, fat_max_pct:      nil,
  fiber_max_pct:     8.0,
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 3250, energy_max_kcal_kg: 4500,
  extra_constraints: {
    calcium_min_pct:             0.29, calcium_max_pct:             2.50,
    phosphorus_min_pct:          0.26, phosphorus_max_pct:          1.20,  # reduced for aging kidneys
    ca_p_ratio_min:              0.9,  ca_p_ratio_max:              2.0,
    sodium_min_pct:              0.05, sodium_max_pct:              nil,
    taurine_min_pct:             0.065,
    arginine_min_pct:            1.04,
    linoleic_acid_min_pct:       0.55,
    arachidonic_acid_min_pct:    0.02
  }
)

# NRC 2006 — Cats all life stages
upsert_standard(
  standard_name: "NRC", version: "2006", species: "cat", life_stage: "all_life_stages",
  protein_min_pct:  30.0, protein_max_pct:  nil,
  fat_min_pct:       9.0, fat_max_pct:      nil,
  fiber_max_pct:     5.0,
  moisture_max_pct: 78.0,
  energy_min_kcal_kg: 4000, energy_max_kcal_kg: 5500,
  extra_constraints: {
    calcium_min_pct:             0.96, calcium_max_pct:             2.50,
    phosphorus_min_pct:          0.77, phosphorus_max_pct:          1.60,
    ca_p_ratio_min:              1.0,  ca_p_ratio_max:              2.0,
    sodium_min_pct:              0.068, sodium_max_pct:             nil,
    taurine_min_pct:             0.10,
    arginine_min_pct:            1.25,
    linoleic_acid_min_pct:       0.55,
    arachidonic_acid_min_pct:    0.04
  }
)

puts "Seeded #{NutritionalStandard.count} nutritional standards"

# =============================================================================
# INGREDIENTS — safe catalog + toxic reference list
# Nutritional values per 100g as-fed (USDA / INIFAP data)
# =============================================================================

# --------------- SAFE PROTEINS ---------------
safe_proteins = [
  { name: "Pollo cocido sin hueso",           species_safe: "both", category: "protein",
    protein_g: 27.3, fat_g: 7.4,   carbs_g: 0,    fiber_g: 0,   moisture_g: 64.0, energy_kcal: 172 },
  { name: "Res molida cocida (90% magra)",     species_safe: "both", category: "protein",
    protein_g: 26.1, fat_g: 10.0,  carbs_g: 0,    fiber_g: 0,   moisture_g: 62.0, energy_kcal: 195 },
  { name: "Salmón al vapor",                  species_safe: "both", category: "protein",
    protein_g: 25.4, fat_g: 8.1,   carbs_g: 0,    fiber_g: 0,   moisture_g: 64.0, energy_kcal: 182 },
  { name: "Pavo molido cocido",               species_safe: "both", category: "protein",
    protein_g: 27.0, fat_g: 6.6,   carbs_g: 0,    fiber_g: 0,   moisture_g: 65.0, energy_kcal: 170 },
  { name: "Sardinas en agua (escurridas)",     species_safe: "both", category: "protein",
    protein_g: 24.6, fat_g: 11.4,  carbs_g: 0,    fiber_g: 0,   moisture_g: 62.0, energy_kcal: 208 },
  { name: "Hígado de pollo cocido",           species_safe: "both", category: "protein",
    protein_g: 24.4, fat_g: 5.5,   carbs_g: 1.0,  fiber_g: 0,   moisture_g: 67.0, energy_kcal: 172 },
  { name: "Atún en agua (escurrido)",         species_safe: "both", category: "protein",
    protein_g: 25.5, fat_g: 2.5,   carbs_g: 0,    fiber_g: 0,   moisture_g: 70.0, energy_kcal: 128 },
  { name: "Cordero cocido",                   species_safe: "both", category: "protein",
    protein_g: 25.6, fat_g: 9.5,   carbs_g: 0,    fiber_g: 0,   moisture_g: 63.0, energy_kcal: 193 },
  { name: "Pato cocido sin piel",             species_safe: "both", category: "protein",
    protein_g: 27.5, fat_g: 7.5,   carbs_g: 0,    fiber_g: 0,   moisture_g: 63.0, energy_kcal: 179 },
  { name: "Conejo cocido",                    species_safe: "both", category: "protein",
    protein_g: 29.1, fat_g: 5.0,   carbs_g: 0,    fiber_g: 0,   moisture_g: 64.0, energy_kcal: 160 },
  { name: "Bacalao cocido",                   species_safe: "both", category: "protein",
    protein_g: 22.8, fat_g: 0.9,   carbs_g: 0,    fiber_g: 0,   moisture_g: 75.0, energy_kcal:  98 },
  { name: "Tilapia al vapor",                 species_safe: "both", category: "protein",
    protein_g: 23.0, fat_g: 2.0,   carbs_g: 0,    fiber_g: 0,   moisture_g: 73.0, energy_kcal: 111 },
  { name: "Huevo cocido",                     species_safe: "both", category: "protein",
    protein_g: 13.0, fat_g: 11.0,  carbs_g: 0.6,  fiber_g: 0,   moisture_g: 75.0, energy_kcal: 155 },
  { name: "Hígado de res cocido",             species_safe: "both", category: "protein",
    protein_g: 26.5, fat_g: 5.3,   carbs_g: 4.4,  fiber_g: 0,   moisture_g: 63.0, energy_kcal: 175 },
]

# --------------- SAFE CARBS (dogs only) ---------------
safe_carbs = [
  { name: "Arroz blanco cocido",   species_safe: "dog", category: "carb",
    protein_g: 2.7,  fat_g: 0.3,  carbs_g: 28.2, fiber_g: 0.4, moisture_g: 68.0, energy_kcal: 130 },
  { name: "Camote cocido",         species_safe: "dog", category: "carb",
    protein_g: 1.6,  fat_g: 0.1,  carbs_g: 20.1, fiber_g: 3.0, moisture_g: 76.0, energy_kcal:  86 },
  { name: "Avena cocida",          species_safe: "dog", category: "carb",
    protein_g: 2.5,  fat_g: 1.5,  carbs_g: 12.0, fiber_g: 1.7, moisture_g: 84.0, energy_kcal:  71 },
  { name: "Quinoa cocida",         species_safe: "dog", category: "carb",
    protein_g: 4.4,  fat_g: 1.9,  carbs_g: 21.3, fiber_g: 2.8, moisture_g: 72.0, energy_kcal: 120 },
  { name: "Papa cocida sin cáscara", species_safe: "dog", category: "carb",
    protein_g: 2.0,  fat_g: 0.1,  carbs_g: 17.0, fiber_g: 1.8, moisture_g: 80.0, energy_kcal:  77 },
  { name: "Lenteja cocida",        species_safe: "dog", category: "carb",
    protein_g: 9.0,  fat_g: 0.4,  carbs_g: 20.1, fiber_g: 7.9, moisture_g: 70.0, energy_kcal: 116 },
]

# --------------- SAFE VEGETABLES ---------------
safe_vegetables = [
  { name: "Zanahoria cocida",    species_safe: "both", category: "vegetable",
    protein_g: 0.8,  fat_g: 0.1,  carbs_g: 8.0,  fiber_g: 2.9, moisture_g: 90.0, energy_kcal:  35 },
  { name: "Calabacita cocida",   species_safe: "both", category: "vegetable",
    protein_g: 1.0,  fat_g: 0.2,  carbs_g: 3.0,  fiber_g: 1.0, moisture_g: 94.0, energy_kcal:  17 },
  { name: "Espinaca cocida",     species_safe: "dog",  category: "vegetable",
    protein_g: 3.0,  fat_g: 0.4,  carbs_g: 3.8,  fiber_g: 2.4, moisture_g: 91.0, energy_kcal:  23 },
  { name: "Brócoli cocido",      species_safe: "dog",  category: "vegetable",
    protein_g: 2.4,  fat_g: 0.4,  carbs_g: 6.6,  fiber_g: 3.3, moisture_g: 90.0, energy_kcal:  35 },
  { name: "Pepino rallado",      species_safe: "both", category: "vegetable",
    protein_g: 0.7,  fat_g: 0.1,  carbs_g: 3.6,  fiber_g: 0.5, moisture_g: 95.0, energy_kcal:  16 },
  { name: "Chayote cocido",      species_safe: "both", category: "vegetable",
    protein_g: 0.8,  fat_g: 0.1,  carbs_g: 4.5,  fiber_g: 1.7, moisture_g: 94.0, energy_kcal:  19 },
  { name: "Ejotes cocidos",      species_safe: "both", category: "vegetable",
    protein_g: 1.9,  fat_g: 0.2,  carbs_g: 7.1,  fiber_g: 3.4, moisture_g: 89.0, energy_kcal:  31 },
  { name: "Espárrago cocido",    species_safe: "both", category: "vegetable",
    protein_g: 2.4,  fat_g: 0.2,  carbs_g: 3.9,  fiber_g: 2.1, moisture_g: 93.0, energy_kcal:  22 },
]

# --------------- SAFE FATS ---------------
safe_fats = [
  { name: "Aceite de salmón", species_safe: "both", category: "fat",
    protein_g: 0, fat_g: 100.0, carbs_g: 0, fiber_g: 0, moisture_g: 0, energy_kcal: 900 },
  { name: "Aceite de coco",   species_safe: "both", category: "fat",
    protein_g: 0, fat_g: 100.0, carbs_g: 0, fiber_g: 0, moisture_g: 0, energy_kcal: 892 },
  { name: "Aceite de oliva",  species_safe: "both", category: "fat",
    protein_g: 0, fat_g: 100.0, carbs_g: 0, fiber_g: 0, moisture_g: 0, energy_kcal: 884 },
]

# --------------- TOXIC / CAUTION (reference — never served) ---------------
toxic_ingredients = [
  { name: "Cebolla (cualquier forma)",   species_safe: "none", category: "vegetable",
    safety_status: "toxic",
    safety_notes: "Causa anemia hemolítica en perros y gatos. Tóxica en cualquier forma (cruda, cocida, en polvo).",
    protein_g: 1.1, fat_g: 0.1, carbs_g: 9.3, fiber_g: 1.7, moisture_g: 89.0, energy_kcal: 40 },
  { name: "Ajo crudo o cocido",          species_safe: "none", category: "vegetable",
    safety_status: "toxic",
    safety_notes: "Toxicidad por tiosulfatos. Especialmente dañino para gatos. Dosis pequeñas ya son peligrosas.",
    protein_g: 6.4, fat_g: 0.5, carbs_g: 33.1, fiber_g: 2.1, moisture_g: 59.0, energy_kcal: 149 },
  { name: "Uvas o pasas",               species_safe: "none", category: "carb",
    safety_status: "toxic",
    safety_notes: "Causa insuficiencia renal aguda en perros. Mecanismo desconocido. Evitar completamente.",
    protein_g: 0.7, fat_g: 0.2, carbs_g: 18.1, fiber_g: 0.9, moisture_g: 81.0, energy_kcal: 69 },
  { name: "Chocolate (cacao)",          species_safe: "none", category: "carb",
    safety_status: "toxic",
    safety_notes: "Contiene teobromina y cafeína. Causa vómito, convulsiones y puede ser fatal.",
    protein_g: 5.5, fat_g: 13.7, carbs_g: 60.0, fiber_g: 7.0, moisture_g: 1.0, energy_kcal: 400 },
  { name: "Xilitol (edulcorante)",      species_safe: "none", category: "carb",
    safety_status: "toxic",
    safety_notes: "Causa hipoglucemia severa y falla hepática en perros. Presente en chicles, algunos yogures.",
    protein_g: 0, fat_g: 0, carbs_g: 100.0, fiber_g: 0, moisture_g: 0, energy_kcal: 240 },
  { name: "Macadamia (nuez)",           species_safe: "none", category: "fat",
    safety_status: "toxic",
    safety_notes: "Causa debilidad, hipertermia y vómitos en perros. Mecanismo desconocido.",
    protein_g: 7.9, fat_g: 75.8, carbs_g: 13.8, fiber_g: 8.6, moisture_g: 2.0, energy_kcal: 718 },
  { name: "Lácteos (leche entera)",     species_safe: "none", category: "fat",
    safety_status: "caution",
    safety_notes: "La mayoría de los perros y gatos adultos son intolerantes a la lactosa. Puede causar diarrea y malestar gastrointestinal.",
    protein_g: 3.3, fat_g: 3.7, carbs_g: 4.8, fiber_g: 0, moisture_g: 88.0, energy_kcal: 61 },
  { name: "Aguacate (pulpa y hueso)",   species_safe: "none", category: "fat",
    safety_status: "caution",
    safety_notes: "La persina en la pulpa puede causar vómito en perros. El hueso es un riesgo de obstrucción.",
    protein_g: 2.0, fat_g: 14.7, carbs_g: 8.5, fiber_g: 6.7, moisture_g: 73.0, energy_kcal: 160 },
]

all_ingredients = safe_proteins + safe_carbs + safe_vegetables + safe_fats

all_ingredients.each do |attrs|
  ing = Ingredient.find_or_initialize_by(name: attrs[:name])
  ing.assign_attributes(
    attrs.merge(
      is_custom:    false,
      source:       attrs.fetch(:source, "USDA"),
      safety_status: attrs.fetch(:safety_status, "safe"),
      safety_notes:  attrs[:safety_notes]
    )
  )
  ing.save!
end

toxic_ingredients.each do |attrs|
  ing = Ingredient.find_or_initialize_by(name: attrs[:name])
  ing.assign_attributes(attrs.merge(is_custom: false, source: "USDA"))
  ing.save!
end

puts "Seeded #{Ingredient.count} ingredients (#{Ingredient.non_toxic.count} safe/caution, #{Ingredient.where(safety_status: 'toxic').count} toxic)"

# =============================================================================
# RAW_SAFE + THERAPEUTIC_FOR — patch existing ingredients
# raw_safe: based on AVMA/WSAVA raw feeding safety guidelines
# therapeutic_for: set AFTER conditions are seeded (see below)
# =============================================================================

# Mark proteins raw-safe (lean meats safe when fresh/frozen; no processing needed on raw diet)
# Fish/eggs are NOT raw-safe: fish = parasite/anisakis risk; eggs = avidin from raw whites
[
  "Pollo cocido sin hueso",
  "Res molida cocida (90% magra)",
  "Pavo molido cocido",
  "Cordero cocido",
  "Pato cocido sin piel",
  "Conejo cocido"
].each do |name|
  ing = Ingredient.find_by(name: name)
  ing&.update!(raw_safe: true)
end

# Vegetables raw-safe (firm non-starchy veggies; no anti-nutritional factors when raw)
[
  "Pepino rallado",
  "Chayote cocido",
  "Ejotes cocidos",
  "Espárrago cocido"
].each do |name|
  ing = Ingredient.find_by(name: name)
  ing&.update!(raw_safe: true)
end
# (Grains — arroz, avena, quinoa — must be cooked; raw_safe remains false)
# (Papa — solanine risk when raw; raw_safe remains false)
# (Fish — parasite risk; must cook; raw_safe remains false)

puts "Updated raw_safe flags on #{Ingredient.where(raw_safe: true).count} ingredients"

# =============================================================================
# CONDITIONS — GI-focused therapeutic conditions
# =============================================================================
conditions = [
  { name: "Insuficiencia renal crónica", species_scope: "both",
    dietary_notes: "Restringir proteína y fósforo" },
  { name: "Diabetes mellitus", species_scope: "both",
    dietary_notes: "Reducir carbohidratos simples, aumentar fibra" },
  { name: "Sobrepeso / obesidad", species_scope: "both",
    dietary_notes: "Reducir densidad energética, aumentar fibra" },
  { name: "Pancreatitis", species_scope: "both",
    dietary_notes: "Restringir grasa total" },
  { name: "Enfermedad inflamatoria intestinal", species_scope: "both",
    dietary_notes: "Dieta hipoalergénica, alta digestibilidad" },
  { name: "Cardiopatía", species_scope: "both",
    dietary_notes: "Reducir sodio" },
  { name: "Hipotiroidismo", species_scope: "dog",
    dietary_notes: "Controlar densidad energética" },
  { name: "Hipertiroidismo", species_scope: "cat",
    dietary_notes: "Aumentar proteína de alta calidad" },
  # ── Nuevas condiciones GI (funcional/terapéutico) ──
  { name: "Diarrea / heces blandas", species_scope: "both",
    dietary_notes: "Dieta blanda, fibra soluble, alta digestibilidad. Evitar grasas y lácteos." },
  { name: "Estreñimiento", species_scope: "both",
    dietary_notes: "Aumentar fibra insoluble y agua. Evitar dieta baja en residuo." },
  { name: "Gases / flatulencia", species_scope: "both",
    dietary_notes: "Reducir leguminosas, crucíferas y alimentos fermentables." },
  { name: "Náuseas / vómito", species_scope: "both",
    dietary_notes: "Comidas pequeñas y frecuentes. Dieta blanda y de alta digestibilidad." },
  { name: "Digestión lenta (dispepsia)", species_scope: "both",
    dietary_notes: "Ingredientes de alta digestibilidad, jengibre con moderación." }
]

conditions.each do |attrs|
  Condition.find_or_create_by!(name: attrs[:name]) { |c| c.assign_attributes(attrs) }
end
puts "Seeded #{Condition.count} conditions"

# =============================================================================
# ALLERGENS
# =============================================================================
allergens = [
  { name: "Pollo",     category: "protein" },
  { name: "Res",       category: "protein" },
  { name: "Pescado",   category: "protein" },
  { name: "Cerdo",     category: "protein" },
  { name: "Huevo",     category: "protein" },
  { name: "Trigo",     category: "grain" },
  { name: "Maíz",      category: "grain" },
  { name: "Soya",      category: "grain" },
  { name: "Lácteos",   category: "other" },
  { name: "Cacahuate", category: "other" }
]

allergens.each do |attrs|
  Allergen.find_or_create_by!(name: attrs[:name]) { |a| a.assign_attributes(attrs) }
end
puts "Seeded #{Allergen.count} allergens"

# =============================================================================
# THERAPEUTIC INGREDIENTS — GI-functional ingredients for Mexico market
# Source: Nutritional values USDA/INIFAP; therapeutic evidence from peer-reviewed
# veterinary nutrition literature (WSAVA/AAFCO companion animal reports).
# =============================================================================

therapeutic_ingredients = [
  # Guayaba cocida — Pectin (soluble fiber) normalizes water in intestinal lumen
  # → antidiarrheal; also carminative (reduces gas-producing fermentation)
  { name: "Guayaba cocida sin semillas",
    species_safe: "dog", category: "vegetable", safety_status: "safe",
    safety_notes: "Rica en pectina soluble. Sin semillas para evitar obstrucción.",
    protein_g: 2.6, fat_g: 1.0, carbs_g: 14.3, fiber_g: 5.4, moisture_g: 80.8, energy_kcal: 68,
    raw_safe: false,   # cooking breaks seeds + improves pectins
    source: "USDA FDC #173044" },

  # Mango maduro cocido — Insoluble fiber + polyphenols bulk stool → constipation relief
  { name: "Mango maduro cocido",
    species_safe: "dog", category: "vegetable", safety_status: "safe",
    safety_notes: "Retirar el hueso (tóxico). Cocinar brevemente para suavizar fibra.",
    protein_g: 0.8, fat_g: 0.4, carbs_g: 15.0, fiber_g: 1.6, moisture_g: 83.0, energy_kcal: 60,
    raw_safe: false,  # cooking removes mango peel + softens fiber
    source: "USDA FDC #169910" },

  # Papaya cocida — Papaína (proteolytic enzyme) aids protein digestion; insoluble fiber for constipation
  { name: "Papaya cocida sin semillas",
    species_safe: "both", category: "vegetable", safety_status: "safe",
    safety_notes: "Retirar semillas. Las enzimas (papaína) mejoran la digestibilidad proteica.",
    protein_g: 0.5, fat_g: 0.3, carbs_g: 9.8, fiber_g: 1.8, moisture_g: 88.1, energy_kcal: 39,
    raw_safe: false,
    source: "USDA FDC #169926" },

  # Zapallo / calabaza de castilla cocida — Soluble + insoluble fiber; bulks loose stools AND softens hard stools
  # Widely recommended by veterinary nutritionists for canine GI upset
  { name: "Zapallo / calabaza cocida",
    species_safe: "both", category: "vegetable", safety_status: "safe",
    safety_notes: "Sin added salt. Rica en fibras mixtas: tanto para diarrea como estreñimiento.",
    protein_g: 1.0, fat_g: 0.1, carbs_g: 6.0, fiber_g: 0.5, moisture_g: 92.0, energy_kcal: 26,
    raw_safe: false,
    source: "USDA FDC #168448" },

  # Jengibre rallado — Carminativo y antiemético; dosis máx 10–20mg/kg en perros (CAUTION)
  { name: "Jengibre fresco rallado",
    species_safe: "dog", category: "vegetable", safety_status: "caution",
    safety_notes: "Carminativo y antiemético. Usar ≤1/4 cucharadita pequeña por 10 kg de peso. NO usar en gatos.",
    protein_g: 1.8, fat_g: 0.8, carbs_g: 17.8, fiber_g: 2.0, moisture_g: 79.0, energy_kcal: 80,
    raw_safe: true,   # ginger is effective raw and safe raw at low doses
    source: "USDA FDC #169231" },
]

therapeutic_ingredients.each do |attrs|
  ing = Ingredient.find_or_initialize_by(name: attrs[:name])
  ing.assign_attributes(attrs.merge(is_custom: false))
  ing.save!
end

# Wire therapeutic_for after conditions have been created
# The integer array maps to Condition IDs resolved by name
def condition_ids(*names)
  names.map { |n| Condition.find_by(name: n)&.id }.compact
end

{
  "Guayaba cocida sin semillas"   => condition_ids("Diarrea / heces blandas", "Gases / flatulencia"),
  "Mango maduro cocido"           => condition_ids("Estreñimiento"),
  "Papaya cocida sin semillas"    => condition_ids("Estreñimiento", "Digestión lenta (dispepsia)"),
  "Zapallo / calabaza cocida"     => condition_ids("Diarrea / heces blandas", "Estreñimiento"),
  "Jengibre fresco rallado"       => condition_ids("Gases / flatulencia", "Náuseas / vómito"),
}.each do |name, ids|
  next if ids.empty?
  ing = Ingredient.find_by(name: name)
  ing&.update!(therapeutic_for: ids)
end

puts "Added #{therapeutic_ingredients.size} therapeutic ingredients"
puts "Updated therapeutic_for on #{Ingredient.where.not(therapeutic_for: []).count} ingredients"

# =============================================================================
# COMMERCIAL FOODS — Mexico market (Guaranteed Analysis, as-fed basis)
# Sources: Official product labels / brand websites (verified data published
# under COFEPRIS regulation NOM-066-ZOO-1995 for pet food labeling).
# Energy values: estimated ME from Atwater modified factors when not label-declared.
# =============================================================================

commercial_foods_data = [
  # ── PERROS — SECO ────────────────────────────────────────────────────────────
  {
    name:               "Pedigree Adulto Croquetas con Res y Vegetales",
    brand:              "Pedigree (Mars)",
    species:            "dog", life_stage: "adult", food_form: "dry",
    protein_min_pct:    21.0, fat_min_pct: 8.0, fiber_max_pct: 4.0, moisture_max_pct: 12.0,
    energy_kcal_per_kg: 3400,
    label_standard:     "AAFCO",
    ingredients_list:   "Harina de cereales, harina de carne de pollo, grasa animal, harina de soya, minerales, vitaminas.",
    is_active:          true,
    source:             "Etiqueta del producto / pedigree.com.mx (Análisis Garantizado)"
  },
  {
    name:               "Purina Dog Chow Adulto Razas Medianas",
    brand:              "Purina (Nestlé)",
    species:            "dog", life_stage: "adult", food_form: "dry",
    protein_min_pct:    21.0, fat_min_pct: 9.0, fiber_max_pct: 4.5, moisture_max_pct: 12.0,
    energy_kcal_per_kg: 3500,
    label_standard:     "AAFCO",
    ingredients_list:   "Maíz, harina de pollo, gluten de maíz, grasa de pollo, harina de soya, minerales, vitaminas.",
    is_active:          true,
    source:             "Etiqueta del producto / purina.com.mx"
  },
  {
    name:               "Purina Pro Plan Adulto Pollo y Arroz",
    brand:              "Purina Pro Plan (Nestlé)",
    species:            "dog", life_stage: "adult", food_form: "dry",
    protein_min_pct:    26.0, fat_min_pct: 16.0, fiber_max_pct: 3.0, moisture_max_pct: 12.0,
    energy_kcal_per_kg: 4000,
    label_standard:     "AAFCO",
    ingredients_list:   "Pollo, arroz, harina de pollo, grasa de pollo, maíz, omega-3/6, minerales, vitaminas.",
    is_active:          true,
    source:             "Etiqueta del producto / purina.com.mx/proplan"
  },
  {
    name:               "Royal Canin Medium Adult",
    brand:              "Royal Canin (Mars)",
    species:            "dog", life_stage: "adult", food_form: "dry",
    protein_min_pct:    25.0, fat_min_pct: 14.0, fiber_max_pct: 3.8, moisture_max_pct: 10.0,
    energy_kcal_per_kg: 3700,
    label_standard:     "FEDIAF",
    ingredients_list:   "Harina de pollo, maíz, harina de trigo, grasa animal, pulpa de remolacha, aceite de soya, minerales, vitaminas.",
    is_active:          true,
    source:             "Etiqueta del producto / royalcanin.com/mx"
  },
  {
    name:               "Hill's Science Diet Adult",
    brand:              "Hill's Pet Nutrition",
    species:            "dog", life_stage: "adult", food_form: "dry",
    protein_min_pct:    18.5, fat_min_pct: 12.5, fiber_max_pct: 3.5, moisture_max_pct: 10.0,
    energy_kcal_per_kg: 3600,
    label_standard:     "AAFCO",
    ingredients_list:   "Maíz, harina de pollo, harina de trigo, grasa animal, pulpa de achicoria, minerales, antioxidantes.",
    is_active:          true,
    source:             "Etiqueta del producto / hillspet.com.mx"
  },
  {
    name:               "Purina One Adulto Pollo",
    brand:              "Purina One (Nestlé)",
    species:            "dog", life_stage: "adult", food_form: "dry",
    protein_min_pct:    28.0, fat_min_pct: 15.0, fiber_max_pct: 3.0, moisture_max_pct: 12.0,
    energy_kcal_per_kg: 3900,
    label_standard:     "AAFCO",
    ingredients_list:   "Pollo, maíz, harina de pollo, grasa de pollo, arroz, omega-6, minerales, vitaminas.",
    is_active:          true,
    source:             "Etiqueta del producto / purina.com.mx/one"
  },
  {
    name:               "Cannes Adulto",
    brand:              "Cannes (distribuido por Mars México)",
    species:            "dog", life_stage: "adult", food_form: "dry",
    protein_min_pct:    19.0, fat_min_pct: 7.0, fiber_max_pct: 5.0, moisture_max_pct: 12.0,
    energy_kcal_per_kg: 3200,
    label_standard:     "AAFCO",
    ingredients_list:   "Harina de cereales, harina de carne, grasa animal, minerales, vitaminas.",
    is_active:          true,
    source:             "Etiqueta del producto (marca económica para mercado mexicano)"
  },
  # ── GATOS — SECO ─────────────────────────────────────────────────────────────
  {
    name:               "Purina Cat Chow Adulto",
    brand:              "Cat Chow (Nestlé Purina)",
    species:            "cat", life_stage: "adult", food_form: "dry",
    protein_min_pct:    30.0, fat_min_pct: 9.0, fiber_max_pct: 4.5, moisture_max_pct: 12.0,
    energy_kcal_per_kg: 3600,
    label_standard:     "AAFCO",
    ingredients_list:   "Harina de pollo, maíz, gluten de trigo, grasa de pollo, taurina, minerales, vitaminas.",
    is_active:          true,
    source:             "Etiqueta del producto / purina.com.mx/catchow"
  },
  {
    name:               "Whiskas Adulto Seco Pollo",
    brand:              "Whiskas (Mars)",
    species:            "cat", life_stage: "adult", food_form: "dry",
    protein_min_pct:    28.0, fat_min_pct: 8.0, fiber_max_pct: 3.5, moisture_max_pct: 12.0,
    energy_kcal_per_kg: 3400,
    label_standard:     "AAFCO",
    ingredients_list:   "Harina de pollo, harina de cereales, grasa animal, taurina, minerales, vitaminas.",
    is_active:          true,
    source:             "Etiqueta del producto / whiskas.com.mx"
  },
  {
    name:               "Royal Canin Kitten (gatito)",
    brand:              "Royal Canin (Mars)",
    species:            "cat", life_stage: "kitten", food_form: "dry",
    protein_min_pct:    34.0, fat_min_pct: 17.0, fiber_max_pct: 3.0, moisture_max_pct: 10.0,
    energy_kcal_per_kg: 4050,
    label_standard:     "FEDIAF",
    ingredients_list:   "Harina de pollo, arroz, harina de trigo, grasa animal, aceite de pescado, taurina, minerales, vitaminas.",
    is_active:          true,
    source:             "Etiqueta del producto / royalcanin.com/mx"
  },
]

commercial_foods_data.each do |attrs|
  food = CommercialFood.find_or_initialize_by(name: attrs[:name])
  food.assign_attributes(attrs)
  food.save!
end

puts "Seeded #{CommercialFood.count} commercial foods"

# =============================================================================
# MASTER RECIPES
# =============================================================================
chicken_rice  = Ingredient.find_by!(name: "Pollo cocido sin hueso")
sweet_potato  = Ingredient.find_by!(name: "Camote cocido")
carrot        = Ingredient.find_by!(name: "Zanahoria cocida")
salmon_oil    = Ingredient.find_by!(name: "Aceite de salmón")
egg           = Ingredient.find_by!(name: "Huevo cocido")
rice          = Ingredient.find_by!(name: "Arroz blanco cocido")
turkey        = Ingredient.find_by!(name: "Pavo molido cocido")
zucchini      = Ingredient.find_by!(name: "Calabacita cocida")
salmon        = Ingredient.find_by!(name: "Salmón al vapor")
diet_dog_adult = Diet.find_or_create_by!(name: "Dieta Base Adulto Perro") do |r|
  r.description       = "Dieta equilibrada para perro adulto sano"
  r.preparation_notes = "Cocinar todas las proteínas y vegetales. No añadir sal ni condimentos. Servir a temperatura ambiente. Dividir en 2 porciones al día."
  r.species           = "dog"
  r.life_stage        = "adult"
  r.status            = "active"
end

# Assign ingredients to recipe (base percentages must sum to 100)
[
  { ingredient: chicken_rice, base_percentage: 45, is_supplement: false },
  { ingredient: rice,         base_percentage: 30, is_supplement: false },
  { ingredient: sweet_potato, base_percentage: 10, is_supplement: false },
  { ingredient: carrot,       base_percentage: 10, is_supplement: false },
  { ingredient: salmon_oil,   base_percentage:  5, is_supplement: true  }
].each do |ri|
  RecipeIngredient.find_or_create_by!(diet: diet_dog_adult, ingredient: ri[:ingredient]) do |r|
    r.base_percentage = ri[:base_percentage]
    r.is_supplement   = ri[:is_supplement]
  end
end

# Recipe 2: Generic adult cat
diet_cat_adult = Diet.find_or_create_by!(name: "Dieta Base Adulto Gato") do |r|
  r.description       = "Dieta equilibrada para gato adulto sano"
  r.preparation_notes = "Cocinar la proteína completamente. Los gatos requieren taurina — el aceite de salmón ayuda. Servir en porciones pequeñas frecuentes (3–4 veces al día)."
  r.species           = "cat"
  r.life_stage        = "adult"
  r.status            = "active"
end

[
  { ingredient: turkey,     base_percentage: 60, is_supplement: false },
  { ingredient: zucchini,   base_percentage: 15, is_supplement: false },
  { ingredient: carrot,     base_percentage: 10, is_supplement: false },
  { ingredient: egg,        base_percentage: 10, is_supplement: false },
  { ingredient: salmon_oil, base_percentage:  5, is_supplement: true  }
].each do |ri|
  RecipeIngredient.find_or_create_by!(diet: diet_cat_adult, ingredient: ri[:ingredient]) do |r|
    r.base_percentage = ri[:base_percentage]
    r.is_supplement   = ri[:is_supplement]
  end
end

# Recipe 3: Puppy / kitten all life stages (covers puppy dog + kitten cat via all_life_stages)
diet_growth = Diet.find_or_create_by!(name: "Dieta Crecimiento Universal") do |r|
  r.description       = "Dieta para cachorros y gatitos en etapa de crecimiento"
  r.preparation_notes = "Alta densidad energética y proteica. Dividir en 3–4 porciones al día. Asegurarse de que el pollo esté completamente cocido."
  r.species           = "dog"
  r.life_stage        = "puppy"
  r.status            = "active"
end

[
  { ingredient: chicken_rice, base_percentage: 55, is_supplement: false },
  { ingredient: sweet_potato, base_percentage: 20, is_supplement: false },
  { ingredient: egg,          base_percentage: 15, is_supplement: false },
  { ingredient: carrot,       base_percentage:  7, is_supplement: false },
  { ingredient: salmon_oil,   base_percentage:  3, is_supplement: true  }
].each do |ri|
  RecipeIngredient.find_or_create_by!(diet: diet_growth, ingredient: ri[:ingredient]) do |r|
    r.base_percentage = ri[:base_percentage]
    r.is_supplement   = ri[:is_supplement]
  end
end

# Recipe 4: Low-fat for pancreatitis / obesity
diet_low_fat = Diet.find_or_create_by!(name: "Dieta Baja en Grasa Perro") do |r|
  r.description       = "Dieta para perros con pancreatitis o sobrepeso"
  r.preparation_notes = "Proteínas muy magras, sin aceites adicionales. Porciones controladas. Evitar premios altos en grasa."
  r.species           = "dog"
  r.life_stage        = "adult"
  r.status            = "active"
end

turkey_ing = Ingredient.find_by!(name: "Pavo molido cocido")
[
  { ingredient: turkey_ing,   base_percentage: 45, is_supplement: false },
  { ingredient: rice,         base_percentage: 30, is_supplement: false },
  { ingredient: sweet_potato, base_percentage: 15, is_supplement: false },
  { ingredient: zucchini,     base_percentage: 10, is_supplement: false }
].each do |ri|
  RecipeIngredient.find_or_create_by!(diet: diet_low_fat, ingredient: ri[:ingredient]) do |r|
    r.base_percentage = ri[:base_percentage]
    r.is_supplement   = ri[:is_supplement]
  end
end

# Link recipe contraindications: low-fat recipe is NOT for healthy dogs
# (no contraindications to add here — it IS good for pancreatitis/obesity)
# Link chicken-based recipes as contraindicated for chicken allergen
chicken_allergen = Allergen.find_by!(name: "Pollo")
[diet_dog_adult, diet_growth].each do |diet|
  RecipeContraindicatedAllergen.find_or_create_by!(diet: diet, allergen: chicken_allergen) do |r|
    r.reason = "La receta contiene pollo como ingrediente principal"
  end
end

puts "Seeded #{Diet.count} diets with ingredients and contraindications"
puts "\n=== Seed complete ==="
