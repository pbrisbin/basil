require 'bundler/gem_tasks'
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

# it's getting tedious to manually modify the config away from skype
# just to test something in cli. this will make the change, run basil,
# then revert it when he quits. also uses a different pstore file so i
# don't modify any data used by the skype instance.
desc "temporarily run basil in cli mode"
task :cli do
  require 'yaml'
  require 'fileutils'

  Class.new do
    include FileUtils

    def run!
      config = 'config/basil.yml'
      backup = "#{config}.bak"

      mv config, backup

      File.open(backup, 'r') do |from|
        yaml = YAML::load(from)

        yaml['server_type'] = :cli
        yaml['pstore_file'] = '/tmp/basil.pstore'

        File.open(config, 'w') do |to|
          to.write(yaml.to_yaml)
        end
      end

      system('bundle exec bin/basil')
    ensure
      if File.exists?(backup)
        mv backup, config
      end
    end
  end.new.run! # nifty!
end

task :default => :spec
