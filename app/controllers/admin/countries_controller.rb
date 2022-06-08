class Admin::CountriesController < ApplicationController

  before_action :require_login
  before_action :for_hr
  before_action :set_country, except: [:index, :new, :create]
  # before_action :set_modifier, only: [:destroy]

  layout "admin"

  def index
    @countries = Country.all.order_by(name: :asc)
  end

  def new
    @country = Country.new
  end

  def create
    @country = Country.new(country_params)
    if @country.save
      redirect_to action: 'index'
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.json { render json: @country.errors, status: :unprocessable_entity }
      end
    end

  end

  def edit

  end

  def update
    if @country.update(country_params)
      redirect_to action: 'index'
    else
      respond_to do |format|
        format.html {render action: 'edit'}
        format.json {render json: @country.errors, status: :unprocessable_entity}
      end
    end
  end

  private

  def set_country
    @country = Country.find(params[:id])
  end

  def country_params
    params.require(:country).permit(:name, :vacation_days_per_year, :sick_days_per_year,
                                    offices_attributes: [:id, :name, :_destroy],
                                    holidays_attributes: [:id, :date, :title, :done, :_destroy])

  end

  def set_modifier
    @country.update(modifier: current_user)
  end

end