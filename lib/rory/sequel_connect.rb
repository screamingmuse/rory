module Rory
  module SequelConnect
    def connect_db(environment = ENV['RORY_ENV'])
      @db_config = load_config_data(:database)
      @db = Sequel.connect(@db_config[environment.to_s])
      @db.loggers << logger
    end
  end
end
