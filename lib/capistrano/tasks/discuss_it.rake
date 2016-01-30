namespace :puma do
  desc 'start puma server'
  task :start do
    on roles(:app) do
      within "#{current_path}" do
        with rack_env: fetch(:rack_env) do
          execute "./bin/server"
        end
      end
    end
  end

  desc 'stop puma server'
  task :stop do
    on roles(:app) do
      within "#{current_path}" do
        with rack_env: fetch(:rack_env) do
          execute :bundle, :exec, "pumactl -P /var/www/discuss_it/shared/pids/puma.pid stop"
        end
      end
    end
  end

  desc 'restart puma server'
  task :restart do
    on roles(:app) do
      within "#{current_path}" do
        with rack_env: fetch(:rack_env) do
          execute :bundle, :exec, "pumactl -P /var/www/discuss_it/shared/pids/puma.pid stop", raise_on_non_zero_exit: false
          execute "./bin/server"
        end
      end
    end
  end
end
