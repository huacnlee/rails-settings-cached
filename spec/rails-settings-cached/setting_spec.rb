require 'spec_helper'

describe RailsSettings do
  before(:all) do
    @str = 'Foo bar'
    @tm = Time.now
    @items = [1, 3, 5, 'as']
    @hash = { name: @str, items: @items }
    @merged_hash = { name: @str, items: @items, id: 32 }
    @bar = 'Bar foo'
    @user = User.create(login: 'test', password: 'foobar')
  end

  describe "#thing" do
    it "has belongs_to relationship to `thing`" do
      expect(Setting.reflect_on_association(:thing).macro).to eq(:belongs_to)
    end
  end

  describe 'Getter and Setter' do
    context 'String value' do
      it 'can work with String value' do
        Setting.foo = @str
        expect(Setting.foo).to eq @str
      end
    end

    context 'Boolean value' do
      before(:all) do
        Setting.boolean_foo = true
        Setting.boolean_bar = false
      end

      it { expect(Setting.boolean_foo).to be_truthy }
      it { expect(Setting.boolean_bar).to be_falsey }
    end

    context 'Array value' do
      before(:all) do
        Setting.items = @items
      end

      it { expect(Setting.items).to eq @items }
      it { expect(Setting.items).to be_a(Array) }
    end

    context 'DateTime value' do
      before(:all) do
        Setting.created_on = @tm
      end
      it { expect(Setting.created_on).to eq @tm }
      it { expect(Setting.created_on).to be_a(Time) }
    end

    context 'Hash value' do
      before(:all) do
        Setting.hashes = @hash
      end
      it { expect(Setting.hashes).to eq @hash }
      it { expect(Setting.hashes).to be_a(Hash) }
    end

    context 'namespace for key' do
      before(:all) do
        Setting['config.color'] = :red
        Setting['config.limit'] = 100
      end
      it { expect(Setting['config.color']).to eq :red }
      it { expect(Setting['config.limit']).to eq 100 }
    end

    context 'Merge hash' do
      before(:all) do
        Setting.merge!(:hashes, id: 32)
      end
      it { expect(Setting.hashes).to include(id: 32) }
      it { expect(Setting.hashes).to include(@hash) }
    end
  end

  describe '#all' do
    it 'should work' do
      expect(Setting.all.count).to eq 8
    end

    it "should all('namespace')" do
      expect(Setting.get_all('config').count).to eq 2
    end
  end

  describe '#destroy' do
    before(:all) do
      Setting.destroy(:foo)
    end

    it { expect(Setting.foo).to be_nil }
    it { expect(Setting.all.count).to eq 7 }

    it 'can destroy a falsy value' do
      Setting.falsy_value = false
      Setting.destroy(:falsy_value)
      expect(Setting.falsy_value).to be_nil
    end
  end

  describe 'Default values' do
    it 'can work with default value' do
      Setting.defaults[:bar] = @bar
      expect(Setting.bar).to eq @bar
    end

    it 'can use default value, when the setting it cached with nil value' do
      Setting.has_cached_nil_key
      Setting.defaults[:has_cached_nil_key] = '123'
      expect(Setting.has_cached_nil_key).to eq '123'
    end

    it '#save_default' do
      Setting.test_save_default_key
      Setting.save_default(:test_save_default_key, '321')
      expect(Setting.where(var: 'test_save_default_key').count).to eq 1
      expect(Setting.test_save_default_key).to eq '321'
      Setting.save_default(:test_save_default_key, '3211')
      expect(Setting.test_save_default_key).to eq '321'
    end
  end

  describe 'Implementation by embeds a Model' do
    it 'can set values' do
      @user.settings.level = 30
      @user.settings.locked = true
      @user.settings.last_logined_at = @tm
      Setting.level = 20
      expect(Setting.unscoped.where(var: 'level').count).to eq 2
      expect(Setting.where(var: 'level').count).to eq 1
      Setting.where(var: 'level').first.value == 20
    end

    it 'can read values' do
      expect(@user.settings.level).to eq 30
      expect(@user.settings.locked).to eq true
      expect(@user.settings.last_logined_at).to eq @tm
    end
  end

  describe 'Query all items' do
    describe '#unscoped' do
      it 'should work' do
        expect(Setting.unscoped).to be_a(ActiveRecord::Relation)
      end

      it 'should get items more than 8' do
        Setting.aa = Time.now
        expect(Setting.unscoped.count).to be > 8
      end
    end

    describe '#find' do
      let(:obj) { Setting.unscoped.first }
      let(:id) { obj.id }

      it 'should work with find' do
        expect(Setting.unscoped.find(id)).to eq obj
      end
    end

    describe '#with_settings_for' do
      it 'should only return items with matching settings' do
        User.create.settings.color = 'green'
        User.create.settings.color = 'red'
        User.create.settings.color = 'green'

        expect(User.with_setting_value('color', 'red').count).to be 1
        expect(User.with_setting_value('color', 'green').count).to be 2
      end
    end
  end

  describe 'Custom table name' do
    it 'should work' do
      expect(CustomSetting.foo).to eq(nil)
      CustomSetting.foo = 123
      expect(CustomSetting.foo).to eq(123)
    end
  end
end
