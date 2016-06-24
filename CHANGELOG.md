## 0.6.5

- Return direct value first for existing default keys. (#111)
- Fix defaults merge when get_all. (#110)
- Fix deprecated syntax in the model generator (#107)

## 0.6.4

- Fix cache key with multiple processes.

## 0.6.3

- Ensure defaults not overwrite persisted settings (#98) (Kevin Sjöberg)

## 0.6.2

- Make sure YAML default settings can work when Rails not initialized (in Rails initializes or environments/*.rb)

## 0.6.1

- Make sure YAML default settings can work when settings table does not exist (For example in Rails initializes).

## 0.6.0

- Add `config/app.yml` for write you default settings in file.
- Change generator command from `rails g settings` to `rails g settings:install`.
- [Deprecated] RailsSettings::CachedSettings, please use RailsSettings::Base.
- [Deprecated] Setting.defaults method, use YAML file instead.
- [Deprecated] Setting.save_default method, use YAML file instead.
- Removed `SettingsDefaults::DEFAULTS` support.
- Change cache key prefix after restart Rails application server (This for make sure cache will expire, when you update default config in YAML file).
- If the value was set to false, either the default is returned or if there is no default, then nil would be returned. @dangerous

## 0.5.6

- Fixed inheritance of RailsSettings::CachedSettings to use RailsSettings::Base.

## 0.5.5

- Change default g
- [Deprecated] RailsSettings::Settings, please use RailsSettings::Base.


## 0.5.4

- Update the cached value for the key when value set.
- Return nil if value not present;

## 0.5.3

- Fixed mistake, when scoped result contains global defaults which not in scope. (Alexander Merkulov)

## 0.5.2

- Gem spec require Ruby 2.0+; @alexanderadam
- Include defaults in get_all call; @alexanderadam

## 0.5.0

- Allow setting dynamic cache prefix. So that settings can be arbitrarily
scoped based on some context (e.g. current tenant). @artemave

# For Rails 4.1.x

## 0.4.6

- Fix scoped cache key name.


## 0.4.5

- Cache db values that does not exist within rails cache.

## 0.4.4

- Add cached to model scoped settings.

## 0.4.3

- Fix Rails 4.2.4 `after_rollback`/`after_commit` depreciation warnings. @miks

## 0.4.2

- Ruby new hash syntax and do not support Ruby 1.9.2 from now.
- Cache key has changed with `rails_settings_cached` prefix.

## 0.4.1

- ActiveRecord `table_name_prefix` support; #31

## 0.4.0

- Rails 4.1.0 compatibility.
- Setting.all -> Setting.get_all

# For Rails 4.0.x - 4.1.x

## 0.3.2

- Enable destroy-ing a key with falsy data; #32
- Require Rails 4.0.0+;

## 0.3.1

- false value can't got back bug has fixed.

## 0.3.0

- Fix to work with Rails 4.0.0

# For Rails 3.x

## 0.2.4

- Setting.save_default method to direct write default value in database.
- fix mass-update bug.

## 0.2.3

- Fix bug with when key has cached a nil value, and then set a default value for that key,
the default value can't right return.

## 0.2.2

- Add auto cache feature to all key visit.
