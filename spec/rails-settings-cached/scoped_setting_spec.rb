require 'spec_helper'

describe RailsSettings::ScopedSettings do
  it "extends `RailsSettings::Base`" do
    expect(described_class.ancestors).to include(RailsSettings::Base)
  end
end
