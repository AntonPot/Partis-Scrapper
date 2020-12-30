require 'spec_helper'

RSpec.describe Runner do
  let(:new_entries) { [entries.first] }
  let(:log_path) { 'tmp/test_log' }
  let(:entries) do
    [
      {name: 'NBA 2020 12 23 Mavericks vs Suns 720p HD', id: '596433'},
      {name: 'NBA 2020 12 17 Timberwolves vs Mavericks', id: '595909'},
      {name: 'NBA 2020 12 14 Mavericks vs Bucks 720p H', id: '595625'},
      {name: 'NBA 2020 12 12 Mavericks vs Bucks 720p H', id: '595373'}
    ]
  end

  before do
    allow(Runner).to receive(:log_filename).and_return(log_path)
    allow(Scrapper).to receive(:search).with(nil, Runner.search_regex).and_return(entries)
  end

  pending 'test for all class methods'

  describe '#fetch_document' do
    pending
  end

  describe '#find_entries' do
    it 'sends .search to Scrapper' do
      subject.find_entries
      expect(Scrapper).to have_received(:search).with(nil, Runner.search_regex).once
    end
  end

  describe '#filter_new_entries' do
    before do
      allow(Runner).to receive(:log_filename).and_return('spec/static/test_log')
      subject.find_entries
    end

    it 'removes entries present in the log' do
      expect { subject.filter_new_entries }.to change(subject.entries, :count).by(-3)
    end

    it 'keeps desired entire in the log' do
      subject.filter_new_entries
      expect(subject.entries).to eq new_entries
    end
  end

  describe 'new_entries?' do
    it 'returns FALSE if @entries is empty' do
      allow(subject).to receive(:entries).and_return([])
      expect(subject.new_entries?).to be false
    end
  end

  describe 'download_new_entries' do
    before do
      allow(subject).to receive(:entries).and_return(new_entries)
      allow(subject.getter).to receive(:download_file).with(new_entries.first)
      allow(File).to receive(:open).with(log_path, 'a')
      subject.download_new_entries
    end

    it 'sends #download_file to Getter' do
      expect(subject.getter).to have_received(:download_file).with(new_entries.first)
    end

    it 'sends .open to File' do
      expect(File).to have_received(:open).with(log_path, 'a')
    end
  end
end
