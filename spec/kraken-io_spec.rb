require 'spec_helper'
require 'timeout'

describe Kraken::API do
  let(:result) do
    {
      "success" =>  true,
      "file_name" => "header.jpg",
      "original_size" =>  324520,
      "kraked_size" =>  165358,
      "saved_bytes" =>  159162,
      "kraked_url" => "http://dl.kraken.io/ecdfa5c55d5668b1b5fe9e420554c4ee/header.jpg"
    }
  end

  subject { Kraken::API.new(api_key: 1, api_secret: 2) }

  describe 'initialize' do
    it 'is an error to leave out the key or secret' do
      expect { Kraken::API.new(api_secret: 2) }.to raise_error KeyError
      expect { Kraken::API.new(api_key: 2) }.to raise_error KeyError
    end
  end

  describe '#async' do
    let(:expected_params) do
      {
          'wait' => true,
          'auth' => { 'api_key' => 1, 'api_secret' => 2},
          'url' => 'http://farts.gallery',
      }
    end

    it 'returns the result eventually' do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => expected_params.to_json).to_return(body: result.to_json)

      defer = nil
      immediate = subject.async.url('http://farts.gallery') do |result|
        defer = result.kraked_url
      end

      expect(immediate).to be_nil

      Timeout.timeout(2) do
        loop until defer
      end

      expect(defer).to eq result['kraked_url']
    end
  end

  describe '#callback' do
    let(:expected_params) do
      {
        'callback_url' => 'http://seriouslylike.omg',
        'auth' => { 'api_key' => 1, 'api_secret' => 2},
        'url' => 'http://farts.gallery'
      }
    end

    let(:result) do
      {
        "id" => "18fede37617a787649c3f60b9f1f280d"
      }
    end

    it 'uses the call back and runs async' do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => expected_params.to_json).to_return(body: result.to_json)

      res = subject.callback_url('http://seriouslylike.omg').url('http://farts.gallery')
      expect(res.code).to eq 200
    end
  end

  describe '#url' do
    let(:expected_params) do
      {
          'wait' => true,
          'auth' => { 'api_key' => 1, 'api_secret' => 2},
          'url' => 'http://farts.gallery'
      }
    end

    it 'provides a url to the kraken api' do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => expected_params.to_json).to_return(body: result.to_json)

      res = subject.url('http://farts.gallery')
      expect(res.code).to eq 200
    end
  end

  describe '#upload' do
    let(:expected_params) do
      {
          'wait' => true,
          'auth' => { 'api_key' => 1, 'api_secret' => 2}
      }
    end

    it 'uploads multipart form data to the server' do
      stub_request(:post, "https://api.kraken.io/v1/upload").with do |req|
        expect(req.body).to include(expected_params.to_json)
        expect(req.body).to include('filename="test.gif"')
        expect(req.headers['Content-Type']).to include('multipart/form-data')
      end.to_return(body: result.to_json)

      res = subject.upload(File.expand_path('test.gif', File.dirname(__FILE__)))
      expect(res).to be_kind_of Kraken::Response
    end
  end
end
