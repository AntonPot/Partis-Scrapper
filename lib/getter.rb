require 'uri'
require 'net/http'
require 'active_support'
require 'active_support/inflector'
require 'dotenv/load'

class Getter
  CREDENTIALS = {
    'user[username]' => ENV.fetch('LOGIN_NAME'),
    'user[password]' => ENV.fetch('PASSWORD')
  }.freeze

  FILE = {
    path: ENV['DOWNLOAD_PATH'],
    type: ENV['FILE_TYPE']
  }.freeze

  attr_reader :uri, :cookie, :response, :code

  def initialize
    @uri = URI(ENV['DOMAIN'])
  end

  def fetch_sign_in_page
    uri.path = '/prijava'
    send_request(:get)
    return unless response

    @cookie = response.to_hash['set-cookie'].join('; ')
  end

  def post_sign_in
    uri.path = '/user/login'
    send_request(:post) do |request|
      request.set_form(CREDENTIALS.to_a, 'multipart/form-data')
    end
    return unless response

    @cookie = response.to_hash['set-cookie'].join('; ')
  end

  def fetch_desired_page
    uri.path = '/uporabnik/356928'
    send_request(:get)
  end

  def download_file(data)
    uri.path = "/torrent/prenesi/#{data[:id]}"
    send_request(:get)
    return unless response

    File.open("#{FILE[:path]}/#{data[:name]}.#{FILE[:type]}", 'wb') do |f|
      f.write(@response.body)
    end
  end

  def send_request(http_method)
    request_constant = "Net::HTTP::#{http_method.capitalize}".constantize
    https = Net::HTTP.new(uri.host, uri.port).tap { |h| h.use_ssl = true }
    request = request_constant.new(uri)
    request['Cookie'] = cookie

    yield(request) if block_given?

    begin
      @response = https.request(request)
      @code = response.code
    rescue Net::ReadTimeout => e
      puts e.message
    end
  end
end
