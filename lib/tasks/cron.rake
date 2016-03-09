namespace :cron do
  desc "Pull feeds"
  task :pull_feeds => :environment do
    fs = FeedService.new
    fs.pull_and_send!
  end
end
