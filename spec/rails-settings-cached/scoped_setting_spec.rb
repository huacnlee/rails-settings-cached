require 'spec_helper'

describe RailsSettings::ScopedSettings do
  it "extends `CachedSettings`" do
    expect(described_class.ancestors).to include(RailsSettings::CachedSettings)
  end
end
