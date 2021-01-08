
require_relative './lib/downloader.rb'

file_id = ARGV[0]
name = ARGV[1]

Downloader.new(file_id, name).run
