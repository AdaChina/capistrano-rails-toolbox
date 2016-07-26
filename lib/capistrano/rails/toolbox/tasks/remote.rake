namespace :toolbox do
  namespace :remote do
    desc <<-DESC
      open a rails console for remote
    DESC
    task :console do
      on roles(:app) do |server|
        puts "Opening a console on: #{host}...."
        command = "cd #{fetch(:deploy_to)}/current && RAILS_ENV=#{fetch(:stage)} #{SSHKit.config.command_map[:bundle]} exec rails console"
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
        configure_backend

        log_path = "#{shared_path}/log/#{fetch(:rails_env)}.log"
        command = "tail -F #{log_path}"
        puts command
        execute command
      end
    end
  end
end
