require 'test_helper'

class SettingsTest < Test::Unit::TestCase
  def setup
    setup_db
    Settings.create(:var => 'test',  :value => 'foo')
    Settings.create(:var => 'test2', :value => 'bar')
  end

  def teardown
    teardown_db
  end
	
  def test_defaults
    Settings.defaults[:foo] = 'default foo'
    
    assert_nil Settings.object(:foo)
    assert_equal 'default foo', Settings.foo
    
    Settings.foo = 'bar'
    assert_equal 'bar', Settings.foo
    assert_not_nil Settings.object(:foo)
  end
  
	def test_get
		assert_setting 'foo', :test
		assert_setting 'bar', :test2
	end

	def test_update
		assert_assign_setting '321', :test
	end
	
	def test_create
    assert_assign_setting '123', :onetwothree
	end
  
  def test_complex_serialization
    complex = [1, '2', {:three => true}]
    Settings.complex = complex
    assert_equal complex, Settings.complex
  end
  
  def test_serialization_of_float
    Settings.float = 0.01
    Settings.reload
    assert_equal 0.01, Settings.float
    assert_equal 0.02, Settings.float * 2
  end
  
  def test_object_scope
    user1 = User.create :name => 'First user'
    user2 = User.create :name => 'Second user'
    
    assert_assign_setting 1, :one, user1
    assert_assign_setting 2, :two, user2
		
    assert_setting 1, :one, user1
    assert_setting 2, :two, user2
    
    assert_setting nil, :one
    assert_setting nil, :two
    
    assert_setting nil, :two, user1
    assert_setting nil, :one, user2
    
    assert_equal({ "one" => 1}, user1.settings.all('one'))
    assert_equal({ "two" => 2}, user2.settings.all('two'))
    assert_equal({ "one" => 1}, user1.settings.all('o'))
    assert_equal({}, user1.settings.all('non_existing_var'))
  end
  
  def test_all
    assert_equal({ "test2" => "bar", "test" => "foo" }, Settings.all)
    assert_equal({ "test2" => "bar" }, Settings.all('test2'))
    assert_equal({ "test2" => "bar", "test" => "foo" }, Settings.all('test'))
    assert_equal({}, Settings.all('non_existing_var'))
  end
  
  def test_merge
    assert_raise(TypeError) do
      Settings.merge! :test, { :a => 1 }
    end

    Settings[:hash] = { :one => 1 }
    Settings.merge! :hash, { :two => 2 }
    assert_equal({ :one => 1, :two => 2 }, Settings[:hash])
    
    assert_raise(ArgumentError) do
      Settings.merge! :hash, 123
    end
    
    Settings.merge! :empty_hash, { :two => 2 }
    assert_equal({ :two => 2 }, Settings[:empty_hash])
  end
  
  private
    def assert_setting(value, key, scope_object=nil)
      key = key.to_sym
      
      if scope_object
        assert_equal value, scope_object.instance_eval("settings.#{key}")
        assert_equal value, scope_object.settings[key.to_sym]
        assert_equal value, scope_object.settings[key.to_s]
      else
        assert_equal value, eval("Settings.#{key}")
        assert_equal value, Settings[key.to_sym]
        assert_equal value, Settings[key.to_s]
      end
    end
    
    def assert_assign_setting(value, key, scope_object=nil)
      key = key.to_sym
      
      if scope_object
        assert_equal value, (scope_object.settings[key] = value)
        assert_setting value, key, scope_object
        scope_object.settings[key] = nil
      
        assert_equal value, (scope_object.settings[key.to_s] = value)
        assert_setting value, key, scope_object
      else
        assert_equal value, (Settings[key] = value)
        assert_setting value, key
        Settings[key] = nil
      
        assert_equal value, (Settings[key.to_s] = value)
        assert_setting value, key
      end
    end
end