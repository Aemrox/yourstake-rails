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

  # GET /companies/1 or /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies or /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        format.html { redirect_to company_url(@company), notice: "Company was successfully created." }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to company_url(@company), notice: "Company was successfully updated." }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1 or /companies/1.json
  def destroy
    @company.destroy

    respond_to do |format|
      format.html { redirect_to companies_url, notice: "Company was successfully destroyed." }
      format.json { head :no_content }
    end
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
