# typed: false
# The boot helper to add custom configs to Rails.configuration
class BootHelper
  class BootError < StandardError; end

  def self.add_custom_boot_config_for(config)
    # raise BootError, 'CURRENT_INSTANCE nil' if @current_instance.nil?
    puts 'Loading custom boot config...'
    raise BootConfig, 'config nil' if config.nil?

    if ENV['CURRENT_INSTANCE'].nil?
      puts 'Attention: ENV not available, skipped init'
      return
    end

    @current_instance = ENV['CURRENT_INSTANCE'] || 'local'
    config.renderer = { foo: :bar, bar: 1 }
    basic_auth(config)
    lw_config(config)
  end

  def self.basic_auth(config)
    raise BootError, 'BASIC_AUTH_USERNAME nil' if ENV['BASIC_AUTH_USERNAME'].nil?

    config.basic_auth = {
      username: ENV['BASIC_AUTH_USERNAME'],
      password: ENV['BASIC_AUTH_PASSWORD']
    }
  end

  def self.lw_config(config)
    config.lw = {
      endpoint: Rails.application.credentials.dig(@current_instance.to_sym, :languagewire, :endpoint),
      user_agent: Rails.application.credentials.dig(@current_instance.to_sym, :languagewire, :user_agent)
    }
    config.lw[:secret] = Rails.env.production? ? ENV['Rails.configuration.lw[:secret]'] : Rails.application.credentials.dig(@current_instance.to_sym, :languagewire, :secret)
    # Locally use prod key
    config.lw[:secret] = ENV['LW_SECRET']
    raise BootError, 'lw stuff nil' if config.lw[:secret].nil? || config.lw[:endpoint].nil? || config.lw[:user_agent].nil?
  end
end
