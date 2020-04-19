require 'logger'
require 'redis'

class Database

  def initialize(host, port=6379,loglevel='info')
    unless ENV['APP_ENV'] == 'test'
      @logger = Logger.new(STDOUT)
    else
      @logger = Logger.new('/dev/null')
    end
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