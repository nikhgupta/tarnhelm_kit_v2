class CreateMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :invited_by, null: true, foreign_key: { to_table: :users }, type: :uuid

      t.string   :invitation_token
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.integer  :invitation_limit
      t.integer  :invitations_count, default: 0
      t.timestamps
    end

    remove_index :memberships, :account_id
    add_index :memberships, :invitation_token, unique: true
    add_index :memberships, [:account_id, :user_id], unique: true
  end
end
