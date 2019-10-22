## Bolt Vault plugin

This module provides a plugin which allows config values to be set by accessing secrets from a
Key/Value engine on a Vault server.

#### Table of Contents

1. [Requirements](#requirements)
2. [Usage](#usage)
3. [Examples](#examples)

## Requirements

You will need to have a Vault server running, and a way to [authenticate](#authentication-methods) with the server

## Usage

The Vault plugin supports several options:
- `server_url`: The URL of the Vault server (optional, defaults to `ENV['VAULT_ADDR']`)
- `auth`: The method for authorizing with the Vault server and any necessary parameters (optional, defaults to `ENV['VAULT_TOKEN']`)
- `path`: The path to the secrets engine (required)
- `field`: The specific secret being used (optional, defaults to a Ruby hash of all secrets at the `path`)
- `version`: The version of the K/V engine (optional, defaults to 1)

If Vault server uses TLS, you can use the following config to authenticate with the server:
- `cacert`: Path to the CA certificate (optional)
- `cert`: Path to the SSL certificate (optional)
- `key`: Path to the SSL key (optional)

### Authentication Methods

Vault requires a token to assign an identity and set of policies to a user before accessing secrets.
The Vault plugin offers 2 authentication methods:

#### Token

Authenticate using a token. This method requires the following fields:

-   `method`: The value of `method` must be `token`
-   `token`: The token to authenticate with

#### Userpass

Request a token by logging into the Vault server with a username and password. This method requires
the following fields:

-   `method`: The value of `method` must be `userpass`
-   `user`: The username
-   `pass`: The password

## Examples

You can add any Vault plugin field to the inventory configuration. The following example shows how
you would access the `private-key` secret on a KVv2 engine mounted at `secrets/bolt`:

```
version: 2
targets:
  - ...
config:
  ssh:
    user: root
    private-key:
      key-data:
        _plugin: vault
        server_url: http://127.0.0.1:8200
        auth:
          method: userpass
          user: bolt
          pass: bolt
        path: secrets/bolt
        field: private-key
        version: 2
```

You can also set configuration in your [Bolt config file](https://puppet.com/docs/bolt/latest/configuring_bolt.html) 
under the `plugins` field. If a field is set in both the inventory file and the config file, Bolt
will use the value set in the inventory file. The available fields for the config file are:

-   `server_url`
-   `cacert`
-   `auth`

```
plugins:
  vault:
    server_url: https://127.0.0.1:8200
    cacert: /path/to/ca
    cert: /path/to/cert
    key: /path/to/key
    auth:
      method: token
      token: xxxxx-xxxxx
```
