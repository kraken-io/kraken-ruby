require 'net/http/post/multipart'

module HTTPMultiPart
  def multipart_post(url, params = {})
    unless params.has_key?(:file)
      post(url, params)
    end

    url = URI.parse(base_uri + url)

    req = Net::HTTP::Post::Multipart.new(url.path, { 
      file: UploadIO.new(File.open(params[:file]), 'file'), 
      body: params[:body] })

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.request(req)
  end
end
