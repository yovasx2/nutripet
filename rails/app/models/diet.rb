class Diet < ApplicationRecord
  belongs_to :pet
  has_many :diet_items, dependent: :destroy
  has_many :ingredients, through: :diet_items

  PREP_STYLES = {
    "cooked" => "Cocida",
    "raw"    => "⚠️ Cruda (BARF)",
    "mixed"  => "⚠️ Mixta"
  }.freeze

  def prep_style_label
    PREP_STYLES.fetch(preparation_style, preparation_style)
  end

  def macros
    engine_output["macros"] || {}
  end

  def aafco
    engine_output["aafco"] || {}
  end

  def preparation_notes
    engine_output["preparation_notes"] || ""
  end
end
