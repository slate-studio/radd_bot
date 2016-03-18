class FeedService
  attr_reader :bot

  def initialize
    @bot = TelegramService.new
  end

  def pull_and_send_feed(feed_id)
    f   = Feed.find(feed_id)
    url = f.url

    begin
      ff = Feedjira::Feed.fetch_and_parse(url)

    rescue Feedjira::NoParserAvailable
      ap 'No valid parser for XML for:'
      ap f.url

      return

    rescue Faraday::TimeoutError
      ap 'Wops, timeout happened for:'
      ap f.url

      return

    end

    new_posts = ff.entries.select do |e|
      e.published > f.updated_at
    end

    sorted_posts = []
    if ! new_posts.empty?
      sorted_posts = new_posts.map { |p| [p.published, p.url] }
      sorted_posts.sort!
    end

    f.touch

    if ! sorted_posts.empty?
      user_ids = f.subscribers.map { |s| s.user_id }
      user_ids.each do |user_id|
        sorted_posts.each do |sp|
          url = sp[1]
          ap "Send notification for #{user_id}: #{url}"
          send_notification(user_id, url)
        end
      end
    end
  end

  def send_notification(user_id, text, counter=0)
    @bot.send_silent_message(user_id, text)

  rescue TelegramService::Exceptions::ResponseError
    ap "Destroy user: #{user_id}"
    Subscriber.destroy_if_exists(user_id)

  rescue Net::ReadTimeout
    if counter < 3
      send_notification(user_id, text, counter + 1)
    end

  end

  def create_pull_jobs!
    Feed.all.each do |f|
      # TODO: add subscribers check
      ap f.url
      Resque.enqueue(FeedJob, f.id.to_s)
    end
    true
  end
end
