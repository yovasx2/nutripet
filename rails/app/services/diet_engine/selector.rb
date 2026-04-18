module DietEngine
  class Selector
    CATEGORY_OFFSETS = {
      protein: 0,
      carb: 1,
      fat: 2,
      vegetable: 3
    }.freeze

    def initialize(pet:, diet_mode:)
      @pet = pet
      @diet_mode = diet_mode.to_s
      @master_lists = {}
    end

    def required_categories
      base = %i[protein fat vegetable]
      return base if @diet_mode == "raw"

      base.insert(1, :carb)
    end

    def master_list(category)
      @master_lists[category] ||= begin
        score_expr = <<~SQL.squish
          (
            COALESCE(digestibility, 5) * 0.40 +
            (10 - COALESCE(gas_risk, 5)) * 0.20 +
            COALESCE(stool_firming, 5) * 0.20 +
            COALESCE(omega3, 5) * 0.20
          )
        SQL

        scope = Ingredient.non_toxic.safe_for(@pet.species)
        scope = scope.raw_safe if @diet_mode == "raw"

        scope
          .where(category: category.to_s)
          .select("ingredients.*", "#{score_expr} AS score")
          .order(score: :desc, id: :asc)
      end
    end

    def build_slots(recipe_count:)
      slots = []

      (0...recipe_count).each do |recipe_idx|
        required_categories.each do |category|
          list = master_list(category).limit(200).to_a
          next if list.empty?

          base_pos = CATEGORY_OFFSETS.fetch(category, 0)
          position = (recipe_idx + base_pos) % list.size
          ingredient = list[position]

          slots << {
            recipe_index: recipe_idx,
            category: category,
            position: position,
            ingredient: ingredient,
            score: ingredient.respond_to?(:score) ? ingredient.score.to_f : 0.0
          }
        end
      end

      slots
    end

    def rotate_lowest_scored_slot!(slots)
      sorted = slots.sort_by { |slot| slot[:score].to_f }

      sorted.each do |slot|
        list = master_list(slot[:category]).limit(200).to_a
        next if list.empty?

        next_position = slot[:position].to_i + 1
        next if next_position >= list.length

        next_ingredient = list[next_position]
        slot[:position] = next_position
        slot[:ingredient] = next_ingredient
        slot[:score] = next_ingredient.respond_to?(:score) ? next_ingredient.score.to_f : 0.0
        return true
      end

      false
    end
  end
end
