# Radd Telegram Bot

## Development

Run following services locally:

> foreman start
> ngrok 5000
> redis-server

Save ngrok `https` endpoint to `.env` file:

    WEBHOOK_URL = https://66a49b24.ngrok.com

Generate Telegram bot and add token to `.env` file using `TELEGRAM_BOT_API_TOKEN` variable.

To change/set Webhook address user rake command:

> rake bot:set_webhook
