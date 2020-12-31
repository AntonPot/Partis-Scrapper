require 'nokogiri'

class Scrapper
  attr_reader :document, :regex

  def self.search(document, regex)
    s = new(document, regex)
    s.find_nodes
    s.parse_nodes
  end

  def initialize(document, regex)
    @document = Nokogiri::HTML(document)
    @regex = regex
  end

  def find_nodes
    document.search('div.listeklink a').select do |node|
      node.content.match?(regex)
    end
  end

  def parse_nodes
    find_nodes.map do |node|
      {
        name: node.content.delete('...'),
        id: node.attributes['href'].value.split('/').last
      }
    end
  end
end
