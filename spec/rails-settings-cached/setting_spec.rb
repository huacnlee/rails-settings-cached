require "spec_helper"

describe RailsSettings do
  before(:all) do
    @str = "Foo bar"
    @tm = Time.now
    @items = [1, 3, 5, "as"]
    @hash = { name: @str, items: @items }
    @merged_hash = { name: @str, items: @items, id: 32 }
    @bar = "Bar foo"
    @user = User.create(login: "test", password: "foobar")
  end

  describe "#thing" do
    it "has belongs_to relationship to `thing`" do
      expect(Setting.reflect_on_association(:thing).macro).to eq(:belongs_to)
    end
  end

  describe "Getter and Setter" do
    context "String value" do
      it "can work with String value" do
        Setting.foo = @str
        expect(Setting.foo).to eq @str
      end
    end

    context "Boolean value" do
      before(:all) do
        Setting.boolean_foo = true
        Setting.boolean_bar = false
      end

      it { expect(Setting.boolean_foo).to be true }
      it { expect(Setting.boolean_bar).to be false }

      it "returns the same values if the cache is cleared" do
        Rails.cache.clear
        expect(Setting.boolean_foo).to be true
        expect(Setting.boolean_bar).to be false
      end
    end

    context "Array value" do
      before(:all) do
        Setting.items = @items
      end

      it { expect(Setting.items).to eq @items }
      it { expect(Setting.items).to be_a(Array) }
    end

    context "DateTime value" do
      before(:all) do
        Setting.created_on = @tm
      end
      it { expect(Setting.created_on).to eq @tm }
      it { expect(Setting.created_on).to be_a(Time) }
    end

    context "Hash value" do
      before(:all) do
        Setting.hashes = @hash
      end
      it { expect(Setting.hashes).to eq @hash }
      it { expect(Setting.hashes).to be_a(Hash) }
    end

    context "namespace for key" do
      before(:all) do
        Setting["config.color"] = :red
        Setting["config.limit"] = 100
      end
      it { expect(Setting["config.color"]).to eq :red }
      it { expect(Setting["config.limit"]).to eq 100 }
    end

    context "defaults within namespace for key" do
      before do
        allow(RailsSettings::Default).to receive(:instance).and_return("config.dcolor" => :blue, "config.dlimit" => 200)
      end

      it { expect(Setting["config.dcolor"]).to eq :blue }
      it { expect(Setting["config.dlimit"]).to eq 200 }
    end

    context "Merge hash" do
      before(:all) do
        Setting.merge!(:hashes, id: 32)
      end
      it { expect(Setting.hashes).to include(id: 32) }
      it { expect(Setting.hashes).to include(@hash) }
    end
  end

  describe "#all" do
    it "should work" do
      expect(Setting.all.count).to eq 8
    end
  end

  describe "#get_all" do
    it "should include defaults" do
      expect(RailsSettings::Default).to receive(:instance).and_return(default1: 1, default2: "2")
      expect(Setting.get_all).to include(:default1, :default2)
    end

    it "should include namespace defaults" do
      expect(RailsSettings::Default).to receive(:instance).and_return("test.default1" => 1, "test.default2" => "2", demo: 3)
      expect(Setting.get_all("test.")).to include(:'test.default1', :'test.default2')
    end

    it "should all('namespace')" do
      expect(Setting.get_all("config")).to eq("config.color" => :red, "config.limit" => 100)
      expect(Setting.get_all("config").count).to eq 2
    end

    it "overwrites default values" do
      Setting.str = "abc"
      expect(Setting.get_all["str"]).to eq("abc")
    end
  end

  describe "#destroy" do
    before(:all) do
      Setting.destroy(:foo)
    end

    it { expect(Setting.foo).to be_nil }
    it { expect(Setting.all.count).to eq 8 }

    it "can destroy a falsy value" do
      Setting.falsy_value = false
      Setting.destroy(:falsy_value)
      expect(Setting.falsy_value).to be_nil
    end
  end

  describe "Implementation by embeds a Model" do
    it "can set values" do
      @user.settings.level = 30
      @user.settings.locked = true
      @user.settings.last_logined_at = @tm
      Setting.level = 20
      expect(Setting.unscoped.where(var: "level").count).to eq 2
      expect(Setting.where(var: "level").count).to eq 1
      Setting.where(var: "level").first.value == 20
    end

    it "can read values" do
      expect(@user.settings.level).to eq 30
      expect(@user.settings.locked).to eq true
      expect(@user.settings.last_logined_at).to eq @tm
    end
  end

  describe "Query all items" do
    describe "#unscoped" do
      it "should work" do
        expect(Setting.unscoped).to be_a(ActiveRecord::Relation)
      end

      it "should get items more than 8" do
        Setting.aa = Time.now
        expect(Setting.unscoped.count).to be > 8
      end
    end

    describe "#find" do
      let(:obj) { Setting.unscoped.first }
      let(:id) { obj.id }

      it "should work with find" do
        expect(Setting.unscoped.find(id)).to eq obj
      end
    end
  end

  describe "Custom table name" do
    it "should work" do
      expect(CustomSetting.foo).to eq(nil)
      CustomSetting.foo = 123
      expect(CustomSetting.foo).to eq(123)
    end
  end
end
