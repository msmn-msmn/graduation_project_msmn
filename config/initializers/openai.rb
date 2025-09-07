OpenAI.configure do |config|
  key = ENV["OPENAI_API_KEY"] || Rails.application.credentials.dig(:openai, :api_key)
  config.access_token = key if key.present?
end
