require 'spec_helper'

describe RailsSettings::CachedSettings do
  it "caches unscoped settings" do
    queries_count = count_queries do
      expect(described_class["gender"]).to be nil
      described_class["gender"] = "female"
      expect(described_class["gender"]).to eq("female")
      expect(described_class["gender"]).to eq("female")
    end
    expect(queries_count).to eq(5)
  end

  it "caches scoped settings" do
    user = User.create!(login: 'another_test', password: 'foobar')

    queries_count = count_queries do
      expect(user.settings["gender"]).to be nil
      user.settings["gender"] = "male"
      expect(user.settings["gender"]).to eq("male")
      expect(user.settings["gender"]).to eq("male")
    end
    expect(queries_count).to eq(6)
  end

  it "caches values from db" do
    described_class["some_random_key"] = "asd"
    Rails.cache.clear

    queries_count = count_queries do
      expect(described_class["some_random_key"]).to eq("asd")
      expect(described_class["some_random_key"]).to eq("asd")
      expect(described_class["another_random_key"]).to be nil
      expect(described_class["another_random_key"]).to be nil
    end
    expect(queries_count).to eq(2)
  end
end
