module Rory
  module Logging
    attr_writer :logger, :log_file, :log_path

    def log_path
      @log_path ||= root_path.join('log')
    end

    def log_file
      @log_file ||= begin
        Dir.mkdir(log_path) unless File.exists?(log_path)
         File.open(log_path.join("#{ENV['RORY_ENV']}.log"), 'a').tap { |file| file.sync = true }
      end
    end

    def logger
      @logger ||= Rory::Logger.new(log_file)
    end
  end
end
