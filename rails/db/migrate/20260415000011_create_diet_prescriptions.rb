class CreateDietPrescriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :diet_prescriptions do |t|
      t.references :pet, null: false, foreign_key: true
      t.references :nutritional_standard, null: false, foreign_key: true
      t.references :master_recipe, null: false, foreign_key: true
      # Engine calculation outputs
      t.decimal :der_kcal, precision: 8, scale: 2, null: false   # daily energy requirement
      t.decimal :daily_portion_g, precision: 8, scale: 2, null: false  # total grams per day
      # Full calculation traces stored as JSONB
      t.jsonb :engine_output, default: {}
      t.jsonb :llm_output, default: {}
      t.jsonb :final_output, default: {}
      t.jsonb :rejected_recipes, default: []  # [{name:, reason:}]
      # Workflow status
      t.string :status, default: "calculated", null: false  # calculated | ai_refined | needs_review
      t.string :llm_status                                  # pending | done | failed | nil (no LLM run)
      t.string :source, default: "engine", null: false      # engine | llm_refined

      t.timestamps
    end

    add_index :diet_prescriptions, :status
    add_index :diet_prescriptions, :engine_output, using: :gin
    add_index :diet_prescriptions, :final_output, using: :gin
  end
end
