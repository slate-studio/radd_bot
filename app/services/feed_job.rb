class FeedJob
  @queue = :feed_jobs

  def self.perform(feed_id)
    fs = FeedService.new
    fs.pull_and_send_feed(feed_id)
  end
end
