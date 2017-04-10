class AddPaymentDetails < ActiveRecord::Migration
  def change
    add_column :users, :paypal_id_as_seller, :string
    add_column :users, :stripe_customer_id_as_buyer, :string
    add_column :users, :stripe_customer_id_as_seller, :string
    add_column :users, :stripe_customer_token_as_seller, :string
    add_column :users, :bitcoin_receive_address_as_seller, :string
  end
end
