class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, :null => false
      t.string :description, :null => true
      t.integer :price, :null => false
      t.string :currency, :null => false, :default => 'USD'
      t.integer :quantity, :null => false, :default => -1
      t.integer :user_id, :null => false
      t.string :unique_key, :null => false
      t.string :unique_link, :null => false
      t.timestamps
    end
    add_foreign_key :products, :users, :on_delete => :cascade
    add_index :products, :unique_key, :unique => true
    add_index :products, [:user_id, :unique_link], :unique => true
  end
end
