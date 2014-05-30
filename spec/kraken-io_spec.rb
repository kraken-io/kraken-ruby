require 'spec_helper'

describe Kraken::API do
  let(:result) do
    {
      "success" =>  true,
      "file_name" => "header.jpg",
      "original_size" =>  324520,
      "kraked_size" =>  165358,
      "saved_bytes" =>  159162,
      "kraked_url" => "http://dl.kraken.io/ecdfa5c55d5668b1b5fe9e420554c4ee/header.jpg"
    }.to_json
  end

  subject { Kraken::API.new(1,2) }
  describe '#url' do
    let(:expected_params) do
      {
          'url' => 'http://farts.gallery',
          'wait' => true,
          'auth' => { 'api_key' => 1, 'api_secret' => 2}
      }
    end

    it 'provides a url to the kraken api' do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => expected_params.to_json).to_return(body: result)

        subject.url(
          'url' => 'http://farts.gallery',
          'wait' => true
        )
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
      end.to_return(body: result)

      subject.upload(
        'wait' => true,
        'file' => File.expand_path('test.gif', File.dirname(__FILE__))
      )
    end
  end
end
