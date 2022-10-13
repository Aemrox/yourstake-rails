class Company < ApplicationRecord
  def issues_exposed_to
    [animal_testing, nuclear_weapons, coal_power, rainforest_destruction].reduce(0) {|issues, field| field ? issues : issues += 1 }
  end
end
