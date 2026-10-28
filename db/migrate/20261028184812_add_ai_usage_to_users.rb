class AddAiUsageToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :ai_usage_count, :integer, default: 0, null: false
    add_column :users, :ai_usage_date, :date
  end
end
