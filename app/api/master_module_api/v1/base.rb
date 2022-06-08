class MasterModuleApi::V1::Base < Grape::API
  version :v1, using: :path
  default_format :json
  format :json
  formatter :json, SuccessFormatter
  error_formatter :json, ErrorFormatter
  prefix :api

  before do
    check_auth
  end

  helpers do
    def warden
      env['warden']
    end

    def check_auth
      raise_error(401, 'Unauthorized', {}, "#{request.base_url}/users/sign_in") unless warden.authenticated?(:user)
    end

    def current_user
      @current_user ||= warden.user(:user)
    end

    def declared_params
      declared(params, include_missing: false)
    end

    def master_cabinet?
      params[:master].eql?('true') || params.dig(:user, :master_cabinet).eql?('true')
    end

    def respond_with(interactor_klass, entity = nil)
      Rails.logger.info ActiveSupport::LogSubscriber.new.send(:color, "Processing by #{interactor_klass.name}#", :red)
      Rails.logger.info ActiveSupport::LogSubscriber.new.send(:color, "Rendering with #{entity&.name}", :red)

      interactor = interactor_klass.(
        current_user: current_user,
        headers: headers,
        request: request,
        params: declared_params.deep_symbolize_keys
      )

      redirect interactor.redirect_url                     if interactor.redirect_url.present?
      raise(interactor.exception, interactor.error)        if interactor.raise?
      raise_error(interactor.error_code, interactor.error) if interactor.failure?

      present(interactor.response, with: entity)
    rescue Mongoid::Errors::DocumentNotFound => e
      raise_error(404, document_not_found: e.message)
    end

    def raise_error(code, message, args = {}, redirect_uri = nil)
      redirect_uri = { 'Location' => redirect_uri } if redirect_uri
      error!({ error_code: code, error_message: message }.merge(args), code, redirect_uri)
    end
  end

  # mount Employees
  mount Vacations
  # mount VacationApproves

  route :any, '*path' do
    raise_error(404, 'Endpoint Not Found')
  end
end
