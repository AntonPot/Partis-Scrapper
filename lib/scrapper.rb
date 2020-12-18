require 'nokogiri'

class Scrapper
  attr_reader :document, :upload_time, :file_id, :file_name, :link_node, :time_node

  def self.scrap(doc)
    s = new(doc)
    s.find_matching_node
    s.parse_link_node
    s.parse_time_node
    s
  end

  def initialize(doc)
    @document = Nokogiri::HTML(doc)
  end

  def find_matching_node
    document.search('div.listeklink').each do |node|
      next unless node.elements.first.content.match?(/Dhabi/)

      @link_node, @time_node = node.elements
      break
    end
  end

  def parse_time_node
    raw_text = time_node.at('span:contains("Naloženo")').at('span.middle').to_s.split('<br>').last[0..-8]
    time_strings = raw_text.split(' ').each_with_index.map { |t, i| t if i.odd? }.compact
    args = time_strings.each_with_index.map { |t, i| i.even? ? t.split('.').reverse : t.split(':') }.flatten
    @upload_time = Time.new(*args)
  end

  def parse_link_node
    @file_id = link_node.values.first.split('/').last
    @file_name = link_node.content.delete('...')
  end
end
