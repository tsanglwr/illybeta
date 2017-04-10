class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_real_name, :string
    add_column :users, :user_name, :string
  end
end
