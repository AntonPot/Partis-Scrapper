require_relative './getter.rb'
require_relative './scrapper.rb'

class Runner
  def self.run
    r = new

    loop do
      r.fetch_document
      r.find_entries
      r.filter_new_entries

      r.download_new_entries if r.new_entries?

      wait 10
      print '.'
    end
  end

  def self.wait(seconds)
    sleep(seconds) unless ENV['test'] == '1'
  end

  def self.log_filename
    'log/file_ids'
  end

  def self.search_regex
    /(NBA 2020)*(Lakers|Nets|Nuggets)/
  end

  attr_reader :getter, :document, :ids_log, :entries, :file

  def initialize
    File.new(log_filename, 'a+').close
    @getter = Getter.new
  end

  def fetch_document
    i = 0
    getter.fetch_desired_page

    until getter.code == '200' || i >= 300
      i += 1
      puts "\nSign in attempt --> #{i}"
      authenticate
    end

    @document = getter.response.body
  end

  def authenticate
    %w[fetch_sign_in_page post_sign_in fetch_desired_page].each do |method|
      Runner.wait 1
      getter.send(method)
    end
  end

  def find_entries
    @entries = Scrapper.search(document, search_regex)
  end

  def filter_new_entries
    File.foreach(log_filename) do |id|
      @entries.delete_if { |f| f[:id] == id.chomp }
    end
  end

  def new_entries?
    entries.any?
  end

  def download_new_entries
    entries.each do |e|
      getter.download_file(e)
      File.open(log_filename, 'a') { |f| f.puts e[:id] }
      puts "\nNew download: #{e[:name]}"
    end
  end

  private

  def log_filename
    self.class.log_filename
  end

  def search_regex
    self.class.search_regex
  end
end
