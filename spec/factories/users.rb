# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user  do |f|
    f.password "12312311"
    f.password_confirmation { "12312311" }
    f.email { Faker::Internet.email }
  end
end
