require 'rails_helper'

RSpec.describe Company, type: :model do
  before(:all) do
    create(:company, company_name: "Amon", ticker_symbol: "AMO", animal_testing: true, rainforest_destruction: true)
    create(:company, company_name: "Asmodeus", ticker_symbol: "ASM", animal_testing: true)
    create(:company, company_name: "Baal", ticker_symbol: "BAL", coal_power: true, nuclear_weapons: true)
    create(:company, company_name: "Behemoth", ticker_symbol: "BHM", coal_power: true)
    create(:company, company_name: "Gabriel", ticker_symbol: "GAB")
    create(:company, company_name: "Leviathan", ticker_symbol: "LVN", nuclear_weapons: true)
    create(:company, company_name: "Lucifer", ticker_symbol: "LUC", animal_testing: true, rainforest_destruction: true, coal_power: true, nuclear_weapons: true)
  end

  after(:all) do
    Company.delete_all
  end
  context "class methods" do
    describe ".search_by_name" do
      it "it will only return a lazily evaluated active record association" do
        expect(Company.search_by_name()).to be_a ActiveRecord::Relation
      end

      it "each item in the association will be a company" do
        companies = Company.search_by_name()
        companies.each do |company|
          expect(company).to be_a Company
        end
      end

      it "will return all companies when given no arguments" do
        expect(Company.search_by_name().count).to eq(7)
      end

      it "will only return companies that partially match the company name" do
        expect(Company.search_by_name(company_name: "mo").count).to eq(3)
      end

      it "will not be case sensitive in it's search" do
        expect(Company.search_by_name(company_name: "MO").count).to eq(3)
      end

      it "will only return companies that partially match the ticker symbol" do
        expect(Company.search_by_name(ticker_symbol: "l").count).to eq(3)
      end

      it "will only return companies that match both the company name and ticker symbol when given both" do
        expect(Company.search_by_name(company_name: "mo", ticker_symbol: "mo").count).to eq(1)
      end
    end

    describe ".filter_by_issue" do
      it "it will only return a lazily evaluated active record association" do
        expect(Company.filter_by_issue()).to be_a ActiveRecord::Relation
      end

      it "each item in the association will be a company" do
        companies = Company.filter_by_issue()
        companies.each do |company|
          expect(company).to be_a Company
        end
      end

      it "will return all companies when given no arguments" do
        expect(Company.filter_by_issue().count).to eq(7)
      end

      it "will return the subset of companies given if passed a list of companies with no filters" do
        subset = Company.first(5)
        expect(Company.filter_by_issue(companies: subset)).to eq(subset)
      end

      it "will filter companies by the issues passed in" do
        expect(Company.filter_by_issue(animal_testing: true).count).to eq(3)
        expect(Company.filter_by_issue(animal_testing: false).count).to eq(4)
        expect(Company.filter_by_issue(coal_power: true).count).to eq(3)
        expect(Company.filter_by_issue(coal_power: false).count).to eq(4)
        expect(Company.filter_by_issue(animal_testing: false, nuclear_weapons: false, coal_power: false, rainforest_destruction: false).first.company_name).to eq("Gabriel")
        expect(Company.filter_by_issue(animal_testing: true, nuclear_weapons: true, coal_power: true, rainforest_destruction: true).first.company_name).to eq("Lucifer")
      end
    end
  end

  context "instance_methods" do
    describe "#issues_exposed_to" do
      it "will return the correct count of number of issues areas that a company has as true" do
        amon = Company.find_by_company_name("Amon")
        expect(amon.issues_exposed_to).to eq(2)
        asmodeus = Company.find_by_company_name("Asmodeus")
        expect(asmodeus.issues_exposed_to).to eq(1)
        lucifer = Company.find_by_company_name("Lucifer")
        expect(lucifer.issues_exposed_to).to eq(4)
        gabriel = Company.find_by_company_name("Gabriel")
        expect(gabriel.issues_exposed_to).to eq(0)
      end
    end
  end
end
