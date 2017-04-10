class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :account_uuid, :null => false
      t.string :site_name, :null => false
      t.timestamps
    end
    add_index :accounts, :site_name, :unique => true
  end
end
