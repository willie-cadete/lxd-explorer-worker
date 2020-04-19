require 'logger'
require 'json'

Dir['./lib/*.rb'].sort.each { |file| require file }

$stdout.sync = true

logger = Logger.new(STDOUT)
logger.info('Application has been started.')

servers = ENV['LXD_HOSTS'].split(',')

loop do
  servers.each do |s|
    lxd = Lxd.new(s, ENV['CLIENT_CERT'], ENV['CLIENT_KEY'], ENV['LOG_LEVEL'])
    redis = Database.new(ENV['REDIS_HOST'], ENV['REDIS_PORT'], ENV['LOG_LEVEL'])

    lxd.get_containers.each do |container|
      redis.save_container(
        "lxd:#{URI.parse(lxd.api_endpoint).hostname}:#{container}",
        ENV['INTERVAL'].to_i + 60,
        info: lxd.get_container_info(container).to_json,
        state: lxd.get_container_state(container).to_json
      )
    end
    logger.info('Containers data have been saved')
  end

  sleep ENV['INTERVAL'].to_i
end

logger.info('Application has been finished.')