
Dir[File.join(File.dirname(__FILE__), '..', 'tasks', '*.rake')].each do |path|
  load path
end