class CreateFaceMatchResults< ActiveRecord::Migration
  def change
    create_table :face_match_results do |t|
      t.attachment :image, :null => true
      t.integer :user_id, :null => true
      t.integer :is_processing_completed, :default => 0
      t.integer :is_error
      t.string :error_code
      t.integer :match_completed_at
      t.string :face_match_result_uuid, :null => false
      t.string :image_sha256, :null => false
      t.timestamps
    end
    add_foreign_key :face_match_results, :users, :on_delete => :cascade
    add_index :face_match_results, :face_match_result_uuid, :unique => true
    add_index :face_match_results, :image_sha256, :unique => false
  end
end
