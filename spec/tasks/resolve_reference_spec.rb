# frozen_string_literal: true

require 'spec_helper'
require_relative '../../tasks/resolve_reference.rb'

describe Vault do
  let(:server_url) { 'http://127.0.0.1:8200' }
  let(:path) { 'foo/bar' }
  let(:secret) { 'bar' }

  let(:config) do
    {
      server_url: server_url,
      auth: {
        method: 'token',
        token: 'secret'
      },
      path: path,
      field: 'foo'
    }
  end

  let(:response) do
    {
      'data' => {
        'foo' => 'bar'
      }
    }
  end

  it 'errors when missing cacert and using https' do
    config[:server_url] = 'https://127.0.0.1:8200'
    uri = subject.get_uri(config)
    expect { subject.get_client(uri, config) }.to raise_error(Vault::ValidationError, /https/)
  end

  context 'when validating keys' do
    it 'errors when missing required inventory config key' do
      config.delete(:path)
      expect { subject.validate_options(config) }.to raise_error(Vault::ValidationError, /path/)
    end

    it 'errors when missing required auth method key' do
      config[:auth].delete(:token)
      expect { subject.validate_auth(config, %i[token]) }
        .to raise_error(Vault::ValidationError, /token/)
    end

    it 'errors when using unknown auth method' do
      auth = config[:auth]
      auth[:method] = 'foo'
      expect { subject.request_token(auth, config) }.to raise_error(
        Vault::ValidationError, /foo/
      )
    end
  end

  context 'when building the uri' do
    it 'builds the correct uri' do
      expect(subject.get_uri(config).to_s).to eq("#{server_url}/v1/#{path}")
    end

    it 'prefers keys from inventory config' do
      server_url = 'http://127.0.0.1:9000'
      config[:server_url] = server_url
      expect(subject.get_uri(config).to_s).to eq("#{server_url}/v1/#{path}")
    end

    it 'prefers a path from an auth method' do
      path = 'cat/dog'
      expect(subject.get_uri(config, path).to_s).to eq("#{server_url}/v1/#{path}")
    end
  end

  context 'when parsing the response' do
    it 'errors when response is missing field from inventory config' do
      config[:field] = 'baz'
      expect { subject.parse_response(response, config) }.to raise_error(
        TaskHelper::Error, /baz/
      )
    end

    it 'accesses v2 data' do
      response_v2 = { 'data' => response }
      config[:version] = 2
      expect(subject.parse_response(response_v2, config)).to eq(secret)
    end

    it 'returns the value of a field from the inventory config' do
      expect(subject.parse_response(response, config)).to eq(secret)
    end

    it 'returns a hash of data when no field is given' do
      config.delete(:field)
      expect(subject.parse_response(response, config)).to eq(response['data'])
    end
  end
end
