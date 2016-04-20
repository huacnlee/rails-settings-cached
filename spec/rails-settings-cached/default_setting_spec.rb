require 'spec_helper'

describe RailsSettings::Default do
  class SettingWithYML < RailsSettings::Base
  end

  describe 'YMLSetting config' do
    it { expect(RailsSettings::Default.enabled?).to eq true }
    it { expect(RailsSettings::Default.source_path.to_s).to eq File.expand_path("../../config/app.yml", __FILE__) }
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
        SettingWithYML['yml_foo.bar']
      end
      expect(queries_count).to eq 4
    end

    it { expect(SettingWithYML.str).to eq 'hello in test' }
    it { expect(SettingWithYML.script).to eq 6 }
    it { expect(SettingWithYML['yml_foo.bar']).to eq 'Foo bar' }

    it 'should read yml value by get_all' do
      # TODO: make sure SettingWithYML.unscoped.all have keys,values from yml
    end

    it 'should allow set value into db' do
      SettingWithYML.str = "AAA"
      expect(SettingWithYML.str).to eq "AAA"
      SettingWithYML.str = 123
      expect(SettingWithYML.str).to eq 123
      SettingWithYML['yml_foo.bar'] = "AAA1"
      expect(SettingWithYML['yml_foo.bar']).to eq "AAA1"
    end
  end
end
