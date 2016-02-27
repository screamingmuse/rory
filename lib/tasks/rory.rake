require 'irb'

namespace :rory do
  desc "Opens IRB console with Rory application loaded"
  task :console => :environment do
    command = ARGV.shift
    IRB.start
  end

  desc "List out middleware stack in load order"
  task :middleware => :environment do
    Rory.application.run_initializers
    puts Rory.application.middleware.map(&:klass).map(&:to_s).join("\n")
  end

  desc "List out initializers in load order"
  task :initializers => :environment do
    puts Rory::Application.initializers.map(&:name).join("\n")
  end
end

namespace :log do
  desc "Truncates all logs"
  task :clear do
    FileList[File.join('log', '*.log')].each do |file|
      File.open(file, 'w').close
    end
  end
end

desc "Shows all rake tasks and their locations"
task :tasks do
  tasks = Rake.application.tasks.map { |t|
    { 'name' => t.name, 'location' => t.locations }
  }
  puts tasks
end
