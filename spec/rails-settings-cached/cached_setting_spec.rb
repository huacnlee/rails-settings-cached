require 'spec_helper'

describe RailsSettings::CachedSettings do
  before(:each) do
    RailsSettings::Settings.config do |config|
      # setup cache store from Rails.cache
      config.cache_store = Rails.cache
    end
    Rails.cache.clear
  end

  describe '.cache_key' do
    before do
      allow(Setting).to receive(:cache_prefix_by_startup).and_return('t123456')
    end

    it 'should work with instance method' do
      obj = Setting.unscoped.first
      expect(obj.cache_key).to eq("rails_settings_cached/t123456/#{obj.var}")
    end

    it 'should work with class method' do
      expect(Setting.cache_key('abc', nil)).to eql('rails_settings_cached/t123456/abc')
    end

    it 'should work with class method and scoped object' do
      obj = User.first
      expect(Setting.cache_key('abc', obj)).to eql('rails_settings_cached/t123456/User-1/abc')
    end
  end

  describe '.cache_prefix_by_startup' do
    it 'should work' do
      digest = Digest::MD5.hexdigest(RailsSettings::Default.instance.to_s)
      expect(described_class.cache_prefix_by_startup).to eq(digest)
    end
  end

  describe '.cache_prefix' do
    before do
      allow(described_class).to receive(:cache_prefix_by_startup).and_return('t123456')
    end

    it 'sets cache key prefix' do
      described_class.cache_prefix { 'stuff' }
      expect(described_class.cache_key('abc', nil)).to eql('rails_settings_cached/t123456/stuff/abc')
    end
  end

  describe 'Unscoped' do
    it 'should set a key and fetch with one query' do
      expect(Setting.test_cache).to eq(nil)
      Setting.test_cache = 123
      queries_count = count_queries do
        expect(Setting.test_cache).to eq(123)
        expect(Setting.test_cache).to eq(123)
        expect(Setting.test_cache).to eq(123)
      end
      expect(queries_count).to eq(0)
      Setting.test_cache = 321
      expect(Setting.test_cache).to eq(321)
    end
  end

  it 'caches unscoped settings' do
    queries_count = count_queries do
      expect(described_class['gender']).to be nil
      described_class['gender'] = 'female'

      # Call 4 times, make sure value is cached by fact number of queries does not go up.
      expect(described_class['gender']).to eq('female')
      expect(described_class['gender']).to eq('female')
      expect(described_class['gender']).to eq('female')
      expect(described_class['gender']).to eq('female')
    end
    expect(queries_count).to eq(5)
  end

  it 'caches unscoped settings' do
    expect(described_class['gender']).to eq('female')
    ActiveRecord::Base.transaction do
      described_class['gender'] = 'trans'
      expect(described_class['gender']).to eq('trans')
    end

    expect(described_class['gender']).to eq('trans')
  end

  it 'caches scoped settings' do
    user = User.create!(login: 'another_test', password: 'foobar')

    queries_count = count_queries do
      expect(user.settings['gender']).to be nil
      user.settings['gender'] = 'male'
      expect(user.settings['gender']).to eq('male')
      expect(user.settings['gender']).to eq('male')
    end
    expect(queries_count).to eq(6)
  end

  it 'caches scoped settings in transaction' do
    user = User.create!(login: 'another_test2', password: 'foobar')

    queries_count = count_queries do
      expect(user.settings['gender']).to be nil
      ActiveRecord::Base.transaction do
        user.settings['gender'] = 'male'
        expect(user.settings['gender']).to eq('male')
      end

      # Call 4 times, make sure value is cached by fact number of queries does not go up.
      expect(user.settings['gender']).to eq('male')
      expect(user.settings['gender']).to eq('male')
      expect(user.settings['gender']).to eq('male')
      expect(user.settings['gender']).to eq('male')
    end
    expect(queries_count).to eq(6)
  end

  it 'caches values from db' do
    described_class['some_random_key'] = 'asd'
    Rails.cache.clear

    queries_count = count_queries do
      expect(described_class['some_random_key']).to eq('asd')
      expect(described_class['some_random_key']).to eq('asd')
      expect(described_class['another_random_key']).to be nil
      expect(described_class['another_random_key']).to be nil
    end
    expect(queries_count).to eq(2)
  end
end
