class AddUserProfileFields < ActiveRecord::Migration
  def change
    add_attachment :users, :image
    add_column :users, :user_type, :string # END_CUSTOMER, FULL_USER
  end
end
