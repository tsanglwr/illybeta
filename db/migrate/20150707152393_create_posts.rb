class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :label, :null => true
      t.string :post_type, :null => false # TEXT, PHOTOS, VIDEO, LINK
      t.string :headline, :null => true
      t.text :body, :null => true
      t.attachment :image1, :null => true
      t.attachment :image2, :null => true
      t.attachment :image3, :null => true
      t.attachment :image4, :null => true
      t.string :link, :null => true
      t.integer :is_featured, :null => false, :default => 0
      t.integer :is_primary, :null => false, :default => 0
      t.integer :user_id, :null => false
      t.string :unique_key, :null => false
      t.string :unique_link, :null => false
      t.integer :product_id, :null => true
      t.integer :published_at, :null => false
      t.timestamps
    end
    add_foreign_key :posts, :users, :on_delete => :cascade
    add_foreign_key :posts, :products
    add_index :posts, :unique_key, :unique => true
    add_index :posts, [:user_id, :unique_link], :unique => true
  end
end
