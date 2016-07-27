namespace :toolbox do
  namespace :pg do
    desc <<-DESC
      load remote databse data to local
    DESC
    task :load_remote_db do
      on roles(:db) do |server|
        info "make sure you are not connecting to the local database"

        username, password, database, host = remote_database_config(fetch(:stage))
        l_username, l_password, l_database, l_host = local_database_config

        backup_file_name = "pg_dump.sql.bz2"
        dump_file_path = "#{fetch(:deploy_to)}/#{backup_file_name}"
        local_file_path = "/tmp/#{backup_file_name}"
        unzip_file_path = "/tmp/pg_dump.sql"

        info "start dumping database from remote..."
        no_output do
          execute "export PGPASSWORD=#{password}; pg_dump -U #{username} -h #{host} #{database} -a --no-owner --no-acl | bzip2 -9 > #{dump_file_path}"
        end

        info "downloading..."
        download! dump_file_path, local_file_path

        info "decompressing..."
        system "bzip2 -d -c #{local_file_path} >> #{unzip_file_path}"

        info "reset local database"
        system "bundle exec rake db:drop"
        system "bundle exec rake db:create"
        system "bundle exec rake db:schema:load"

        info "loading data..."
        system "export PGPASSWORD=#{password}; psql -U #{l_username} #{l_database} < #{unzip_file_path}"
        system "rm #{local_file_path}"
        system "rm #{unzip_file_path}"
        execute "rm #{dump_file_path}"
        info "done!"
      end
    end

    def remote_database_config(stage)
      remote_config = no_output do
        capture("cat #{shared_path}/config/database.yml")
      end

      database_config = YAML::load(remote_config)["#{stage}"]

      [
        database_config['username'],
        database_config['password'],
        database_config['database'],
        database_config['host'],
      ]
    end

    def local_database_config
      database_config = YAML::load_file("config/database.yml")["development"]

      [
        database_config['username'],
        database_config['password'],
        database_config['database'],
        database_config['host'],
      ]
    end

    def no_output
      default = SSHKit.config.output
      SSHKit.config.output = SSHKit::Formatter::Pretty.new(String.new)
      result = yield
      SSHKit.config.output = default
      result
    end
  end
end
