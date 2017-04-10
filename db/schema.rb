# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161101218292) do

  create_table "account_managers", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "account_managers", ["account_id"], name: "fk_rails_86d1b0ba87", using: :btree
  add_index "account_managers", ["user_id"], name: "fk_rails_422622ed57", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.string   "account_uuid", limit: 255, null: false
    t.string   "site_name",    limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["site_name"], name: "index_accounts_on_site_name", unique: true, using: :btree

  create_table "face_match_results", force: :cascade do |t|
    t.string   "image_file_name",         limit: 255
    t.string   "image_content_type",      limit: 255
    t.integer  "image_file_size",         limit: 4
    t.datetime "image_updated_at"
    t.integer  "user_id",                 limit: 4
    t.integer  "is_processing_completed", limit: 4,   default: 0
    t.integer  "is_error",                limit: 4
    t.string   "error_code",              limit: 255
    t.integer  "match_completed_at",      limit: 4
    t.string   "face_match_result_uuid",  limit: 255,             null: false
    t.string   "image_sha256",            limit: 255,             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "face_match_results", ["face_match_result_uuid"], name: "index_face_match_results_on_face_match_result_uuid", unique: true, using: :btree
  add_index "face_match_results", ["image_sha256"], name: "index_face_match_results_on_image_sha256", using: :btree
  add_index "face_match_results", ["user_id"], name: "fk_rails_e52175fbb7", using: :btree

  create_table "face_matches", force: :cascade do |t|
    t.string   "image_file_name",                   limit: 255, null: false
    t.string   "image_content_type",                limit: 255, null: false
    t.integer  "image_file_size",                   limit: 4,   null: false
    t.datetime "image_updated_at",                              null: false
    t.integer  "face_match_result_id",              limit: 4,   null: false
    t.integer  "matched_with_face_match_result_id", limit: 4,   null: false
    t.integer  "score_percent",                     limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "face_matches", ["face_match_result_id"], name: "fk_rails_f3f19febfa", using: :btree
  add_index "face_matches", ["matched_with_face_match_result_id"], name: "fk_rails_01c1098ec8", using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.string   "provider",           limit: 255
    t.string   "uid",                limit: 255
    t.string   "token",              limit: 255
    t.string   "secret",             limit: 255
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.string   "user_name",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["user_id"], name: "fk_rails_fc9fc8b828", using: :btree

  create_table "network_connections", force: :cascade do |t|
    t.string   "network",            limit: 255, null: false
    t.string   "uid",                limit: 255, null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.string   "handle",             limit: 255, null: false
    t.string   "token",              limit: 255
    t.string   "secret",             limit: 255
    t.string   "twitter_type",       limit: 255
    t.string   "twitter_dest",       limit: 255
    t.string   "facebook_type",      limit: 255
    t.string   "facebook_dest",      limit: 255
    t.integer  "connection_ok",      limit: 4,   null: false
    t.string   "last_error",         limit: 255
    t.integer  "account_id",         limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "network_connections", ["account_id"], name: "fk_rails_50d1f3bba0", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "label",               limit: 255
    t.string   "post_type",           limit: 255,               null: false
    t.string   "headline",            limit: 255
    t.text     "body",                limit: 65535
    t.string   "image1_file_name",    limit: 255
    t.string   "image1_content_type", limit: 255
    t.integer  "image1_file_size",    limit: 4
    t.datetime "image1_updated_at"
    t.string   "image2_file_name",    limit: 255
    t.string   "image2_content_type", limit: 255
    t.integer  "image2_file_size",    limit: 4
    t.datetime "image2_updated_at"
    t.string   "image3_file_name",    limit: 255
    t.string   "image3_content_type", limit: 255
    t.integer  "image3_file_size",    limit: 4
    t.datetime "image3_updated_at"
    t.string   "image4_file_name",    limit: 255
    t.string   "image4_content_type", limit: 255
    t.integer  "image4_file_size",    limit: 4
    t.datetime "image4_updated_at"
    t.string   "link",                limit: 255
    t.integer  "is_featured",         limit: 4,     default: 0, null: false
    t.integer  "is_primary",          limit: 4,     default: 0, null: false
    t.integer  "user_id",             limit: 4,                 null: false
    t.string   "unique_key",          limit: 255,               null: false
    t.string   "unique_link",         limit: 255,               null: false
    t.integer  "product_id",          limit: 4
    t.integer  "published_at",        limit: 4,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["product_id"], name: "fk_rails_bac89a80b8", using: :btree
  add_index "posts", ["unique_key"], name: "index_posts_on_unique_key", unique: true, using: :btree
  add_index "posts", ["user_id", "unique_link"], name: "index_posts_on_user_id_and_unique_link", unique: true, using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name",        limit: 255,                 null: false
    t.string   "description", limit: 255
    t.integer  "price",       limit: 4,                   null: false
    t.string   "currency",    limit: 255, default: "USD", null: false
    t.integer  "quantity",    limit: 4,   default: -1,    null: false
    t.integer  "user_id",     limit: 4,                   null: false
    t.string   "unique_key",  limit: 255,                 null: false
    t.string   "unique_link", limit: 255,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["unique_key"], name: "index_products_on_unique_key", unique: true, using: :btree
  add_index "products", ["user_id", "unique_link"], name: "index_products_on_user_id_and_unique_link", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                             limit: 255, default: "", null: false
    t.string   "encrypted_password",                limit: 255, default: "", null: false
    t.string   "reset_password_token",              limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",                limit: 255
    t.string   "last_sign_in_ip",                   limit: 255
    t.string   "confirmation_token",                limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_real_name",                    limit: 255
    t.string   "user_name",                         limit: 255
    t.string   "image_file_name",                   limit: 255
    t.string   "image_content_type",                limit: 255
    t.integer  "image_file_size",                   limit: 4
    t.datetime "image_updated_at"
    t.string   "user_type",                         limit: 255
    t.string   "paypal_id_as_seller",               limit: 255
    t.string   "stripe_customer_id_as_buyer",       limit: 255
    t.string   "stripe_customer_id_as_seller",      limit: 255
    t.string   "stripe_customer_token_as_seller",   limit: 255
    t.string   "bitcoin_receive_address_as_seller", limit: 255
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "account_managers", "accounts", on_delete: :cascade
  add_foreign_key "account_managers", "users", on_delete: :cascade
  add_foreign_key "face_match_results", "users", on_delete: :cascade
  add_foreign_key "face_matches", "face_match_results", column: "matched_with_face_match_result_id", on_delete: :cascade
  add_foreign_key "face_matches", "face_match_results", on_delete: :cascade
  add_foreign_key "identities", "users", on_delete: :cascade
  add_foreign_key "network_connections", "accounts", on_delete: :cascade
  add_foreign_key "posts", "products"
  add_foreign_key "posts", "users", on_delete: :cascade
  add_foreign_key "products", "users", on_delete: :cascade
end
