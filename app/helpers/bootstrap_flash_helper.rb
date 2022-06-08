module BootstrapFlashHelper
  ALERT_TYPES = [:error, :info, :success, :warning] unless const_defined?(:ALERT_TYPES)

  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = type.to_sym
      type = :success if type == :notice
      type = :error   if type == :alert
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = "<div class='alert fade in alert-#{type} sign-in--alert-popup--message'}>
          <span class='size-16'>#{msg}</span>
          <span class='close close--button top-0' data-id='login-flash-alert-close-id'>&times;</span>
        </div>"

        flash_messages << text if msg
      end
    end
    sanitize flash_messages.join("\n")
  end
end
