class CreateResetPasswordKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :reset_password_keys do |t|
      t.integer :user_id
      t.text    :key
      t.timestamps
    end

    add_index :reset_password_keys, :key, unique: true
  end
end
