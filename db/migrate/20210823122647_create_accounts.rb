class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :name
      t.string :salt
      t.boolean :personal, null: false, default: false

      t.timestamps
    end

    add_index :accounts, :personal
    add_index :accounts, :salt, unique: true
  end
end
