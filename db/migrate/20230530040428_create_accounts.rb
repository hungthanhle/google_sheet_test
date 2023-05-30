class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts, { :id => false } do |t|
      ## Required
      t.string :id, null: false, unique: true
      t.string :provider, :null => false, :default => "email"
      t.string :uid, :null => false, :default => ""

      ## Database authenticatable
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.boolean :allow_password_change, :default => false

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## User Info

      t.string :name, null: false
      t.integer :gender, null: false
      t.date :date_of_birth, null: false
      t.string :phone_number, null: false
      t.string :address, null: false
      t.integer :status, null: false
      t.integer :position, null: false
      t.integer :contract, null: false
      t.string :slack_token, null: false
      t.integer :role, null: false
      t.date :date, null: false
      t.string :identity_card, null: false
      t.date :date_of_issue
      t.string :place_of_issue
      ## Tokens
      t.text :tokens
      t.timestamps null: false
    end
    # execute "ALTER TABLE accounts ADD PRIMARY KEY (id);"
    change_table :accounts, bulk: true do |t|
      t.index :email, unique: true
      t.index [:uid, :provider], unique: true
      t.index :reset_password_token, unique: true
      # t.index :confirmation_token,   unique: true
      # t.index :unlock_token,         unique: true
    end
  end
end
