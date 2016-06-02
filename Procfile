web: bundle exec puma -C config/puma.rb
resque: env TERM_CHILD=1 INTERVAL=0.1 VVERBOSE=0 VERBOSE=0 QUEUE='*' bundle exec rake resque:work
