class AddRemindDateToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :remind_date, :date
    add_index :posts, :remind_date
  end
end
