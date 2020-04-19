require 'hyperkit'
require 'logger'


class Lxd
  attr_reader :api_endpoint

  def initialize(api_endpoint, client_cert, client_key, loglevel="info")
    unless ENV['APP_ENV'] == 'test'
      @logger = Logger.new(STDOUT)
    else
      @logger = Logger.new('/dev/null')
    end
    @logger.level = loglevel
    @api_endpoint = 'https://' + api_endpoint
    @client_cert = client_cert
    @client_key = client_key
    self.connect
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
    begin
      # TODO: Find out why debug are being duplicated
      @logger.debug "#{@client.api_endpoint} - Listing containers: #{@client.containers}"
      @client.containers
    rescue => e
      @logger.error "#{@client.api_endpoint} - Unable to get containers: #{e}"
      Array.new
    end
  end

  def get_container_info(container)
    begin
      @logger.debug "#{@client.api_endpoint} - Container info: #{@client.container(container).to_h}"
      @client.container(container).to_h
    rescue => e
      @logger.error "#{@client.api_endpoint} - Unable to get container info: #{e}"
      Hash.new
    end
  end

  def get_container_state(container)
    begin
      @logger.debug "#{@client.api_endpoint} - Container state: #{@client.container_state(container).to_h}"
      @client.container_state(container).to_h
    rescue => e
      @logger.error "#{@client.api_endpoint} - Unable to get container state: #{e}"
      Hash.new
    end
  end
  
end