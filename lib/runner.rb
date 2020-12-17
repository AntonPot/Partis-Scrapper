require_relative './getter.rb'
require_relative './scrapper.rb'
class Runner
  def self.run
    r = new

    loop do
      r.fetch_document
      r.scrap_last_file_data
      r.download_file if r.new_file?

      sleep 5
      print '.'
    end
  end

  attr_reader :getter, :file_data, :document
  attr_writer :last_upload_time

  def initialize
    @getter = Getter.new
  end

  def fetch_document
    i = 0
    getter.fetch_desired_page

    until getter.code == '200' || i >= 300
      i += 1
      puts "\nAuth unsuccessful. Sign in attempt --> #{i}"
      sleep 2
      getter.fetch_sign_in_page
      sleep 2
      getter.post_sign_in
      sleep 2
      getter.fetch_desired_page
    end

    @document = getter.response.body
  end

  def scrap_last_file_data
    service = Scrapper.scrap(@document)
    @file_data = {
      id: service.file_id,
      name: service.file_name,
      time: service.upload_time
    }
  end

  def new_file?
    @last_upload_time = @file_data[:time] if last_upload_time < @file_data[:time]
  end

  def last_upload_time
    @last_upload_time ||= @file_data[:time]
  end

  def download_file
    getter.download_file(@file_data)
    puts "\nNew download: #{file_data[:name]} - Upload time: #{file_data[:time]}"
  end
end
