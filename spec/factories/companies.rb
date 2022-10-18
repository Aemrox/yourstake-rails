FactoryBot.define do
  factory :company do
    company_name { "MyCompany" }
    ticker_symbol { "MC" }
    animal_testing { false }
    nuclear_weapons { false }
    coal_power { false }
    rainforest_destruction { false }
  end
end