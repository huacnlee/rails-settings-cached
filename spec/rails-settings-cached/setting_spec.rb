require "spec_helper"

describe RailsSettings do
  before(:all) do
    @str = "Foo bar"
    @tm = Time.now
    @items = [1,3,5,'as']
    @hash = { :name => @str, :items => @items }
    @merged_hash = { :name => @str, :items => @items, :id => 32 }
    @bar = "Bar foo"
    @user = User.create(:login => 'test', :password => 'foobar')
  end
  
  describe "Implementation" do
    it "can work with String value" do
      Setting.foo = @str
      Setting.foo.should == @str
    end
    
    it "can work with Array value" do
      Setting.items = @items
      Setting.items.should == @items
      Setting.items.class.should == @items.class
    end
    
    it "can work with DateTime value" do
      Setting.created_on = @tm
      Setting.created_on.should == @tm
    end
    
    it "can work with Hash value" do
      Setting.hashes = @hash
      Setting.hashes.should == @hash
      Setting.hashes.class.should == @hash.class
    end
    
    it "can work with namespace key" do
      Setting['config.color'] = :red
      Setting['config.limit'] = 100
    end
    
    it "can read last give namespace key's value" do
      Setting['config.color'].should == :red
      Setting['config.limit'].should == 100
    end
    
    it "can work with Merge to merge a Hash" do
      Setting.merge!(:hashes, :id => 32)
      Setting.hashes.should == @merged_hash
    end
    
    it "can read old data" do
      Setting.foo.should == @str
      Setting.items.should == @items
      Setting.created_on.should == @tm
      Setting.hashes.should == @merged_hash
    end
    
    it "can list all entries by Setting.all" do
      Setting.all.count.should == 6
      Setting.all('config').count.should == 2
    end
    
    it "can destroy a value" do
      Setting.destroy(:foo)
      Setting.foo.should == nil
      Setting.all.count.should == 5
    end
    
    it "can work with default value" do
      Setting.defaults[:bar] = @bar
      Setting.bar.should == @bar
    end
    
    it "can use default value, when the setting it cached with nil value" do
      Setting.has_cached_nil_key
      Setting.defaults[:has_cached_nil_key] = "123"
      Setting.has_cached_nil_key.should == "123"
    end
  end
  
  describe "Implementation by embeds a Model" do
    it "can set values" do
      @user.settings.level = 30
      @user.settings.locked = true
      @user.settings.last_logined_at = @tm
    end
    
    it "can read values" do
      @user.settings.level.should == 30
      @user.settings.locked.should == true
      @user.settings.last_logined_at.should == @tm
    end
  end
end