class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show edit update destroy ]

  # GET /companies or /companies.json
  def index
    session['filter_parameters'] = {}
    @companies ||= Company.all
  end

  # GET /filter_companies
  def filter
    session['filter_parameters'] ||= {}
    filters = session['filter_parameters'].merge!(filter_params)

    @companies = Company.search_by_name(company_name: filters["company_name"], ticker_symbol: filters["ticker_symbol"])
    @companies = Company.filter_by_issue(
      animal_testing: filters["animal_testing"],
      nuclear_weapons: filters["nuclear_weapons"],
      coal_power: filters["coal_power"],
      rainforest_destruction: filters["rainforest_destruction"],
      companies: @companies
    )
    @companies = @companies.order("#{filters["column"]} #{filters["direction"]}")
    render(partial: 'companies', locals: { companies: @companies })
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.require(:company).permit(:company_name, :ticker_symbol, :animal_testing, :nuclear_weapons, :coal_power, :rainforest_destruction)
    end

    def filter_params
      params.permit(:company_name, :ticker_symbol, :animal_testing, :nuclear_weapons, :coal_power, :rainforest_destruction, :column, :direction)
    end
end
