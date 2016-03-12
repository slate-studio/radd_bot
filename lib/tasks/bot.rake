namespace :bot do
  desc "Set webhook"
  task :set_webhook => :environment do
    webhook_url = "#{ENV['WEBHOOK_URL']}/telegram"
    t = TelegramService.new
    ap webhook_url
    t.set_webhook(webhook_url)
  end

  task :unset_webhook => :environment do
    t = TelegramService.new
    t.set_webhook('')
  end

  task :get_me => :environment do
    t = TelegramService.new
    t.get_me
  end
end
