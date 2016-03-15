class TelegramService
  include HTTMultiParty

  attr_reader :token

  base_uri 'https://api.telegram.org'

  def initialize
    # https://core.telegram.org/bots#3-how-do-i-create-a-bot
    @token = ENV['TELEGRAM_BOT_API_TOKEN']
    # https://core.telegram.org/bots/self-signed
    # @certificate_path = Rails.root.join('config', 'YOURPUBLIC.pem')
  end

  # https://core.telegram.org/bots/api#setwebhook
  def set_webhook(url)
    params = { url: url, certificate: "test" } #File.new(@certificate_path) }
    call('setWebhook', params)
  end

  def get_me
    call('getMe')
  end

  def send_message(chat_id, text)
    call('sendMessage', { chat_id: chat_id, text: text })
  end

  def send_message_without_preview(chat_id, text)
    call('sendMessage', { chat_id: chat_id, text: text, disable_web_page_preview: true })
  end

  def send_silent_message(chat_id, text)
    call('sendMessage', { chat_id: chat_id, text: text, disable_notification: true })
  end

  def send_chat_action(chat_id, action)
    call('sendChatAction', { chat_id: chat_id, action: action })
  end

  def send_messsage_with_onetime_keyboard_options(chat_id, text, options)
    params = {
      chat_id: chat_id,
      text: text,
      reply_markup: {
        keyboard: options,
        resize_keyboard: true,
        one_time_keyboard: true
      }.to_json
    }
    call('sendMessage', params)
  end

  def send_message_and_hide_custom_keyboard(chat_id, text)
    params = {
      chat_id: chat_id,
      text: text,
      reply_markup: {
        hide_keyboard: true
      }.to_json
    }
    call('sendMessage', params)
  end

  # Helpers method are pulled from:
  # https://github.com/alexkravets/telegram-bot-ruby/blob/master/lib/telegram/bot/api.rb
  def call(endpoint, params = {})
    response = self.class.post("/bot#{token}/#{endpoint}", query: params)

    ap 'OUT:'
    ap response

    if response.code == 200
      response.to_hash

    elsif response.code == 403
      raise Exceptions::ForbiddenError.new(response),
        'Bot was blocked by the user.'

    else
      fail Exceptions::ResponseError.new(response),
        'Telegram API has returned the error.'

    end
  end

  private

  module Exceptions
    class Base < StandardError; end

    class ResponseError < Base
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def to_s
        super +
          format(' (%s)', data.map { |k, v| %(#{k}: "#{v}") }.join(', '))
      end

      def error_code
        data[:error_code] || data['error_code']
      end

      private

      def data
        @data ||= begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          { error_code: response.code, uri: response.request.last_uri.to_s }
        end
      end
    end

    class ForbiddenError < ResponseError; end
  end
end
