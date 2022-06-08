require 'sidekiq/web'

HrModule::Application.routes.draw do
  constraints subdomain: ['mm', 'ppmm'] do
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.secrets[:sidekiq_user])) &
        Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.secrets[:sidekiq_password]))
    end if Rails.env.production?
    mount Sidekiq::Web => '/sidekiq'
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" unless Rails.env.production?

  mount Main => '/overtimes'

  get '/forbidden', to: 'application#forbidden'

  post 'jira/webhook' => 'jira#webhook'

  #devise_for :bookeepers

  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  devise_scope :user do
    get 'users/auth/:provider/callback', to: 'sessions#create'
  end

  devise_for :users, :controllers => {:sessions => 'sessions', :omniauth_callbacks => "omniauth_callbacks"}

  constraints subdomain: ['mm', 'ppmm'] do
    get "/" => redirect("/admin/employees")
  end
  constraints subdomain: 'masters' do
    get "/" => redirect("/manager/vacations?master=true&only_role=true")
  end

  get "/admin" => redirect("/admin/employees")
  get "/manager" => redirect("/manager/projects")

  namespace 'api' do
    namespace 'masters' do
      get 'index'
      get 'check_reminder_need'
      post 'list'
      post 'actual_loads'
      post 'charges'
      post 'working_days_number'
      post 'info'
      post 'projects'
      post 'time_tracking'
    end
  end

  namespace "manager" do

    resources :vacation_approve, only: [:index] do
      member do
        post 'approve'
        post 'reject'
        get 'comment_form'
      end
    end

    resources :overtime_approve, only: [:index, :update] do
      member do
        post 'approve'
        post 'dismiss'
        post 'edit'
        get 'approve_comment_form'
        get 'dismiss_comment_form'
        get 'revert_approve_status'
      end
      collection do
        get 'search' => 'overtime_approve#index_filters'
      end
    end

    resources :vacations, except: [:show, :edit, :update] do
      member do
        post 'approve'
        post 'reject'
      end
      collection do
        get 'vacation_days'
        get 'search' => 'vacations#index_filters'
        get 'export'
        get 'ajax_export'
      end
    end

    resources :overtimes, except: [:show] do
      member do
        get 'index'
        post 'edit'
        post 'hr_revert_approve_status'
        post 'approve'
        post 'dismiss'
      end
      collection do
        get 'report' => 'overtimes#report'
        get 'search' => 'overtimes#index_filters'
        get 'hr_dismiss_comment_form' => 'overtimes#hr_dismiss_comment_form'
        get 'hr_approve_comment_form' => 'overtimes#hr_approve_comment_form'
        post 'delete' => 'overtimes#delete'
        post 'export' => 'overtimes#export'
      end
    end

    resources :calendar, only: [:index] do
      collection do
        get 'search' => 'calendar#index_filters'
        get 'batch' => 'calendar#batch'
        get 'user_load_detailed/:user_id' => 'calendar#user_load_detailed'
        post 'next_month'
        post 'previous_month'
      end
    end

    get 'projects/' => 'projects#index'
    post 'projects/update_positions' => 'projects#update_positions'
    get 'projects/export' => 'projects#export'
    get 'projects/search' => 'projects#index_filters'
    post 'projects/' => 'projects#create', as: :create_project
    get 'projects/:id' => 'projects#show', as: :project
    get 'projects/:id/edit' => 'projects#edit', as: :edit_project
    put 'projects/:id' => 'projects#update', as: :update_project
    delete 'projects/:id' => 'projects#destroy', as: :destroy_project
    post 'projects/:project_id' => 'projects#create_load', as: :create_project_load
    put 'projects/load/:id' => 'projects#update_load', as: :update_project_load
    put 'projects/load/:id/level' => 'projects#update_load_level', as: :update_project_load_level
    post 'projects/load/:id/clear_date' => 'projects#clear_load_date'
    post 'projects/:id/clear_date' => 'projects#clear_project_date'
    get 'projects/load/:id/warning' => 'projects#load_warning', as: :load_warning
    delete 'projects/load/:id' => 'projects#destroy_load', as: :destroy_project_load
    post 'projects/:id/send_for_feedbacks' => 'projects#send_for_feedbacks', as: :send_for_feedbacks
  end

  namespace "admin" do
    resources :employees do
      collection do
        get 'search' => 'employees#index_filters'
        get 'employee_for_projects' => 'employees#employee_for_projects'
        delete 'clear_career_comment/:id' => 'employees#clear_career_comment'
        get 'update_template' => 'lawyer_info#update_template'
        get 'legal_documents' => 'lawyer_info#documents'
        get 'social_days_per_year'
        get 'offices' => 'employees#offices_list'
        get 'communities' => 'employees#get_division_communities'
        get 'positions' => 'employees#get_community_positions'
        get 'export' => 'employees#export'
      end
      member do
        get 'hardware_managments' => 'hardware_managments#edit'
        put 'hardware_managments/pc' => 'hardware_managments#attach_pc'
        put 'hardware_managments/hadware' => 'hardware_managments#attach_hardware'

        get 'autocomplete_hadware_model' => 'hardware_managments#autocomplete_hadware_model'
        get 'autocomplete_pc_model' => 'hardware_managments#autocomplete_pc_model'

        post 'remove_photo'

        get 'legal_info' => 'lawyer_info#legal_info'
        get 'legal_info_formatted' => 'lawyer_info#legal_info_formatted'

        post 'update_contract_status' => 'lawyer_info#update_contract_status'

        get 'edit_passport_info' => 'lawyer_info#edit_passport_info'
        post 'passport_info' => 'lawyer_info#update_passport_info'

        get 'edit_bank_info' => 'lawyer_info#edit_bank_info'
        post 'bank_info' => 'lawyer_info#update_bank_info'

        get 'generate_document' => 'lawyer_info#generate_document'
        get 'ajax_generate_document' => 'lawyer_info#ajax_generate_document'

        post 'send_onboarding_email' => 'employees#send_onboarding_email'
      end
    end

    resources :career_histories, only: [:destroy, :index]

    resources :countries
  end
  root :to => 'employees#index'
end
