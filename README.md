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
* [Image Type Conversion](#image-type-conversion)
* [Preserving Metadata](#preserving-metadata)
* [External Storage](#external-storage)
  * [Amazon S3](#amazon-s3)
  * [Rackspace Cloud Files](#rackspace-cloud-files)
  * [Microsoft Azure](#microsoft-azure)
  * [SoftLayer Object Storage](#softlayer-object-storage)

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

**Please visit our [Image Resizing](https://kraken.io/docs/image-resizing) documentation for details and examples.**

## WebP Compression

WebP is a new image format introduced by Google in 2010 which supports both lossy and lossless compression. According to [Google](https://developers.google.com/speed/webp/), WebP lossless images are **26% smaller** in size compared to PNGs and WebP lossy images are **25-34% smaller** in size compared to JPEG images.

To recompress your PNG or JPEG files into WebP format simply set `"webp": true` flag in your request JSON. You can also optionally set `"lossy": true` flag to leverage WebP's lossy compression:

````ruby
params = {
    'webp' => true,
    'lossy' => true
}
````

## Image Type Conversion

Kraken API allows you to easily convert different images from one type/format to another. If, for example, you would like to turn you transparent PNG file into a JPEG with a grey background Kraken API has you covered.

In order to convert between different image types you need to add an extra `convert` object to you request JSON. This object takes three properties:

- `format` with which you specify the file type you want your image converted into.
- An optional `background` property where you can specify background colour when converting from transparent file formats such as PNG and GIF into a fully opaque format such as JPEG.
- An optional `keep_extension` property which allows you to keep the original file extension intact regardless of the output image format.

**Mandatory Parameters:**
- `format` —    The image format you wish to convert your image into. This can accept one of the following values: `jpeg`, `png` or `gif`.

**Optional Parameters:**
- `background` —    Background image when converting from transparent file formats like PNG or GIF into fully opaque format like JPEG. The background property can be passed in HEX notation `"#f60"` or `"#ff6600"`, RGB `"rgb(255, 0, 0)"` or RGBA `"rgba(91, 126, 156, 0.7)"`. The default background color is white.
- `keep_extension` —    a boolean value (`true` or `false`) instructing Kraken API whether or not the original extension should be kept in the output filename. For example when converting "image.jpg" into PNG format with this flag turned on the output image name will still be "image.jpg" even though the image has been converted into a PNG. The default value is `false` meaning the correct extension will always be set.


## Preserving Metadata

By default Kraken API will **strip all the metadata found in an image** to make the image file as small as it is possible, and in both lossy and lossless modes. Entries like EXIF, XMP and IPTC tags, colour profile information, etc. will be stripped altogether.

However there are situations when you might want to preserve some of the meta information contained in the image, for example, copyright notice or geotags. In order to preserve the most important meta entries add an additional `preserve_meta` array to your request with one or more of the following values:

````js
{
    "preserve_meta": ["date", "copyright", "geotag", "orientation", "profile"]
}
````

- `profile` - will preserve the ICC colour profile. ICC colour profile information adds unnecessary bloat to images. However, preserving it can be necessary in **extremely rare cases** where removing this information could lead to a change in brightness and/or saturation of the resulting file.
- `date` - will preserve image creation date.
- `copyright` - will preserve copyright entries.
- `geotag` - will preserve location-specific information.
- `orientation` - will preserve the orientation (rotation) mark.

Example integration:

````ruby
require 'rubygems'
require 'kraken-io'

kraken = Kraken::API.new(
    :api_key => 'your-api-key',
    :api_secret => 'your-api-secret'
)

params = {
  'file' => '/path/to/image/file.jpg',
  'wait' => true,
  'preserve_meta' => [ 'profile', 'geotag', 'orientation' ]
}

data = kraken.upload('/path/to/image/file.jpg', 'lossy' => true)

if data.success
    puts 'Success! Optimized image URL: ' + response.kraked_url
else
    puts 'Fail. Error message: ' + data.message
end

````

## External Storage

Kraken API allows you to store optimized images directly in your S3 bucket, Cloud Files container, Azure container or SoftLayer Object Storage container. With just a few additional parameters your optimized images will be pushed to your external storage in no time.

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

### Microsoft Azure

**Mandatory Parameters:**
- `account` - Your Azure Storage Account.
- `key` - Your unique Azure Storage Access Key.
- `container` - Name of a destination container on your Azure account.

**Optional Parameters:**
- `path` - Destination path in your container (e.g. `"images/layout/header.jpg"`). Defaults to root `"/"`.

The above parameters must be passed in a `azure_store` key:

````ruby

params = {
    'wait' => true,
    'azure_store' => {
        'account' => 'your-azure-account',
        'key' => 'your-azure-storage-access-key',
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

### SoftLayer Object Storage

**Mandatory Parameters:**
- `user` - Your SoftLayer username.
- `key` - Your SoftLayer API Key.
- `container` - Name of a destination container on your SoftLayer account.
- `region` - Short name of the region your container is located in. This can be one of the following: 
`syd01` `lon02` `mon01` `dal05` `tok02`
`tor01` `hkg02` `mex01` `par01` `fra02`
`mil01` `sjc01` `sng01` `mel01` `ams01`

**Optional Parameters:**
- `path` - Destination path in your container (e.g. "images/layout/header.jpg"). Defaults to root "/".
- `cdn_url` - A boolean value `true` or `false` instructing Kraken API to return a public CDN URL of your optimized file. Defaults to `false` meaning the non-CDN URL will be returned.


The above parameters must be passed in a `sl_store` object:

````ruby

params = {
    'wait' => true,
    'sl_store' => {
        'user' => 'your-softlayer-account',
        'key' => 'your-softlayer-key',
        'container' => 'destination-container',
        'region' => 'your-container-location',
        'cdn_url' => true,
        'path' =>'images/layout/header.jpg'
    }
}

data = kraken.upload('/path/to/image/file.jpg', params)

if data.success
    puts 'Success! Optimized image URL: ' + response.kraked_url
else
    puts 'Fail. Error message: ' + data.message
end

````

## LICENSE - MIT

Copyright (c) 2013-2015 Nekkra UG

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
