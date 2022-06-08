module MasterModuleApi::ErrorFormatter
  class << self
    def call(message, backtrace, _options, _env, _)
      if message.is_a?(Hash)
        errors = message[:error_message]
        if errors.is_a?(Array)
          errors = errors.first.values if errors.first.is_a?(Hash)
          errors = errors.join('; ')
        end
        { errors: errors }.to_json
      else
        e = Exception.new(message)
        e.set_backtrace(backtrace)
        Airbrake.notify e
        error_message = e.message
        [error_message].flatten.to_json
      end
    end
  end
end
