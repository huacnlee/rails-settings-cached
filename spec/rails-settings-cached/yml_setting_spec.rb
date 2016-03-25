require 'spec_helper'

describe RailsSettings::YMLSetting do
  class SettingWithYML < RailsSettings::Base
    source File.expand_path("../../app.yml", __FILE__)
    namespace "test"
  end

  describe 'YMLSetting config' do
    it { expect(RailsSettings::YMLSetting.namespace).to eq 'test' }
    it { expect(RailsSettings::YMLSetting.source).to eq File.expand_path("../../app.yml", __FILE__) }
  end

  describe 'Base test' do
    it "should not hit SQL" do
      queries_count = count_queries do
        SettingWithYML.str
        SettingWithYML.str
        SettingWithYML.str
        SettingWithYML.script
        SettingWithYML.script
        SettingWithYML.script
        SettingWithYML.not_exist_key
        SettingWithYML.not_exist_key
      end
      expect(queries_count).to eq 3
    end

    it { expect(SettingWithYML.str).to eq 'hello in test' }
    it { expect(SettingWithYML.script).to eq 6 }

    it 'should read yml value by get_all' do
      # TODO: make sure SettingWithYML.unscoped.all have keys,values from yml
    end

    it 'should allow set value into db' do
      SettingWithYML.str = "AAA"
      expect(SettingWithYML.str).to eq "AAA"
      SettingWithYML.str = 123
      expect(SettingWithYML.str).to eq 123
    end
  end
end
