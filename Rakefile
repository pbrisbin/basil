require 'rdoc/task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.pattern    = "./spec/**/*_spec.rb"
  t.rspec_opts = '-c'
  t.verbose    = false
end

Rake::RDocTask.new do |rd|
  rd.title = 'Basil'
  rd.rdoc_dir = './doc'
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
end

desc "shortcut to run basil in cli mode"
task :cli do
  cmd =  'bundle exec bin/basil --cli'
  cmd += ' --debug' if ENV['DEBUG']

  system(cmd)
end

task :default => :spec
