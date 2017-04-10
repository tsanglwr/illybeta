class CreateFaceMatches < ActiveRecord::Migration
  def change
    create_table :face_matches do |t|
      t.attachment :image, :null => false
      t.integer :face_match_result_id, :null => false
      t.integer :matched_with_face_match_result_id, :null => false
      t.integer :score_percent, :null => false
      t.timestamps
    end
    add_foreign_key :face_matches, :face_match_results, :on_delete => :cascade
    add_foreign_key :face_matches, :face_match_results, :on_delete => :cascade, :column => :matched_with_face_match_result_id
  end
end
