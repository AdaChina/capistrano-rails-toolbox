namespace :toolbox do
  namespace :remote do
    desc <<-DESC
      open a rails console for remote
    DESC
    task :console do
      on roles(:app) do |server|
        puts "Opening a console on: #{host}...."
        command = "cd #{fetch(:deploy_to)}/current && "\
                  "RAILS_ENV=#{fetch(:stage)} "\
                  "#{SSHKit.config.command_map[:bundle]} exec rails console"
        puts command
        exec "ssh #{server.user}@#{host} -t '#{command}'"
      end
    end

    desc <<-DESC
      tail rails log file
    DESC
    task :log do
      on roles :app do
        set :log_level, :debug
        set :format, :pretty
        configure_backend

        log_path = "#{shared_path}/log/#{fetch(:rails_env)}.log"
        command = "tail -F #{log_path}"
        puts command
        execute command
      end
    end

    desc <<-DESC
      download [stage].log file to local, enter the path to store the log file, current path for blank
    DESC

    task :download_log do
      on roles :app do
        log_fname = "#{fetch(:rails_env)}.log"
        ask(:local_path,
            '')
        puts fetch(:local_path)
        local_path = if fetch(:local_path).chars.count == 0
                       "#{`pwd`.delete("\n")}/#{log_fname}"
                     else
                       "#{fetch(:local_path)}/#{log_fname}"
                     end
        log_path = "#{shared_path}/log/#{log_fname}"

        info 'start download'
        download! log_path, local_path
        info "download complete, your log file is in #{local_path}"
      end
    end
  end
end
