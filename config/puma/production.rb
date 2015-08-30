require 'environment'

environment 'production'
daemonize true

pidfile "/var/www/discuss_it/shared/pids/puma.pid"

workers 2
preload_app!

# Redirect STDOUT and STDERR to files specified. The 3rd parameter
# ("append") specifies whether the output is appended, the default is
# "false".
stdout_redirect '/var/www/discuss_it/shared/log/discuss_it.log',
                '/var/www/discuss_it/shared/log/discuss_it.log',
                true
