# LXD Explorer - Worker

A simple service to gather information about containers from LXD servers and store into Redis. 

## Instalation

This application works with [docker](https://docs.docker.com/engine/install/) and [docker-compose](https://docs.docker.com/compose/install/), please following the Docker documentation to install it.

## Usage

To get started, you'll need to first enable the HTTPS API on your LXD server:

```bash
$ lxc config set core.https_address 127.0.0.1
```

To listen on all interfaces, replace 127.0.0.1 with 0.0.0.0.

### Authentication

The LXD API uses client-side certificates to authenticate clients.

You'll need to generate a certificate and private key. To do this, you might install OpenSSL and issue the following commands:

```bash
mkdir -p keys
openssl req -x509 -newkey rsa:2048 -keyout keys/client.key.secure -out keys/client.crt -days 3650
openssl rsa -in keys/client.key.secure -out keys/client.key
```

### Trusting on the certificate

You might set a password to LXD API.

```bash
$ lxc config set core.trust_password secret
```

And trust in your generated certificates.

```bash
$ curl -s -k --cert keys/client.crt --key keys/client.key https://127.0.0.1:8443/1.0/certificates -X POST -d '{"type": "client", "password": "secret"}' | jq .
{
 "type": "sync",
 "status": "Success",
 "status_code": 200,
 "metadata": {}
}
```

Alternatively, you can simply copy your certificate file to the LXD server and use the lxc tool to trust it:

```bash
lxd-server$ lxc config trust add my-new-cert.crt
```

### Configuration

The configuration use the `Environment variables` of docker-compose.yml file.

You might look at docker-compose documentation.
https://docs.docker.com/compose/environment-variables/

```bash
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - LOG_LEVEL=info
      #interval to gather the information from LXD hosts in seconds
      - INTERVAL=60
      # By default the enpoint use HTTPS at 8443 port, if you are using a different setting you must add the scheme and port to URL
      - LXD_HOSTS=lxd1.example.com,https://lxd2.example.com:8000
      - CLIENT_CERT=keys/client.crt
      - CLIENT_KEY=keys/client.key
```

### Starting the Application

```bash
$ cp docker-compose.yml.example docker-compose.yml
$ docker-compose up -d
$ docker-compose logs -f
```

## Contributing
Pull requests are welcome.

## License
The application is available as open source under the terms of the [MIT](https://choosealicense.com/licenses/mit/) License.