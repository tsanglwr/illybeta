# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account  do |f|
    f.account_guid { Faker::Number.number(10) }
    f.site_name { Faker::Number.number(10) }
  end
end
