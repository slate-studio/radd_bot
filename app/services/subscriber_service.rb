class SubscriberService
  attr_reader :url
  attr_reader :user_id
  attr_reader :feeds
  attr_reader :telegram

  def initialize(params)
    @telegram = TelegramService.new
    @user_id  = params["user_id"]
    @url      = params["url"]
  end

  def subscribe!
    ds = DiscoveryService.new(@url)
    @feeds = ds.feeds

    if @feeds.nil?
      send_text('😁')

    elsif @feeds.empty?
      send_text('No feeds available... 😐')

    elsif @feeds.size == 1
      subscribe_to_feed

    else
      suggest_feed_options

    end
  end

  private

  def send_text(text)
    @telegram.send_message_and_hide_custom_keyboard(@user_id, text)
  end

  def subscribe_to_feed
    url  = @feeds.first
    feed = Feed.find_or_create_by(url: url)
    feed.subscribers.push(subscriber)
    send_text('👍')
  end

  def suggest_feed_options
    text    = "There are some options..."
    options = @feeds.collect {|f| [f] }
    @telegram.send_messsage_with_onetime_keyboard_options(@user_id, text, options)
  end

  def subscriber
    @subscriber ||= Subscriber.where(user_id: @user_id).first
  end
end
