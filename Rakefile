$:.unshift 'lib'
require 'rubygems'
require 'hanoi'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rspec/core/rake_task'

task :default => 'spec:all'
namespace :spec do
  desc "Run all the specs."
  task :all => [ :spec, 'spec:javascripts' ] do
  end

  desc "Runs all the JavaScript tests and collects the results"
  JavaScriptTestTask.new(:javascripts) do |t|
    test_cases        = ENV['TESTS'] && ENV['TESTS'].split(',')
    browsers          = ENV['BROWSERS'] && ENV['BROWSERS'].split(',')
    sources_directory = File.expand_path(File.dirname(__FILE__) + "/assets/javascripts")

    t.setup(sources_directory, test_cases, browsers)
  end
end

RSpec::Core::RakeTask.new do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['-fs --color --backtrace']
end
