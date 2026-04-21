class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string     :thinking_topic, null: false
      t.text       :thinking_diffusion
      t.string     :thinking_core
      t.text       :thinking_output
      t.integer    :status, null: false, default: 0 

      t.timestamps
    end
  end
end
