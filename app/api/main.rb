class Main < Grape::API
  mount MasterModuleApi::V1::Base
end
