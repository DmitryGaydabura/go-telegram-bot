# 🤖 Telegram Bot in Go

This is a simple **Telegram bot** written in **Golang** using  
[cobra](https://github.com/spf13/cobra) and [telebot](https://pkg.go.dev/gopkg.in/telebot.v3).

The bot responds to `/start`, `/help` commands and echoes back any text sent by the user.

---

## 🚀 Installation & Run

### 1. Clone the repository
```bash
git clone https://github.com/yourname/telegram-bot.git
cd telegram-bot
```

### 2. Install dependencies
```bash
go mod tidy
```

### 3. Get the bot token
Create a bot via [BotFather](https://t.me/BotFather) in Telegram and save the token as an environment variable:

```bash
export TELE_TOKEN="your_bot_token_here"
```

### 4. Run the bot
```bash
go run main.go start
```

---

## 📦 Usage

- `/start` — start the bot
- `/help` — list of available commands
- Any text message will be echoed back by the bot

---

## 🔗 Bot link

👉 [t.me/your_bot_name_bot](https://t.me/your_bot_name_bot)

---

## 🛠️ Technologies Used

- [Go](https://go.dev/) — programming language
- [Cobra](https://github.com/spf13/cobra) — CLI framework
- [Telebot](https://pkg.go.dev/gopkg.in/telebot.v3) — Telegram Bot API client for Go
