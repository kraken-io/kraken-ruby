require 'rubygems'
require 'kraken-io'

kraken = Kraken::API.new(
  'c1cf24cf4aa6b8833286f9393d30695a',
  'c6cbcab25c1ff1575e59ca7a035b1509e992cba6'
)

params = {
  'url' => 'http://files.jb51.net/scimg/png/20100803/Mario_Galaxy_002.png',
  'wait' => true,
  'resize' => {
    'width' => 1,
    'height' => 1,
    'strategy' => 'crop'
  }
}

response = kraken.url(params)

if response['success']
  puts 'Success! Optimized image URL: ' + response['kraked_url']
else
  puts 'Fail. Error message: ' + response['error']
end