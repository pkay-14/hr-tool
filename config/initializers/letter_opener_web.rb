unless Rails.env.production?
  LetterOpenerWeb.configure do |config|
    config.letters_location = Rails.root.join('sidekiq', 'letter_opener')
  end
end
