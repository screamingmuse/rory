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