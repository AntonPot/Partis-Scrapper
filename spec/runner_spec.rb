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

  describe '#fetch_document' do
    before do
      allow(subject.getter).to receive(:fetch_desired_page)
      allow(subject.getter).to receive(:response).and_return(double(body: ''))
      allow(subject.getter).to receive(:code).and_return('200')
    end

    it 'sends #fetch_desired_page to Getter' do
      subject.fetch_document
      expect(subject.getter).to have_received(:fetch_desired_page).once
    end

    it 'assigns value to @document' do
      expect { subject.fetch_document }.to change(subject, :document).from(nil).to('')
    end
  end

  describe '#authenticate' do
    before do
      allow(subject.getter).to receive(:fetch_sign_in_page)
      allow(subject.getter).to receive(:post_sign_in)
      allow(subject.getter).to receive(:fetch_desired_page)
      allow(Runner).to receive(:wait)
      subject.authenticate
    end

    it 'sleeps for 2 seconds between calls' do
      expect(Runner).to have_received(:wait).with(1).exactly(3).times
    end

    it 'sends #fetch_sign_in_page to Getter' do
      expect(subject.getter).to have_received(:fetch_sign_in_page).once
    end

    it 'sends #post_sign_in to Getter' do
      expect(subject.getter).to have_received(:post_sign_in).once
    end

    it 'sends #fetch_desired_page to Getter' do
      expect(subject.getter).to have_received(:fetch_desired_page).once
    end
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

  describe '#new_entries?' do
    it 'returns FALSE if @entries is empty' do
      allow(subject).to receive(:entries).and_return([])
      expect(subject.new_entries?).to be false
    end
  end

  describe '#download_new_entries' do
    before do
      allow(subject).to receive(:entries).and_return(new_entries)
      allow(subject.getter).to receive(:download_file).with(new_entries.first)
      allow(File).to receive(:open).with(log_path, 'a')
      allow($stdout).to receive(:puts)
      subject.download_new_entries
    end

    it 'sends #download_file to Getter' do
      expect(subject.getter).to have_received(:download_file).with(new_entries.first)
    end

    it 'sends .open to File' do
      expect(File).to have_received(:open).with(log_path, 'a')
    end

    it 'writes to output' do
      expect($stdout).to have_received(:puts).with("\nNew download: #{new_entries.first[:name]}").once
    end
  end
end
