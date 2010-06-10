source :gemcutter

group :development do
  gem "jeweler"
  gem "git"
  gem "sqlite3-ruby"
end

group :test, :rails3 do
  gem "hanoi"
  gem "rack", "1.1.0"
end

group :development, :test, :rails3 do
  gem "ruby-debug"
  gem "rspec"
end

if ENV["MORE_PAGINATE_ENV"] == "rails3"
  group :rails3 do
    gem "activesupport", "3.0.0.beta4"
    gem "activerecord", "3.0.0.beta4"
    gem "actionpack", "3.0.0.beta4"
  end
else
  group :test do
    gem "activesupport", "2.3.8"
    gem "activerecord", "2.3.8"
    gem "actionpack", "2.3.8"
  end
end