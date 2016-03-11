namespace :cron do
  desc "Pull feeds"
  task :pull_feeds => :environment do
    ap 'Pulling feeds...'
    fs = FeedService.new
    fs.create_pull_jobs!
  end
end
