# Backward compatible to support 0.x scoped settings

The old `Scoped Settings` implement:

```rb
class User < ApplicationRecord
  include RailsSettings::Extend
end

@user.settings.color = "red"
@user.settings.foo = 123
```

You may used the scoped setting feature in 0.x version. Before you upgrade rails-settings-cached 2.x, you must follow this guide to backward compatible it.

## How to compatible in rails-settings-cached 2.x:

create `app/models/concerns/scoped_setting.rb`

```rb
module ScopedSetting
  extend ActiveSupport::Concern

  included do
    has_many :settings, as: :thing
  end

  class_methods do
    def scoped_field(name, default: nil)
      define_method(name) do
        obj = settings.where(var: name).take || settings.new(var: name, value: default)
        obj.value
      end

      define_method("#{name}=") do |val|
        record = settings.where(var: name).take || settings.new(var: name)
        record.value = val
        record.save!

        val
      end
    end
  end
end
```

Now include it for your model:

```rb
class User < ApplicationRecord
  include ScopedSetting

  scoped_field :color, default: ""
  scoped_field :foo, default: 0
end
```

Now you must to find project with ".setting." for replace with:

Same values will fetch from the `settings` table.

```rb
@user.color = "red"
@user.color # => "red"
@user.foo = 123
@user.foo # =>
```

## Performance Tip

> 🚨I strongly recommend that refactor your code to use ActiveRecord Serialize to storage your scoped settings.
> Here is an example for upgrade to ActiveRecord Serialize. https://github.com/ruby-china/homeland/commit/0963eac06ba4e77601d31fa526f81ff84103b15d

You need to avoid storage a lot scoped settings, that will slow down the settings load, because of the 2.x version of the rails-settings-cached will load all settings into memory on setting update.
