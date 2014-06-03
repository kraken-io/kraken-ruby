require 'spec_helper'

describe Kraken::Response do
  subject do
    Kraken::Response.new(WebMock::Response.new(body: result.to_json))
  end

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

  describe "delegates to the response object" do
    its(:success)       { should == result['success'] }
    its(:file_name)     { should == result['file_name'] }
    its(:original_size) { should == result['original_size'] }
    its(:kraked_size)   { should == result['kraked_size'] }
    its(:saved_bytes)   { should == result['saved_bytes'] }
    its(:kraked_url)    { should == result['kraked_url'] }
  end

  describe "still responds to HTTP response methods" do
    its(:status) { should eq [200, ''] }
  end
end
