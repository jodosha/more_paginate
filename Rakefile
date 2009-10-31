require "rubygems"
require "spec/rake/spectask"
require "hanoi"

task :default => "spec:all"
namespace :spec do
  desc "Run all the specs."
  task :all => [ :spec, "spec:javascripts" ] do
  end

  desc "Runs all the JavaScript tests and collects the results"
  JavaScriptTestTask.new(:javascripts) do |t|
    test_cases        = ENV['TESTS'] && ENV['TESTS'].split(',')
    browsers          = ENV['BROWSERS'] && ENV['BROWSERS'].split(',')
    sources_directory = File.expand_path(File.dirname(__FILE__) + "/assets/javascripts")

    t.setup(sources_directory, test_cases, browsers)
  end
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(-fs --color)
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
end
