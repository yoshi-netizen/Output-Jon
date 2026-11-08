class ChangeEmailToNullableInUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :email, true
    change_column_default :users, :email, from: "", to: nil
  end
end
