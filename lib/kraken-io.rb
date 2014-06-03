require 'json'
require 'httparty'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'

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

    def url(url, params = {})
      params = normalized_params(params).merge!(auth_hash)
      params[:url] = url
      res = self.class.post('/url', body: params.to_json)
      res = Kraken::Response.new(res)
      yield res if block_given? or return res
    end

    def upload(file_name, params = {})
      params = normalized_params(params).merge!(auth_hash)
      res = self.class.multipart_post('/upload', file: file_name, body: params.to_json)
      res = Kraken::Response.new(res)
      yield res if block_given? or return res
    end

    private

    def normalized_params(params)
      params = params.with_indifferent_access

      unless params.keys.include?(:callback)
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
