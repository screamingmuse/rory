namespace :db do
  task :load_extensions => :environment do
    Sequel::Database.extension :schema_dumper
    Sequel::Database.extension :migration
  end

  desc "Migrate database to current version (or given version if arg)"
  task :migrate, [:version] => :load_extensions do |task, args|
    latest_version = `cd #{File.join(Rory.root, 'db', 'migrate')} && ls -1 [0-9]*_*.rb | tail -1 | sed -e s/_.*$//`
    args.with_defaults(:version => latest_version)
    migration_dir = File.join(Rory.root, 'db', 'migrate')
    Sequel::Migrator.run(RORY_APP.db, migration_dir, :target => args[:version].to_i)
  end

  desc "Drop and recreate a database"
  task :purge => :load_extensions do
    config = RORY_APP.db_config[ENV['RORY_STAGE']]
    drop_database_from_config(config)
    create_database_from_config(config)
  end

  namespace :schema do
    desc "Dump schema from database into db/schema.rb"
    task :dump => :load_extensions do
      migration = RORY_APP.db.dump_schema_migration
      schema_file = File.join(Rory.root, 'db', 'schema.rb')
      File.open(schema_file, 'w') { |f| f.write migration }
    end

    desc "Loads schema from db/schema.rb into current environment's DB"
    task :load => :load_extensions do
      schema_file = File.read(File.join(Rory.root, 'db', 'schema.rb'))
      eval(schema_file).apply(RORY_APP.db, :up)
    end
  end

  namespace :test do
    desc "Loads db/schema.rb into test database"
    task :load => [:load_extensions, :purge] do
      RORY_APP.connect_db('test')
      Rake::Task["db:schema:load"].invoke
    end

    desc "Purges test database"
    task :purge => :load_extensions do
      ENV['RORY_STAGE'] = 'test'
      Rake::Task["db:purge"].invoke
    end

    desc "Recreates empty test database from development's schema"
    task :prepare => ['db:schema:dump', 'db:test:load']
  end

  def drop_database_from_config(config)
    RORY_APP.db << "DROP DATABASE IF EXISTS \"#{config['database']}\""
  end

  def create_database_from_config(config)
    RORY_APP.db << "CREATE DATABASE \"#{config['database']}\""
  end
end