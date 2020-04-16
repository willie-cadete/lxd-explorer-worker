require 'logger'
require 'hyperkit'
require 'redis'
require 'json'


$stdout.sync = true

logger = Logger.new(STDOUT)
logger.info("Application has been started.")


module LxdModule
  class Server
    def initialize(api_endpoint, client_cert, client_key, loglevel="info")
      @logger = Logger.new(STDOUT)
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
end

class Database

  def initialize(host, port=6379,loglevel='info')
    @logger = Logger.new(STDOUT)
    @logger.level = loglevel
    @host = host
    @port = port
    self.connect
  end

  def connect
    @client = Redis.new(host: @host, port: @port)
    @logger.info("Connecting to database #{@host}:#{@port}")
  end

  def save_container(name, expire, **data)
    begin
      data.each do |k,v|
        @client.hset(name, k, v)
        @client.expire(name, expire)
        @logger.debug("Saving container: #{name} with fields #{data.keys} and expire set to #{expire}")
      end
      @logger.debug("Container data has been saved to database")
    rescue => e
      @logger.error(" Unable to save the to database: #{e} ")
    end
  end
end

servers = ENV['LXD_HOSTS'].split(',')

while true
  
  servers.each do |s|
    lxd = LxdModule::Server.new(s,ENV['CLIENT_CERT'],ENV['CLIENT_KEY'],ENV['LOG_LEVEL'])
    redis = Database.new(ENV['REDIS_HOST'], ENV['REDIS_PORT'], ENV['LOG_LEVEL'])
    
    lxd.get_containers.each do |container|
      redis.save_container(
        "c:#{container}",
        ENV['INTERVAL'].to_i + 60,
        info: lxd.get_container_info(container).to_json,
        state: lxd.get_container_state(container).to_json
        )
    end
    logger.info("Containers data have been saved")
  end

  sleep ENV['INTERVAL'].to_i

end

logger.info("Application has been finished.")