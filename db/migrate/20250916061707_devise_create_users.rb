# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TYPE user_status AS ENUM ('pending', 'approved', 'rejected');
      CREATE TYPE user_role AS ENUM ('trader', 'admin');
    SQL

    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
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
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.string :first_name,         null: false
      t.string :middle_name
      t.string :last_name,          null: false
      t.date :date_of_birth,        null: false
      t.string :mobile_no,          null: false

      t.string :address_line_01
      t.string :address_line_02
      t.string :city
      t.string :zip_code,           null: false

      t.references :country,     null: false, foreign_key: true

      t.column :user_status, :user_status, default: 'pending', null: false
      t.column :user_role, :user_role, default: 'trader', null: false

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true

    add_index :users, :mobile_no,            unique: true
    add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
    add_index :users, :user_status
    add_index :users, :user_role
    add_index :users, [ :user_status, :user_role ]  # Composite index if you query both together
  end

  def down
    # This tells Rails how to reverse the migration.
    drop_table :users

    execute <<-SQL
      DROP TYPE user_status;
      DROP TYPE user_role;
    SQL
  end
end
