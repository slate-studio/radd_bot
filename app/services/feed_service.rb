class FeedService
  attr_reader :telegram

  def initialize
    @telegram = TelegramService.new
  end

  # TODO: with lots of feeds > 5k this class should be optimized
  def pull_and_send!
    Feed.all.each do |f|
      url = f.url

      begin
        ff = Feedjira::Feed.fetch_and_parse(url)

      rescue Feedjira::NoParserAvailable
        ap 'No valid parser for XML.'
        ap f.url
        next

      end

      new_posts = ff.entries.select do |e|
        e.published > f.updated_at
      end

      if ! new_posts.empty?
        user_ids     = f.subscribers.map { |s| s.user_id }
        sorted_posts = new_posts.map { |p| [p.published, p.url] }
        sorted_posts.sort!

        user_ids.each do |user_id|
          sorted_posts.each do |sp|
            url = sp[1]
            @telegram.send_silent_message(user_id, url)
          end
        end
      end

      f.touch
    end
  end
end
