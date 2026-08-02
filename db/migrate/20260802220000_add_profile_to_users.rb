# frozen_string_literal: true

class AddProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string unless column_exists?(:users, :name)
    add_column :users, :role, :string, default: "member" unless column_exists?(:users, :role)
    add_column :users, :admin, :boolean, default: false, null: false unless column_exists?(:users, :admin)
  end
end
