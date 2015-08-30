namespace :discuss_it do
  desc 'start discuss_it server'
  task :start do
    on roles(:app) do
      within "#{current_path}" do
        with rack_env: fetch(:rack_env) do
          execute :bundle, :exec, "rackup -p 3333"
        end
      end
    end
  end

  desc 'stop discuss_it server'
  task :stop do
    on roles(:app) do
      within "#{current_path}" do
        with rack_env: fetch(:rack_env) do
          execute "ps -ef | grep rackup | grep -v grep | awk '{print $2}' | xargs kill -9"
        end
      end
    end
  end

  desc 'restart discuss_it server'
  task :restart do
    on roles(:app) do
      within "#{current_path}" do
        with rack_env: fetch(:rack_env) do
          execute "ps -ef | grep rackup | grep -v grep | awk '{print $2}' | xargs kill -9"
          execute :bundle, :exec, "rackup -p 3333"
        end
      end
    end
  end
end
