require 'hyperkit'
require 'logger'

# Class to provides methods regading Database
class Lxd
  attr_reader :api_endpoint

  # Returns a new instance of Lxd
  # @param api_endpoint [String] The base URL for API requests
  # @param client_cert [String] The client certificate used to authenticate to the LXD server.
  # @param client_key [String] The client key used to authenticate to the LXD server.
  # @param loglevel [String] The loglevel
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

  # Create the conenction object
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

  # Returns a list of containers from LXD host
  # @return [Array]
  def get_containers
    @logger.debug "#{@client.api_endpoint} - Listing containers: #{@client.containers}"
    @client.containers
  rescue StandardError => e
    @logger.error "#{@client.api_endpoint} - Unable to get containers: #{e}"
    []
  end

  # Return the information about a container
  # @param container [String] The container's name
  # @return [Hash]
  def get_container_info(container)
    @logger.debug "#{@client.api_endpoint} - Container info: #{@client.container(container).to_h}"
    @client.container(container).to_h
  rescue StandardError => e
    @logger.error "#{@client.api_endpoint} - Unable to get container info: #{e}"
    {}
  end

  # Return container state information
  # @param container [String] The container's name
  # @return [Hash]
  def get_container_state(container)
    @logger.debug "#{@client.api_endpoint} - Container state: #{@client.container_state(container).to_h}"
    @client.container_state(container).to_h
  rescue StandardError => e
    @logger.error "#{@client.api_endpoint} - Unable to get container state: #{e}"
    {}
  end
end
