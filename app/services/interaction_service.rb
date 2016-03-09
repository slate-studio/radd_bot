class InteractionService
  ONBOARDING_TEXT = "I'm Radd, a bot that helps to track websites. Send me your favorite ones and I'll notify you when new stuff is posted."

  attr_reader :user
  attr_reader :text
  attr_reader :telegram

  def initialize(user, text)
    @user     = user
    @text     = text
    @telegram = TelegramService.new
  end

  def interact!
    if @text.start_with? '/start'
      onboarding
    else
      subscribe
    end
  end

  private

  def subscribe
    url = @text.split(' ').first.strip.downcase
    params = {
      user_id: @user.user_id,
      url:     url
    }
    send_typing
    Resque.enqueue(SubscriberJob, params)
  end

  def onboarding
    greeting = ['Hola', user.first_name].compact.join(', ')
    reply    = "✌#{greeting}!\n\n#{ONBOARDING_TEXT}"
    send_text(reply)
  end

  def send_text(text)
    @telegram.send_message(@user.user_id, text)
  end

  def send_typing
    @telegram.send_chat_action(@user.user_id, 'typing')
  end

  ## Class Methods

  def self.process(obj)
    ap obj

    message    = obj[:message]
    from       = message[:from]
    subscriber = get_subscriber(from)
    text       = message[:text]

    ss = self.new(subscriber, text)
    ss.interact!
  end

  def self.get_subscriber(from_params)
    user_id    = from_params[:id]
    subscriber = Subscriber.where(user_id: user_id).first

    if not subscriber
      subscriber = Subscriber.create({
        user_id:    user_id,
        first_name: from_params[:first_name],
        last_name:  from_params[:last_name],
        username:   from_params[:username]
      })
    end

    subscriber
  end
end
