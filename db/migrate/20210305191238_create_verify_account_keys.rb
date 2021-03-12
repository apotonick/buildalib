class CreateVerifyAccountKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :verify_account_keys do |t|
      t.integer :user_id
      t.text    :key
      t.timestamps
    end

    add_index :verify_account_keys, :key, unique: true
  end
end
