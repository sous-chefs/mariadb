begin
  # Make sure and put requires here so users will get the error message
  require 'colored'
# rubocop:disable RescueException
rescue Exception
  # rubocop:enable RescueException
  puts 'Missing a dependency, did you install the bundle?'
  exit 1
end
# TODO: Make this stuff a lib similar to https://github.com/postmodern/rubygems-tasks

# Warn of possible oddities
if ENV['SHELL'].include?('zsh') && !ENV['DISABLE_ZSH_RAKE_WARN']
  puts '****************************************'.green
  puts "I see you're using everyone's favorite shell ZSH!, be aware it may behave badly when passing unescaped params to rake".red
  puts 'Take a look at https://robots.thoughtbot.com/how-to-use-arguments-in-a-rake-task for more info'.red
  puts "If you'd like to disable this message, please 'export DISABLE_ZSH_RAKE_WARN=1' in your .zshrc".red
  puts '****************************************'.green
end

require 'bundler'
task default: [:tasks]

desc 'Lists rake tasks with dependencies'
task :tasks do
  run('rake -T', 'Failed to rake')
  run("grep ^task Rakefile | grep '=>'", 'Failed to grep Rakefile')
end

namespace :cookbook do
  desc 'Hard reverts to latest master'
  task :prep do
    force = ENV['force']

    run('echo $- | grep -q i && exit 1', 'Not supported in an interactive shell! Override with force=1') unless force

    run('git fetch origin', 'Failed to update from origin')
    run('git checkout master', 'Failed to check out master')
    run('git reset --hard origin/master', 'Failed to reset to origin/master')
    run('git clean -fd', 'Failed to clean working directory')
    run('git checkout .', 'Failed to check out working directory')
  end

  desc 'Packages the next version of the cookbook'
  task :package do
    run('bundle install --path vendor', 'Failed to install bundle')
    run('bundle exec thor version:bump patch', 'Failed to increment cookbook version')
    run('rm -f Berksfile.lock', 'Failed to remove Berksfile.lock')
    run('berks install', 'Failed to install cookbooks')
  end

  desc 'Uploads the cookbook'
  task :upload do
    run('berks upload', 'Failed to upload the cookbook')
  end
end

namespace :chef_local do
  # Always put a / on the end of a directory
  databag_secret_path = ENV['CHEF_DATABAG_KEY_PATH'] || 'test/integration/encrypted_data_bag_secret'
  databag_path = ENV['CHEF_DATABAG_PATH'] || 'test/integration/data_bags/'

  desc 'Edit local databag, creates if not already exists'
  task :edit_encrypted_databag, [:bag, :item] do |_t, args|
    unless File.exist?(databag_secret_path)
      print "Secret doesn't exist, would you like to generate one? [Y]/N "
      STDOUT.flush
      input = STDIN.gets.chomp
      if input.upcase == 'N'
        puts 'Bailing out'
        exit 1
      end
      Rake::Task['chef_local:generate_databag_key'].invoke
    end

    verbose(false) do
      if File.exist?("#{databag_path}#{args[:bag]}/#{args[:item]}.json")
        sh "knife solo data bag edit --data-bag-path #{databag_path} --secret-file #{databag_secret_path} #{args[:bag]} #{args[:item]}"
      else
        sh "knife solo data bag create --data-bag-path #{databag_path} --secret-file #{databag_secret_path} #{args[:bag]} #{args[:item]}"
      end
    end
  end

  desc 'List local databags and items'
  task :list do
    puts '--'.blue
    puts "Using key #{databag_secret_path}".yellow
    puts "Using path #{databag_path}".yellow
    puts '--'.blue

    Dir["#{databag_path}*"].each do |bag|
      puts '--'.blue
      puts 'Databag:'.blue
      puts '  ' + bag.gsub(databag_path, '').green
      puts 'Items:'.blue
      Dir["#{bag}/*"].each do |item|
        puts '  ' + File.basename(item, '.*').green
      end
    end
    puts '--'.blue
  end

  desc 'Generate Key'
  # TODO: Should look to see if we're overwriting the file
  task :generate_databag_key do
    verbose(false) do
      unless sh 'which openssl 2>&1 > /dev/null'
        puts 'Please install openssl'
        exit 1
      end
      if File.exist?(databag_secret_path)
        print 'Would you like to replace the existing key? Y/[N] '
        STDOUT.flush
        input = STDIN.gets.chomp
        if input.upcase != 'Y'
          puts 'Bailing out'
          exit 1
        end
        puts 'Overwriting existing key'
      end
      sh "openssl rand -base64 512 > #{databag_secret_path}"
      puts 'Done.'
    end
  end
end

# ripped off from https://gist.github.com/MattesGroeger/8665983
def run(command, message)
  puts "\n==== Run Command: `#{command}` ====\n\n"
  Bundler.with_clean_env do
    # rubocop:disable UselessAssignment
    # rubocop:disable AssignmentInCondition
    process = IO.popen(command) do |io|
      while line = io.gets
        # rubocop:enable AssignmentInCondition
        puts line
      end
      io.close
    end
    fail message if $CHILD_STATUS.to_i != 0
    # rubocop:enable UselessAssignment
  end
end
