class Company < ApplicationRecord
  def self.search_by_name(company_name: "", ticker_symbol: "")
    Company.where('company_name like ?', "%#{company_name}%").where('ticker_symbol like ?', "%#{ticker_symbol}%")
  end

  def self.filter_by_issue(animal_testing: "", nuclear_weapons: "", coal_power: "", rainforest_destruction: "", companies: Company.all)
    # Rails Lazy loading builds up this query without execution
    companies = companies.where(animal_testing: animal_testing) unless ["", nil].include?(animal_testing)
    companies = companies.where(nuclear_weapons: nuclear_weapons) unless ["", nil].include?(nuclear_weapons)
    companies = companies.where(coal_power: coal_power) unless ["", nil].include?(coal_power)
    companies = companies.where(rainforest_destruction: rainforest_destruction) unless ["", nil].include?(rainforest_destruction)
    companies
  end

  def issues_exposed_to
    [animal_testing, nuclear_weapons, coal_power, rainforest_destruction].reduce(0) {|issues, field| field ? issues += 1 : issues }
  end
end
