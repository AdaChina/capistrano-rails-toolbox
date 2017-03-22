class NotSupportDatabaseAdapter < RuntimeError; end

namespace :toolbox do
  namespace :db do
    desc <<-DESC
      load remote databse data to local, support adapter: mysql2, postgresql
    DESC
    task :load_remote do
      on roles(:db) do |server|
        info "make sure you are not connecting to the local database"

        local_config_path = 'config/database.yml'
        remote_config_path = "#{shared_path}/config/database.yml"

        puts <<-MSG
default local config path: #{local_config_path}
default remote config path: #{remote_config_path}
        MSG

        ask(:enter_path, "enter your custom config path?(Y/N)")
        if fetch(:enter_path) == 'Y'
          ask(:local_config_path, 'local database config path')
          ask(:remote_config_path, 'remote database config path')
          local_config_path = fetch(:local_config_path)
          remote_config_path = fetch(:remote_config_path)
        end

        remote_config = remote_db_config(remote_config_path)
        local_config = local_db_config(local_config_path)

        db_filename = "db_dump"
        dump_file_path = "#{fetch(:deploy_to)}/#{db_filename}"
        local_file_path = "/tmp/#{db_filename}"

        puts "start dumping database from remote..."
        no_output do
          execute dump_cmd(remote_config, dump_file_path)
        end

        puts "downloading..."
        no_output do
          download! dump_file_path, local_file_path
        end

        puts "reset local database"
        system "bundle exec rake db:drop"
        system "bundle exec rake db:create"

        puts "loading data..."
        system import_cmd(local_config, local_file_path)

        puts "removing dump file..."
        system "rm #{local_file_path}"
        no_output { execute "rm #{dump_file_path}" }
        puts "done!"
      end
    end

    def remote_db_config(path)
      remote_config = no_output do
        capture("cat #{path}")
      end

      YAML::load(remote_config)[fetch(:stage).to_s]
    end

    def local_db_config(path)
      YAML::load_file(path)["development"]
    end

    def dump_cmd(config, dump_file_path)
      case config['adapter']
      when 'postgresql'
        cmd = "export PGPASSWORD=#{config['password']}; pg_dump #{config['database']}" +
                " --username=#{config['username']} --no-owner --no-acl --format=c"
        cmd << " --host=#{config['host']}" unless config['host'].nil?
        cmd << " --port=#{config['port']}" unless config['port'].nil?
        cmd + " > #{dump_file_path}"
      when 'mysql2'
        cmd = "mysqldump --routines --user=#{config['username']}" +
                " --password=#{config['password']}"
        cmd << " --host=#{config['host']}" unless config['host'].nil?
        cmd << " --port=#{config['port']}" unless config['port'].nil?
        cmd + " #{config['database']} > #{dump_file_path}"
      else
        raise NotSupportDatabaseAdapter.new
      end
    end

    def import_cmd(config, db_file_path)
      case config['adapter']
      when 'postgresql'
        cmd = "export PGPASSWORD=#{config['password']}; pg_restore #{db_file_path}" +
                " --no-owner --no-acl -d #{config['database']}"
        cmd << " --host=#{config['host']}" unless config['host'].nil?
        cmd << " --port=#{config['port']}" unless config['port'].nil?
        cmd
      when 'mysql2'
        cmd = "mysql --user=#{config['username']} --password=#{config['password']}"
        cmd << " --host=#{config['host']}" unless config['host'].nil?
        cmd << " --port=#{config['port']}" unless config['port'].nil?
        cmd + " #{config['database']} < #{db_file_path}"
      else
        raise NotSupportDatabaseAdapter.new
      end
    end

    def no_output
      default = SSHKit.config.output
      SSHKit.config.output = SSHKit::Formatter::Pretty.new(String.new)
      result = yield
      SSHKit.config.output = default
      result
    end

    def db_config_path_msg
      "enter your custom config path?(Y/N)"
    end
  end
end
