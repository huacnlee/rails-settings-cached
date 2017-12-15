require 'spec_helper'

describe RailsSettings::Default do
  class SettingWithYML < RailsSettings::Base
  end

  class OtherSettingWithYML < RailsSettings::Base
    self.table_name = 'other_settings'
  end

  describe 'YMLSetting config' do
    it { expect(RailsSettings::Default.enabled?).to eq true }
    it { expect(RailsSettings::Default.source_path.to_s).to eq File.expand_path('../../config/rails_settings/test.yml', __FILE__) }

    it 'works in different enviroment' do
      string_inquirer = ActiveSupport::StringInquirer.new('production')
      allow(Rails).to receive(:env).and_return(string_inquirer)

      expect(RailsSettings::Default.source_path.to_s).to eq File.expand_path('../../config/rails_settings/production.yml', __FILE__)
    end
  end

  describe 'It can work without tables' do
    it 'should work' do
      expect(OtherSettingWithYML.str).to eq 'hello in test'
      expect(OtherSettingWithYML.script).to eq 6
    end

    it 'should work when Rails.cache not initialized' do
      allow(Rails).to receive(:cached).and_return(nil)
      allow(Rails).to receive(:initialized?).and_return(false)
      expect(OtherSettingWithYML.str).to eq 'hello in test'
    end
  end

  describe 'Base test' do
    it 'should not hit SQL' do
      Rails.cache.clear
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
      SettingWithYML.str = 'AAA'
      expect(SettingWithYML.str).to eq 'AAA'
      SettingWithYML.str = 123
      expect(SettingWithYML.str).to eq 123
      SettingWithYML['yml_foo.bar'] = 'AAA1'
      expect(SettingWithYML['yml_foo.bar']).to eq 'AAA1'
    end
  end
end
