require 'bundler/gem_tasks'

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
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

      system('./bin/basil')
    ensure
      if File.exists?(backup)
        mv backup, config
      end
    end
  end.new.run! # nifty!
end

task :default => :test
