Ruby Gem for Kraken.io API
===========

With this Ruby Gem you can plug into the power and speed of [Kraken.io](http://kraken.io/) Image Optimizer.

* [Installation](#installation)
* [Getting Started](#getting-started)
* [Authentication](#authentication)
* [How To Use](#how-to-use)
  * [Usage - Image URL](#usage---image-url)
  * [Usage - Image Upload](#usage---image-upload)
* [Wait and Callback URL](#wait-and-callback-url)
  * [Wait Option](#wait-option)
  * [Callback URL](#callback-url)
* [Downloading Images](#downloading-images)
* [Lossy Optimization](#lossy-optimization)
* [Image Resizing](#image-resizing)
* [WebP Compression](#webp-compression)
* [Amazon S3 and Rackspace Cloud Files Integration](#amazon-s3-and-rackspace-cloud-files)
  * [Amazon S3](#amazon-s3)
  * [Rackspace Cloud Files](#rackspace-cloud-files)

## Installation

Add this line to your application's Gemfile:

    gem 'kraken-io'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kraken-io

## Getting Started

First you need to sign-up for the [Kraken API](http://kraken.io/plans/) and obtain your unique **API Key** and **API Secret**. You will find both under [API Credentials](http://kraken.io/account/api-credentials). Once you have set up your account, you can start using Kraken API in your applications. You can test integration without charge by signing up for the [Developers plan](http://kraken.io/signup/developers).

## Authentication

The first step is to authenticate to Kraken API by providing your unique API Key and API Secret while creating new Kraken instance:

````ruby
require 'rubygems'
require 'kraken-io'

kraken = Kraken::API.new(
    :api_key => 'your-api-key',
    :api_secret => 'your-api-secret'
)
````

## How to use

You can optimize your images in two ways - by providing an URL of the image you want to optimize or by uploading an image file directly to Kraken API.

The first option (image URL) is great for images that are already in production or any other place on the Internet. The second one (direct upload) is ideal for your deployment process, build script or the on-the-fly processing of your user's uploads where you don't have the images available on-line yet.

## Usage - Image URL

To optimize an image by providing an image URL use the `kraken.url()` method. You will need to provide an `url` to the image, and optionally a `callback_url`. If you don't provide a `callback_url`, then `wait` will be set to true automatically:

````ruby
data = kraken.url('http://image-url.com/file.jpg')

if data.success
    puts 'Success! Optimized image URL: ' + data.kraked_url
else
    puts 'Fail. Error message: ' + data.message
end
````

Depending on if you perform a synchronous request or use a callback URL, in the returned `data` object you will find either the optimization ID or optimization results containing a `success` property, file name, original file size, kraked file size, amount of savings and optimized image URL:

````ruby
data.success       #=> true,
data.file_name     #=> "file.jpg"
data.original_size #=> 30664
data.kraked_size   #=> 577
data.saved_bytes   #=> 30087
data.kraked_url    #=> "http://dl.kraken.io/d1aacd2a2280c2ffc7b4906a09f78f46/file.jpg"
````

If no savings were found, the API will still return an object containing `"success":true` however, `saved_bytes` will show zero bytes of savings:

````ruby
data.success #=> true
data.saved_bytes #=> 0
````

## Usage - Image Upload

If you want to upload your images directly to Kraken API use the `kraken.upload()` method. You will need to provide an absolute path to the file, and optionally, an options hash with a `callback_url`.

In the `data` object you will find the same optimization properties as with `url` option above.

````ruby
data = kraken.upload('/path/to/image/file.jpg')

if data.success
    puts 'Success! Optimized image URL: ' + data.kraked_url
else
    puts 'Fail. Error message: ' + data.message
end
````

## Wait and Callback URL

Kraken gives you two options for fetching optimization results. With the `wait` option set the results will be returned immediately in the response. With `callback_url` the results will be posted to the URL specified in your request. Unless a `callback_url` is set in the options, the kraken gem will use the `wait` option by default to perform synchronous processing.

### Wait option

By default, the `wait` option is turned on for every request to the API, and the connection will be held open until the image has been optimized. Once this is finished you will get an immediate response with a Ruby object containing your optimization results.

**Request:**

````ruby
data = kraken.url('http://awesome-website.com/images/file.jpg')
````

**Response**

````ruby
data.success       #=> true
data.file_name     #=> "file.jpg"
data.original_size #=> 324520
data.kraked_size   #=> 165358
data.saved_bytes   #=> 159162
data.kraked_url    #=> "http://dl.kraken.io/d1aacd2a2280c2ffc7b4906a09f78f46/file.jpg"
````

### Callback URL

With the Callback URL the HTTPS connection will be terminated immediately and a unique `id` will be returned in the response body. After the optimization is finished, Kraken will POST a message to the `callback_url` specified in your request. The ID in the response will reflect the ID in the results posted to your Callback URL.

We recommend [requestb.in](http://requestb.in) as an easy way to capture optimization results for initial testing.

**Request:**

````ruby
params = {
    :callback_url => 'http://awesome-website.com/kraken_results'
}

data = kraken.url('http://awesome-website.com/images/header.jpg', params)
````

**Response:**

````ruby
data.id #=> "18fede37617a787649c3f60b9f1f280d"
````

**Results posted to the Callback URL:**

````ruby
def kraken_results
  params[:id]            #=> "18fede37617a787649c3f60b9f1f280d"
  params[:success]       #=> true
  params[:file_name]     #=> "header.jpg"
  params[:original_size] #=> 324520
  params[:kraked_size]   #=> 165358
  params[:saved_bytes]   #=> 159162
  params[:kraked_url]    #=> "http://dl.kraken.io/18fede37617a787649c3f60b9f1f280d/header.jpg"
end
````

If you want to set a `callback_url` to be used for *all* subsequent requests coming from a kraken instance, you can set it like this:

````ruby
kraken.callback_url('http://awesome-website.com/kraken_results')
data = kraken.url('http://awesome-website.com/images/header.jpg')
````

## Downloading Images

Remember - never link to optimized images offered to download. You have to download them first, and then replace them in your websites or applications. Due to security reasons optimized images are available on our servers **for one hour** only. You can copy them back to your application with `open-uri` like so:

````ruby
require 'open-uri'

if request.success
    File.write('local_file_name.jpg', open(data.kraked_url).read, { :mode => 'wb' })
end
````

## Lossy Optimization

When you decide to sacrifice just a small amount of image quality (usually unnoticeable to the human eye), you will be able to save up to 90% of the initial file weight. Lossy optimization will give you outstanding results with just a fraction of image quality loss.

To use lossy optimizations simply set `"lossy" => true` in your request:

````ruby
kraken.upload('/path/to/image/file.jpg', 'lossy' => true)
````

### PNG Images
PNG images will be converted from 24-bit to paletted 8-bit with full alpha channel. This process is called PNG quantization in RGBA format and means the amout of colours used in an image will be reduced to 256 while maintaining all information about alpha transparency.

### JPEG Images
For lossy JPEG optimizations Kraken will generate multiple copies of a input image with a different quality settings. It will then intelligently pick the one with the best quality to filesize ration. This ensures your JPEG image will be at the smallest size with the highest possible quality, without the need for a human to select the optimal image.

## Image Resizing

Image resizing option is great for creating thumbnails or preview images in your applications. Kraken will first resize the given image and then optimize it with it's vast array of optimization algorythms. The `resize` option needs a few parameters to be passed like desired `width` and/or `height` and a mandatory `strategy` property. For example:

````ruby
params = {
    'resize' => {
        'width' => 100,
        'height' => 75,
        'strategy' => 'crop'
    }
}

data = kraken.upload('/path/to/image/file.jpg', params)

if data.success
    puts 'Success! Optimized image URL: ' + data.kraked_url
else
    puts 'Fail. Error message: ' + data.message
end
````

The `strategy` property can have one of the following values:

- `exact` - Resize by exact width/height. No aspect ratio will be maintained.
- `portrait` - Exact width will be set, height will be adjusted according to aspect ratio.
- `landscape` - Exact height will be set, width will be adjusted according to aspect ratio.
- `auto` - The best strategy (portrait or landscape) will be selected for a given image according to aspect ratio.
- `crop` - This option will crop your image to the exact size you specify with no distortion.
- `square` - This strategy will first crop the image by its shorter dimension to make it a square, then resize it to the specified size.
- `fill` - This strategy allows you to resize the image to fit the specified bounds while preserving the aspect ratio (just like auto strategy). The optional background property allows you to specify a color which will be used to fill the unused portions of the previously specified bounds.

** Please visit our [Image Resizing](https://kraken.io/docs/image-resizing) documentation for details and examples. **

## WebP Compression

WebP is a new image format introduced by Google in 2010 which supports both lossy and lossless compression. According to [Google](https://developers.google.com/speed/webp/), WebP lossless images are **26% smaller** in size compared to PNGs and WebP lossy images are **25-34% smaller** in size compared to JPEG images.

To recompress your PNG or JPEG files into WebP format simply set `"webp": true` flag in your request JSON. You can also optionally set `"lossy": true` flag to leverage WebP's lossy compression:

````ruby
params = {
    'webp' => true,
    'lossy' => true
}
````

## Amazon S3 and Rackspace Cloud Files

Kraken API allows you to store optimized images directly in your S3 bucket or Cloud Files container. With just a few addidtional parameters your optimized images will be pushed to your external storage in no time.

### Amazon S3

**Mandatory Parameters:**
- `key` - Your unique Amazon "Access Key ID".
- `secret` - Your unique Amazon "Secret Access Key".
- `bucket` - Name of a destination container on your Amazon S3 account.

**Optional Parameters:**
- `path` - Destination path in your S3 bucket (e.g. `"images/layout/header.jpg"`). Defaults to root `"/"`.
- `acl` - Permissions of a destination object. This can be `"public_read"` or `"private"`. Defaults to `"public_read"`.

The above parameters must be passed in a `s3_store` object:

````ruby
params = {
    's3_store' => {
        'key' => 'your-amazon-access-key',
        'secret' => 'your-amazon-secret-key',
        'bucket' => 'destination-bucket'
    }
}

data = kraken.upload('/path/to/image/file.jpg', params)

if data.success
    puts 'Success! Optimized image URL: ' + data.kraked_url
else
    puts 'Fail. Error message: ' + data.message
end
````

The `data` object will contain `kraked_url` method pointing directly to the optimized file location in your Amazon S3 account:

````ruby
data.kraked_url #=> "http://s3.amazonaws.com/YOUR_CONTAINER/path/to/file.jpg"
````

### Rackspace Cloud Files

**Mandatory Parameters:**
- `user` - Your Rackspace username.
- `key` - Your unique Cloud Files API Key.
- `container` - Name of a destination container on your Cloud Files account.

**Optional Parameters:**
- `path` - Destination path in your container (e.g. `"images/layout/header.jpg"`). Defaults to root `"/"`.

The above parameters must be passed in a `cf_store` object:

````ruby
params = {
    'cf_store' => {
        'user' => 'your-rackspace-username',
        'key' => 'your-rackspace-api-key',
        'container' => 'destination-container'
    }
}

data = kraken.upload('/path/to/image/file.jpg', params)

if data.success
    puts 'Success! Optimized image URL: ' + response.kraked_url
else
    puts 'Fail. Error message: ' + data.message
end
````

If your container is CDN-enabled, the optimization results will contain `kraked_url` which points directly to the optimized file location in your Cloud Files account, for example:

````ruby
data.kraked_url #=> "http://e9ffc04970a269a54eeb-cc00fdd2d4f11dffd931005c9e8de53a.r2.cf1.rackcdn.com/path/to/file.jpg"
````

If your container is not CDN-enabled `kraked_url` will point to the optimized image URL in the Kraken API:

````ruby
data.kraked_url #=> "http://dl.kraken.io/ecdfa5c55d5668b1b5fe9e420554c4ee/file.jpg"
````

## LICENSE - MIT

Copyright (c) 2013 Nekkra UG

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
