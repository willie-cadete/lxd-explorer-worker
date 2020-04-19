require 'logger'
require 'redis'

class Database
  def initialize(host, port = 6379, loglevel = 'info')
    @logger = if ENV['APP_ENV'] == 'test'
                Logger.new('/dev/null')
              else
                Logger.new(STDOUT)
              end
    @logger.level = loglevel
    @host = host
    @port = port
    connect
  end

  def connect
    @client = Redis.new(host: @host, port: @port)
    @logger.info("Connecting to database #{@host}:#{@port}")
  end

  def save_container(name, expire, **data)
    data.each do |k, v|
      @client.hset(name, k, v)
      @client.expire(name, expire)
      @logger.debug("Saving container: #{name} with fields #{data.keys} and expire set to #{expire}")
    end
    @logger.debug('Container data has been saved to database')
  rescue StandardError => e
    @logger.error(" Unable to save the to database: #{e} ")
  end
end
