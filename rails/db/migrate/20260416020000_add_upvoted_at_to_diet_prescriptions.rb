class AddUpvotedAtToDietPrescriptions < ActiveRecord::Migration[7.2]
  def change
    add_column :diet_prescriptions, :upvoted_at, :datetime
  end
end
