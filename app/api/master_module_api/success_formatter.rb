module MasterModuleApi::SuccessFormatter
  class << self
    def call(message, _env)
      message.to_json
    end
  end
end
