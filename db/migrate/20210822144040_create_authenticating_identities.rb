class CreateAuthenticatingIdentities < ActiveRecord::Migration[6.1]
  def change
    create_table :authenticating_identities, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :salt

      t.string :provider, null: false
      t.string :uid, null: false

      t.string :token_ciphertext
      t.string :refresh_token_ciphertext
      t.string :email_ciphertext
      t.text :auth_data_ciphertext

      t.string :locale
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :name

      t.datetime :token_expires_at
      t.timestamps
    end

    add_index :authenticating_identities, :salt, unique: true
  end
end
