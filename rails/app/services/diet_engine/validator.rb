module DietEngine
  class Validator
    MICRO_REQUIREMENTS_PER_1000_KCAL = {
      calcium_mg: 1250.0,
      phosphorus_mg: 1000.0,
      magnesium_mg: 150.0,
      potassium_mg: 1500.0,
      zinc_mg: 20.0,
      iron_mg: 15.0,
      copper_mg: 1.5,
      iodine_mcg: 220.0,
      selenium_mcg: 80.0
    }.freeze

    MICRO_LABELS = {
      calcium_mg: "Calcio",
      phosphorus_mg: "Fosforo",
      magnesium_mg: "Magnesio",
      potassium_mg: "Potasio",
      zinc_mg: "Zinc",
      iron_mg: "Hierro",
      copper_mg: "Cobre",
      iodine_mcg: "Yodo",
      selenium_mcg: "Selenio"
    }.freeze

    FAT_KCAL_MAX_PCT = 25.0
    FIBER_DM_MIN_PCT = 2.0
    FIBER_DM_MAX_PCT = 4.0
    CA_P_MIN_RATIO = 1.1
    CA_P_MAX_RATIO = 1.4
    CA_P_TOLERANCE = 0.005

    def initialize(total_kcal_set:)
      @total_kcal_set = total_kcal_set.to_f
    end

    def validate(metrics)
      failures = []
      micros_target = micro_targets

      if metrics[:fat_kcal_pct].to_f > FAT_KCAL_MAX_PCT
        failures << "Fallo en grasa: #{metrics[:fat_kcal_pct].round(2)}% kcal (max #{FAT_KCAL_MAX_PCT}%)"
      end

      fiber_pct_dm = metrics[:fiber_pct_dm].to_f
      if fiber_pct_dm < FIBER_DM_MIN_PCT || fiber_pct_dm > FIBER_DM_MAX_PCT
        failures << "Fallo en fibra: #{fiber_pct_dm.round(2)}% BMS (rango #{FIBER_DM_MIN_PCT}-#{FIBER_DM_MAX_PCT}%)"
      end

      ca_p_ratio = metrics[:ca_p_ratio].to_f
      if ca_p_ratio < (CA_P_MIN_RATIO - CA_P_TOLERANCE) || ca_p_ratio > (CA_P_MAX_RATIO + CA_P_TOLERANCE)
        failures << "Relacion Ca:P fuera de rango (#{ca_p_ratio.round(3)}; esperado #{CA_P_MIN_RATIO}-#{CA_P_MAX_RATIO})"
      end

      MICRO_REQUIREMENTS_PER_1000_KCAL.each_key do |key|
        observed = metrics[:micros].fetch(key, 0.0).to_f
        required = micros_target[key].to_f
        deficit = normalized_gap(key, required, observed)
        next unless deficit.positive?

        failures << "Fallo en #{MICRO_LABELS[key]}: faltan #{format_amount(deficit, unit_for(key))} (aportado #{format_amount(observed, unit_for(key))} de #{format_amount(required, unit_for(key))})"
      end

      {
        valid: failures.empty?,
        failures: failures,
        metrics: rounded_metrics(metrics),
        targets: rounded_metrics({ micros: micros_target })
      }
    end

    def deficits(metrics)
      target = micro_targets
      deficits = target.each_with_object({}) do |(key, required), hash|
        observed = metrics[:micros].fetch(key, 0.0).to_f
        hash[key] = normalized_gap(key, required, observed)
      end

      # Force Ca:P strict range by adding whichever mineral is missing to reach bounds.
      calcium_total = metrics[:micros][:calcium_mg].to_f + deficits[:calcium_mg].to_f
      phosphorus_total = metrics[:micros][:phosphorus_mg].to_f + deficits[:phosphorus_mg].to_f

      if phosphorus_total.positive?
        ratio = calcium_total / phosphorus_total

        if ratio < CA_P_MIN_RATIO
          deficits[:calcium_mg] += (CA_P_MIN_RATIO * phosphorus_total - calcium_total)
        elsif ratio > CA_P_MAX_RATIO
          deficits[:phosphorus_mg] += (calcium_total / CA_P_MAX_RATIO - phosphorus_total)
        end
      end

      deficits
    end

    def premix_payload(metrics)
      deficits(metrics)
        .transform_values { |value| value.to_f.round(4) }
        .reject { |_key, value| value <= 0.0 }
    end

    private

    def micro_targets
      factor = @total_kcal_set / 1000.0

      MICRO_REQUIREMENTS_PER_1000_KCAL.each_with_object({}) do |(key, value), hash|
        hash[key] = value * factor
      end
    end

    def rounded_metrics(metrics)
      rounded = {}
      metrics.each do |key, value|
        rounded[key] = if key == :micros
          value.transform_values { |inner| inner.to_f.round(4) }
        else
          value.to_f.round(4)
        end
      end
      rounded
    end

    def unit_for(key)
      key.to_s.end_with?("_mcg") ? "mcg" : "mg"
    end

    def format_amount(value, unit)
      rounded = value.to_f.round(unit == "mcg" ? 2 : 3)
      "#{rounded} #{unit}"
    end

    def normalized_gap(key, required, observed)
      gap = required.to_f - observed.to_f
      rounded_gap = gap.round(display_precision_for(key))
      rounded_gap.positive? ? rounded_gap : 0.0
    end

    def display_precision_for(key)
      unit_for(key) == "mcg" ? 2 : 3
    end
  end
end
