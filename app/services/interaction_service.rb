# Commads to be added to bot:
# list - List your feeds
# discover - Other users feeds

class InteractionService
  ONBOARDING_TEXT = "I'm Radd, a bot that helps to track websites. Send me your favorite ones and I'll notify you when new stuff is posted."
  NO_USER_SUBSCRIPTIONS = "You don't have any subscriptions, send me a website to add one. 😉"
  NO_SUBSCRIPTIONS = "There are no subscriptions yet, send me a website to add one. 😉"

  attr_reader :user
  attr_reader :text
  attr_reader :telegram

  def initialize(msg_object)
    @telegram = TelegramService.new

    message  = msg_object[:message]
    @user    = Subscriber.find_or_create_by_message(message)
    @user_id = @user.user_id
    @text    = message[:text]

    @telegram.send_chat_action(@user_id, 'typing')

    if @text.start_with? '/start'
      start

    elsif @text.start_with? '/list'
      list_user_subscriptions

    elsif @text.start_with? '/discover'
      list_all_subscriptions

    else
      subscribe

    end
  end

  def start
    greeting = [ 'Hola', user.first_name ].compact.join(', ')
    reply    = "✌#{greeting}!\n\n#{ONBOARDING_TEXT}"
    @telegram.send_message(@user_id, reply)
  end

  def list_user_subscriptions
    reply = NO_USER_SUBSCRIPTIONS

    if @user.subscriptions.size > 0
      urls  = @user.subscriptions.map &:url
      hosts = urls.collect { |u| URI.parse(u).host.gsub('www.', '') }
      reply = hosts.each_with_index.map { |h, i| "#{i + 1}. #{h}" }.join("\n")
    end

    @telegram.send_message_without_preview(@user_id, reply)
  end

  def list_all_subscriptions
    reply = NO_SUBSCRIPTIONS
    urls  = Feed.all.map &:url
    hosts = urls.collect { |u| URI.parse(u).host.gsub('www.', '') }
    reply = hosts.each_with_index.map { |h, i| "#{i + 1}. #{h}" }.join("\n")

    @telegram.send_message_without_preview(@user_id, reply)
  end

  def subscribe
    url = @text.split(' ').first.strip.downcase
    params = { user_id: @user_id, url: url }
    Resque.enqueue(SubscriberJob, params)
  end
end
