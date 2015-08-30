namespace :discuss_it do
  desc 'start discuss_it server'
  task :start do
    on roles(:app) do
      within "#{current_path}" do
        with rack_env: fetch(:rack_env) do
          execute "./bin/server"
        end
      end
    end
  end

  desc 'stop discuss_it server'
  task :stop do
    on roles(:app) do
      within "#{current_path}" do
        with rack_env: fetch(:rack_env) do
          execute :bundle, :exec, "pumactl -P /var/www/discuss_it/shared/pids/puma.pid stop"
        end
      end
    end
  end

  desc 'restart discuss_it server'
  task :restart do
    on roles(:app) do
      within "#{current_path}" do
        with rack_env: fetch(:rack_env) do
          execute :bundle, :exec, "pumactl -P /var/www/discuss_it/shared/pids/puma.pid stop"
          execute "./bin/server"
        end
      end
    end
  end
end
