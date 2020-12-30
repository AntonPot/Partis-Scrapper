require 'spec_helper'

RSpec.describe Scrapper do
  let(:doc) { File.read('spec/static/scrapper_data') }

  subject(:scrapper) { Scrapper.new(doc, /Mavericks/) }

  describe '#find_nodes' do
    subject { scrapper.find_nodes }

    it 'returns array' do
      expect(subject).to be_kind_of Array
    end

    it 'finds 4 nodes' do
      expect(subject.count).to eq 4
    end

    it 'returns array of Nokogiri::XML::Elements' do
      expect(subject.first).to be_kind_of Nokogiri::XML::Element
    end
  end

  describe '#parse_nodes' do
    subject { scrapper.parse_nodes }

    it 'returns array' do
      expect(subject).to be_kind_of Array
    end

    it 'returns array of Hashes' do
      expect(subject.first).to be_kind_of Hash
    end

    it 'parses node content and href value' do
      expect(subject.first[:name]).to eq 'NBA 2020 12 23 Mavericks vs Suns 720p HD'
      expect(subject.first[:id]).to eq '596433'
    end
  end
end
