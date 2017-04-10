# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account_manager do |f|
    account
    user
  end
end
