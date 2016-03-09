class TelegramController < ActionController::Base
  def receive
    message = params[:telegram]
    InteractionService.process(message)

    render nothing: true
  end
end
