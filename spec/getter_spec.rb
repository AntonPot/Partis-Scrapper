require 'spec_helper'

RSpec.describe Getter do
  subject { Getter.new }

  describe '#fetch_sign_in_page' do
    let(:headers) do
      {
        'set-cookie' => [
          '__cfduid=fu; expires=Fri, 15-Jan-21 13:50:36 GMT; path=/; domain=.partis.si; HttpOnly; SameSite=Lax; Secure',
          '__cf_bm=bar; path=/; expires=Wed, 16-Dec-20 14:20:36 GMT; domain=.partis.si; HttpOnly; Secure; SameSite=None'
        ]
      }
    end

    let(:cookie) do
      '__cf_bm=bar; path=/; expires=Wed, 16-Dec-20 14:20:36 GMT; domain=.partis.si; HttpOnly; Secure; SameSite=None; '\
      '__cfduid=fu; expires=Fri, 15-Jan-21 13:50:36 GMT; path=/; domain=.partis.si; HttpOnly; SameSite=Lax; Secure'
    end

    before do
      stub_request(:get, 'https://www.partis.si/prijava').to_return(headers: headers, body: 'fetch_sign_in_page')
    end

    it 'assings /prijava path to URI' do
      subject.fetch_sign_in_page
      expect(subject.uri.path).to eq('/prijava')
    end

    it 'assigns new response' do
      subject.fetch_sign_in_page
      expect(subject.response.body).to eq('fetch_sign_in_page')
    end

    it 'assings new cookie' do
      subject.fetch_sign_in_page
      expect(subject.cookie).to eq(cookie)
    end
  end

  describe '#post_sign_in' do
    let(:headers) do
      {
        'set-cookie' => [
          'udata=baz; domain=.partis.si; path=/',
          'userd=me; domain=stream.partis.si; path=/',
          'auth_token=bar; domain=.partis.si; path=/; expires=Tue, 16 Feb 2021 14:04:16 GMT',
          '_partis18=foo; path=/'
        ]
      }
    end

    let(:cookie) do
      '_partis18=foo; path=/; '\
      'auth_token=bar; domain=.partis.si; path=/; expires=Tue, 16 Feb 2021 14:04:16 GMT; '\
      'udata=baz; domain=.partis.si; path=/; '\
      'userd=me; domain=stream.partis.si; path=/'
    end

    before { stub_request(:post, 'https://www.partis.si/user/login').to_return(headers: headers, body: 'post_sign_in') }

    it 'assigns /user/login path to URI' do
      subject.post_sign_in
      expect(subject.uri.path).to eq('/user/login')
    end

    it 'assigns new response' do
      subject.post_sign_in
      expect(subject.response.body).to eq('post_sign_in')
    end

    it 'assings new cookie' do
      subject.post_sign_in
      expect(subject.cookie).to eq(cookie)
    end
  end

  describe '#fetch_desired_page' do
    before do
      stub_request(:get, 'https://www.partis.si/uporabnik/356928').to_return(body: 'fetch_desired_page')
    end

    it 'assigns /uporabink/356928 path to URI' do
      subject.fetch_desired_page
      expect(subject.uri.path).to eq('/uporabnik/356928')
    end

    it 'assigns new response' do
      subject.fetch_desired_page
      expect(subject.response.body).to eq('fetch_desired_page')
    end
  end

  describe '#download_file' do
    let(:id) { 123 }

    before do
      stub_request(:get, "https://www.partis.si/torrent/prenesi/#{id}").to_return(body: 'download_file')
      allow(File).to receive(:open)
    end

    it 'assigns new path to URI' do
      subject.download_file(id: id)
      expect(subject.uri.path).to eq("/torrent/prenesi/#{id}")
    end

    it 'assigns new response' do
      subject.download_file(id: id)
      expect(subject.response.body).to eq('download_file')
    end

    it 'opens a file' do
      subject.download_file(id: id)
      expect(File).to have_received(:open).once
    end
  end
end
