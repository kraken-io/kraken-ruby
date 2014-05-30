require 'json'
require 'httparty'
require 'net/http/post/multipart'

module Kraken
  class API
    include HTTParty

    attr_accessor :api_key, :api_secret

    def initialize(api_key = '', api_secret = '')
      @api_key = api_key
      @api_secret = api_secret
    end

    def url(params = {})
      params.merge!({
        'auth' => {
          'api_key' => @api_key,
          'api_secret' => @api_secret
        }
      })

      self.class.post('https://api.kraken.io/v1/url', {:body => JSON.generate(params)})
    end

    def upload(params = {})
      params.merge!({
        'auth' => {
          'api_key' => @api_key,
          'api_secret' => @api_secret
        }
      })

      url = URI.parse("https://api.kraken.io/v1/upload")

      File.open(params['file']) do |file|
        params.delete('file')

        req = Net::HTTP::Post::Multipart.new url.path, "body" => JSON.generate(params), "file" => UploadIO.new(file, 'logotyp.png')

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        res = https.start() {|conn| conn.request(req)}
        response = JSON.parse(res.body)
      end
    end
  end
end
