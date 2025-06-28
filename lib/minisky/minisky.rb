require 'yaml'

class Minisky
  attr_reader :host, :config

  def initialize(host, config_file_or_hash, options = {})
    @host = host

    case config_file_or_hash
    when String
      @config_file = config_file_or_hash
      @config = YAML.load(File.read(@config_file))
    when Hash
      @config = config_file_or_hash
    when nil
      @config = {}
      @send_auth_headers = false
      @auto_manage_tokens = false
    else
      raise ArgumentError.new('must pass config file path or hash')
    end

    if @config.any?
      if user.id.nil? || user.pass.nil?
        raise AuthError, "Missing user id or password #{user.id} #{user.pass}"
      end
    end

    if active_repl?
      @default_progress = '.'
    end

    if options
      options.each do |k, v|
        self.send("#{k}=", v)
      end
    end
  end

  def active_repl?
    return true if defined?(IRB) && IRB.respond_to?(:CurrentContext) && IRB.CurrentContext
    return true if defined?(Pry) && Pry.respond_to?(:cli) && Pry.cli
    false
  end

  def save_config
    File.write(@config_file, YAML.dump(@config)) if @config_file
  end
end

require_relative 'requests'
