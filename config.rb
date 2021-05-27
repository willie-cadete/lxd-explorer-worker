require 'yaml'

config = YAML.load(File.read("config.yaml"))

INTERVAL = config["app"]["interval"]
CLIENT_CERT = config["app"]["certs"]["certificate"]
CLIENT_KEY = config["app"]["certs"]["key"]
LOG_LEVEL = config["app"]["log"]["level"]
REDIS_HOST = config["app"]["redis"]["host"]
REDIS_PORT = config["app"]["redis"]["port"]
LXD_HOSTS = config["lxd_hosts"]
