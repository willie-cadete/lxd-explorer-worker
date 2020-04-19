require 'hyperkit'
require 'logger'

class Lxd
  attr_reader :api_endpoint

  def initialize(api_endpoint, client_cert, client_key, loglevel = 'info')
    @logger = if ENV['APP_ENV'] == 'test'
                Logger.new('/dev/null')
              else
                Logger.new(STDOUT)
              end
    @logger.level = loglevel
    @api_endpoint = 'https://' + api_endpoint
    @client_cert = client_cert
    @client_key = client_key
    connect
  end

  def connect
    @client = Hyperkit::Client.new(
      client_cert: @client_cert,
      client_key: @client_key,
      api_endpoint: @api_endpoint,
      verify_ssl: false
    )
    @logger.info "Connecting to endpoint: #{@client.api_endpoint}"
    @logger.info "TLS Authetntication: certificate=#{@client.client_cert} key=#{@client.client_key}"
    @logger.debug "Connection settings: #{@client.inspect}"
  end

  def get_containers
    @logger.debug "#{@client.api_endpoint} - Listing containers: #{@client.containers}"
    @client.containers
  rescue StandardError => e
    @logger.error "#{@client.api_endpoint} - Unable to get containers: #{e}"
    []
  end

  def get_container_info(container)
    @logger.debug "#{@client.api_endpoint} - Container info: #{@client.container(container).to_h}"
    @client.container(container).to_h
  rescue StandardError => e
    @logger.error "#{@client.api_endpoint} - Unable to get container info: #{e}"
    {}
  end

  def get_container_state(container)
    @logger.debug "#{@client.api_endpoint} - Container state: #{@client.container_state(container).to_h}"
    @client.container_state(container).to_h
  rescue StandardError => e
    @logger.error "#{@client.api_endpoint} - Unable to get container state: #{e}"
    {}
  end
end
