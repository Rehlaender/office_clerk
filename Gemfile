source 'https://rubygems.org'

gem "office_clerk" , :path => "../"

gem 'sqlite3'

gem 'carrierwave'

#asset / production reelated
gem "therubyracer"
gem "libv8" , "3.16.14.13"
gem "rb-readline"
gem 'uglifier', '>= 1.3.0'

# those guys dropped 1.9 support, but i haven't
gem "autoprefixer-rails" , '< 6.0' , :platform => [:ruby_19]

group :development do
  gem 'better_errors' , :platforms=>[:mri_20, :mri_21, :rbx]
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :mri_21,:rbx]
  gem 'quiet_assets'
  gem "i18n-tasks" , "0.8.7"
end
group :test do
  gem "codeclimate-test-reporter"
  gem 'rspec-rails'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem "factory_girl_rails"
  gem 'email_spec'
  gem 'i18n-spec'
  gem 'guard-rails'
  gem 'guard-rspec'
end
