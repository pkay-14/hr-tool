# Usage: bundle exec rake sidekiq:check

namespace :sidekiq do

  sidekiq_pid_file = Rails.root + 'tmp/pids/sidekiq.pid'

  desc 'Sidekiq check'
  task check: :environment do
    if Sidekiq::ProcessSet.new.size.zero?
      sidekiq_down
    else
      puts 'Sidekiq is running'
    end
  end

  desc 'Sidekiq stop'
  task :stop do
    puts '#### Trying to stop Sidekiq Now !!! ####'
    if File.exist?(sidekiq_pid_file)
      sidekiq_stop(sidekiq_pid_file)
    else
      puts '--- Sidekiq Not Running !!!'
    end
  end

  desc 'Sidekiq start'
  task :start do
    sidekiq_start
    if Sidekiq::ProcessSet.new.size.zero?
      sidekiq_could_not_restart
    else
      sidekiq_restarted_successfully(sidekiq_pid_file)
    end
  end

  desc 'Sidekiq restart'
  task :restart do
    puts '#### Trying to restart Sidekiq Now !!! ####'
    Rake::Task['sidekiq:stop'].invoke
    Rake::Task['sidekiq:start'].invoke
    puts '#### Sidekiq restarted successfully !!! ####'
  end

  private

  def sidekiq_down
    Airbrake.notify('Sidekiq down')
    Rake::Task['sidekiq:restart'].invoke
  end

  def sidekiq_stop(sidekiq_pid_file)
    puts "Stopping sidekiq now #PID-#{File.readlines(sidekiq_pid_file).first}..."
    system 'sidekiqctl stop tmp/pids/sidekiq.pid' # stops sidekiq process here
  end

  def sidekiq_start
    puts 'Starting Sidekiq...'
    system "bundle exec sidekiq -e#{Rails.env} -C config/sidekiq.yml -P tmp/pids/sidekiq.pid -d -L log/sidekiq.log" # starts sidekiq process here
    sleep(20)
  end

  def sidekiq_could_not_restart
    puts 'Sidekiq couldn\'t restart'
    Airbrake.notify('Sidekiq couldn\'t restart')
  end

  def sidekiq_restarted_successfully(sidekiq_pid_file)
    puts "Sidekiq started #PID-#{File.readlines(sidekiq_pid_file).first}."
    Airbrake.notify('Sidekiq restarted successfully')
  end
end
