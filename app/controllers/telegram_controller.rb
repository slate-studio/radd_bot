class TelegramController < ActionController::Base
  def receive
    msg_object = params[:telegram]

    ap 'IN:'
    ap msg_object

    InteractionService.new(msg_object)
    render nothing: true
  end
end
