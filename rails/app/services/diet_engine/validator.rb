# DietEngine::Validator
#
# Checks that calculated macro output meets the NutritionalStandard bounds.
# Returns a result struct: { passed: bool, errors: [], warnings: [] }

module DietEngine
  class Validator
    Result = Struct.new(:passed, :errors, :warnings, keyword_init: true) do
      def failed? = !passed
    end

    def initialize(standard, macro_summary, daily_portion_g)
      @standard        = standard
      @macros          = macro_summary
      @daily_portion_g = daily_portion_g.to_f
      @errors          = []
      @warnings        = []
    end

    def validate
      check_protein
      check_fat
      check_fiber
      check_energy

      Result.new(passed: @errors.empty?, errors: @errors, warnings: @warnings)
    end

    private

    def check_protein
      return unless @standard.protein_min_pct

      pct = dry_matter_pct(:protein_g)
      if pct < @standard.protein_min_pct
        @errors << "Protein #{pct.round(1)}% is below minimum #{@standard.protein_min_pct}%"
      elsif @standard.protein_max_pct && pct > @standard.protein_max_pct
        @warnings << "Protein #{pct.round(1)}% exceeds recommended maximum #{@standard.protein_max_pct}%"
      end
    end

    def check_fat
      return unless @standard.fat_min_pct

      pct = dry_matter_pct(:fat_g)
      if pct < @standard.fat_min_pct
        @errors << "Fat #{pct.round(1)}% is below minimum #{@standard.fat_min_pct}%"
      elsif @standard.fat_max_pct && pct > @standard.fat_max_pct
        @warnings << "Fat #{pct.round(1)}% exceeds recommended maximum #{@standard.fat_max_pct}%"
      end
    end

    def check_fiber
      return unless @standard.fiber_max_pct

      pct = dry_matter_pct(:fiber_g)
      if pct > @standard.fiber_max_pct
        @warnings << "Fiber #{pct.round(1)}% exceeds recommended maximum #{@standard.fiber_max_pct}%"
      end
    end

    def check_energy
      return unless @standard.energy_min_kcal_kg

      # Convert daily kcal to kcal/kg diet dry matter basis for comparison
      total_kcal = @macros[:energy_kcal].to_f
      if total_kcal < (@standard.energy_min_kcal_kg * @daily_portion_g / 1000.0)
        @errors << "Total energy #{total_kcal.round(0)} kcal/day may be below minimum for this standard"
      end
    end

    # Rough dry matter % calculation: nutrient_g / (total_g - moisture_g) * 100
    def dry_matter_pct(macro_key)
      total_nutrient_g = @macros[macro_key].to_f
      # Approximate moisture as 70% of as-fed for mixed diets; real value would come from sum of ingredient moisture
      dm_g = @daily_portion_g * 0.30
      return 0 if dm_g.zero?
      (total_nutrient_g / dm_g) * 100
    end
  end
end
