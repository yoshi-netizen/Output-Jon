class AddTermsAcceptedAtToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :terms_accepted_at, :datetime
  end
end
