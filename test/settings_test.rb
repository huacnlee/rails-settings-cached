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
    
    assert_nil Settings.one
    assert_nil Settings.two
    assert_nil user1.settings.two
    assert_nil user2.settings.one
  end
  
  private
    def assert_setting(value, key, scope_object=nil)
      key = key.to_sym
      
      if scope_object
        assert_equal value, scope_object.instance_eval("settings.#{key}")
        
        # Array indexing on scopes does not work. Why?
        # assert_equal value, scope_object.settings[key.to_sym]
        # assert_equal value, scope_object.settings[key.to_s]
        #
        # As a work-around, use a "get" method
        assert_equal value, scope_object.settings.get(key.to_sym)
        assert_equal value, scope_object.settings.get(key.to_s)
      else
        assert_equal value, eval("Settings.#{key}")
        assert_equal value, Settings[key.to_sym]
        assert_equal value, Settings[key.to_s]
      end
    end
    
    def assert_assign_setting(value, key, scope_object=nil)
      key = key.to_sym
      
      if scope_object
        assert_equal value, scope_object.instance_eval("settings.#{key} = value")
        assert_setting value, key, scope_object
        scope_object.instance_eval("settings.#{key} = nil")
      
        assert_equal value, (scope_object.settings.set(key,value))
        assert_setting value, key, scope_object
        scope_object.settings.set(key, nil)
      
        assert_equal value, (scope_object.settings.set(key.to_s,value))
        assert_setting value, key, scope_object
      else
        assert_equal value, eval("Settings.#{key} = value")
        assert_setting value, key
        eval("Settings.#{key} = nil")
      
        assert_equal value, (Settings[key] = value)
        assert_setting value, key
        Settings[key] = nil
      
        assert_equal value, (Settings[key.to_s] = value)
        assert_setting value, key
      end
    end
end