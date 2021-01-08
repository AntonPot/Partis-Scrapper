require_relative './getter.rb'

class Downloader
  attr_reader :getter, :file_id, :name

  def initialize(file_id, name)
    @getter = Getter.new
    @file_id = file_id
    @name = name
  end

  def run
    5.times do |i|
      puts "\nSign in attempt --> #{i}"
      authenticate
      break if getter.code == '200'
    end

    getter.download_file(id: file_id, name: name)
    puts "File #{name} downloaded"
  end

  def authenticate
    %w[fetch_sign_in_page post_sign_in fetch_desired_page].each do |method|
      sleep 1
      getter.send(method)
    end
  end
end
