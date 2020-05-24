require 'httparty'
require 'openssl'

module Datasource
  class << self
    attr_accessor :http_client

    TTL = 900.seconds
    STALE_TTL = 1.day

    # Allow connecting to servers with self-signed server certificates
    # by setting `fetch_options[:connection_adapter]` to "ssl::verify_none"
    def fetch(url, fetch_options = {})
      fetch_or_cache(cache_key(url), stale_key(url)) do
        http_client.fetch(url, fetch_options).body.to_s
      end
    rescue StandardError
      Rails.logger.error($ERROR_INFO)
      Rails.cache.fetch(stale_key) || ''
    end

    private

    def cache_key(url)
      url.to_s
    end

    def stale_key(url)
      "stale-#{cache_key(url)}"
    end

    def fetch_or_cache(cache_key, stale_key)
      content = Rails.cache.fetch(cache_key, expires_in: TTL) do
        yield if block_given?
      end
      content.tap do |c|
        Rails.cache.write stale_key, c, expires_in: STALE_TTL
      end
    end
  end

  class HttpClient
    CLIENT_CERT = '/path/to/certificate.pem'.freeze

    HEADERS = {
      'Content-Type'   => 'application/json',
      'Accept'         => 'application/json'
    }.freeze

    OPTIONS = {
      headers: HEADERS,
      pem: File.read(CERTIFICATE, mode: 'rb')
    }.freeze

    def fetch(url, fetch_options = {})
      # NOTE: HTTParty::Response version 0.11.0 doesn't like tap! The following
      # line returns `String` instead of `HTTParty::Response`:
      #
      # HTTParty.get(url, options).tap { |r| Rails.logger.error r.class.name }
      #
      response = HTTParty.get(url, options(fetch_options))
      return response if response.success?
      raise "#{response.code} error fetching #{url}"
    rescue StandardError => e
      raise "Failed fetch request: #{e.message}"
    end

    private

    def options(fetch_options)
      @options ||= begin
        OPTIONS.merge(fetch_options).tap do |options|
          if options[:connection_adapter] == 'ssl::verify_none'
            options[:connection_adapter] = ConnectionAdapter
          end
        end
      end
    end
  end

  class ConnectionAdapter < HTTParty::ConnectionAdapter
    def connection
      super.tap do |http|
        # Allow the use of self-signed server certificates
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
  end

  self.http_client ||= HttpClient.new
end
