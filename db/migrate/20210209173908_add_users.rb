class AddUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.text :email
      t.text :state
      t.text :password
    end

    add_index :users, :email, unique: true
  end
end
