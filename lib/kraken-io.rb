require 'json'
require 'httparty'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'
require 'thread'

require 'kraken-io/http_multi_part'
require 'kraken-io/response'

module Kraken
  class API
    include HTTParty
    extend  HTTPMultiPart

    base_uri 'https://api.kraken.io/v1'

    attr_accessor :api_key, :api_secret

    def initialize(options = {})
      @api_key    = options.fetch(:api_key)
      @api_secret = options.fetch(:api_secret)
    end

    def async
      @async = true
      self
    end

    def sync
      @async = false
      self
    end

    def url(url, params = {})
      params = normalized_params(params).merge!(auth_hash)
      params[:url] = url
      call_kraken do
        res = self.class.post('/url', body: params.to_json)
        res = Kraken::Response.new(res)
        yield res if block_given? or return res
      end
    end

    def callback_url(url)
      @callback_url = url
      self
    end

    def upload(file_name, params = {})
      params = normalized_params(params).merge!(auth_hash)
      call_kraken do
        res = self.class.multipart_post('/upload', file: file_name, body: params.to_json)
        res = Kraken::Response.new(res)
        yield res if block_given? or return res
      end
    end

    private
    def call_kraken(&block)
      if @async
        call_async(&block)
      else
        yield
      end
    end

    def call_async(&block)
      Thread.abort_on_exception = false
      Thread.new do |t|
        block.call
      end
      nil
    end

    def normalized_params(params)
      params = params.with_indifferent_access

      if params.keys.include?('callback_url') || @callback_url
        params[:callback_url] ||= @callback_url
      else
        params[:wait] = true
      end

      params
    end

    def auth_hash
      {
        auth: {
          api_key: api_key,
          api_secret: api_secret
        }
      }
    end
  end
end
