num_workers = Integer(ENV["PUMA_WORKERS"] || 1)
num_threads = Integer(ENV["PUMA_THREADS"] || 3)

workers num_workers
threads num_threads, num_threads

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
end
