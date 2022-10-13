class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :company_name
      t.string :ticker_symbol
      t.boolean :animal_testing
      t.boolean :nuclear_weapons
      t.boolean :coal_power
      t.boolean :rainforest_destruction

      t.timestamps
    end
  end
end
