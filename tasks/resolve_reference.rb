#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require 'json'
require 'net/http'
require 'openssl'

class Vault < TaskHelper
  class VaultHTTPError < TaskHelper::Error
    def initialize(response)
      err = JSON.parse(response.body)['errors']
      m = String.new("#{response.code} \"#{response.msg}\"")
      m << ": #{err.join(';')}" unless err.nil?
      super(m, 'bolt.plugin/vault-http-error')
    end
  end

  class ValidationError < TaskHelper::Error
    def initialize(m)
      super(m, 'bolt.plugin/validation-error')
    end
  end

  # Default header for all requests, including auth methods
  DEFAULT_HEADER = {
    "Content-Type" => "application/json",
    "Accept" => "application/json"
  }.freeze

  def validate_options(opts)
    %i[server_url path].each do |key|
      unless opts[key]
        raise ValidationError, "Vault plugin requires #{key} to be configured"
      end
    end
  end

  def task(opts)
    # Precedence: Inventory overrides config overrides env
    env_opts = {
      server_url: ENV['VAULT_ADDR'],
      cacert: ENV['VAULT_CACERT']
    }

    env_opts = env_opts.merge(auth: { method: 'token', token: ENV['VAULT_TOKEN'] }) if ENV['VAULT_TOKEN']
    merged = env_opts.merge(opts)

    validate_options(merged)
    header = {
      "X-Vault-Token" => merged.fetch(:auth, nil) ? request_token(merged[:auth], merged) : nil
    }

    # Handle the different versions of the API
    if merged[:version] == 2
      mount, store = merged[:path].split('/', 2)
      merged[:path] = [mount, 'data', store].join('/')
    end

    response = request(:Get, get_uri(merged), merged, header: header)
    { "value" => parse_response(response, merged) }
  end

  # Request uri - built up from Vault server url and secrets path
  def get_uri(opts, path = nil)
    path ||= opts[:path]
    URI.parse(File.join(opts[:server_url], "v1", path))
  end

  # Configure the http/s client
  def get_client(uri, opts)
    client = Net::HTTP.new(uri.host, uri.port)

    if uri.scheme == 'https'
      cacert = opts[:cacert]
      unless cacert
        raise ValidationError, "Vault plugin requires cacert to be configured when connecting over https"
      end
      client.use_ssl = true
      client.ssl_version = :TLSv1_2
      client.ca_file = cacert
      client.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    client
  end

  def request(verb, uri, opts, data: nil, header: {})
    # Add on any header options
    header = DEFAULT_HEADER.merge(header)

    # Create the HTTP request
    client = get_client(uri, opts)
    request = Net::HTTP.const_get(verb).new(uri.request_uri, header)

    # Attach any data
    request.body = data if data

    # Send the request
    begin
      response = client.request(request)
    rescue StandardError => e
      raise TaskHelper::Error.new(
        "Failed to connect to #{uri}: #{e.message}",
        'CONNECT_ERROR'
      )
    end

    case response
    when Net::HTTPOK
      JSON.parse(response.body)
    else
      raise VaultHTTPError, response
    end
  end

  def parse_response(response, opts)
    data = case opts[:version]
           when 2
             response['data']['data']
           else
             response['data']
           end

    if opts[:field]
      unless data[opts[:field]]
        raise ValidationError, "Unknown secrets field: #{opts[:field]}"
      end
      data[opts[:field]]
    else
      data
    end
  end

  # Request a token from Vault using one of the auth methods
  def request_token(auth, opts)
    case auth[:method]
    when 'token'
      auth_token(auth)
    when 'userpass'
      auth_userpass(auth, opts)
    else
      raise ValidationError, "Unknown auth method: #{auth[:method]}"
    end
  end

  def validate_auth(auth, required_keys)
    required_keys.each do |key|
      next if auth[key]
      raise ValidationError, "Expected key in #{auth[:method]} auth method: #{key}"
    end
  end

  # Authenticate with Vault using the 'Token' auth method
  def auth_token(auth)
    validate_auth(auth, %i[token])
    auth[:token]
  end

  # Authenticate with Vault using the 'Userpass' auth method
  def auth_userpass(auth, opts)
    validate_auth(auth, %i[user pass])
    path = "auth/userpass/login/#{auth[:user]}"
    uri = get_uri(opts, path)
    data = { "password" => auth[:pass] }.to_json

    request(:Post, uri, opts, data: data)['auth']['client_token']
  end
end

Vault.run if $PROGRAM_NAME == __FILE__
