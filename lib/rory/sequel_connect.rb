module Rory
  module SequelConnect
    def connect_db(environment = ENV['RORY_ENV'])
      @db_config = load_config_data(:database)
      @db = Sequel.connect(@db_config[environment.to_s])
      @db.loggers << logger
    end

    # @deprecated Use {#connect_db} instead of this method because that's all it does any ways.
    def spin_up
      connect_db
    end
  end
end
