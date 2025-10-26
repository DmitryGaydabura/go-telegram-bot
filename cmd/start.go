package cmd

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/spf13/cobra"
	tele "gopkg.in/telebot.v3"
)

// startCmd represents the start command
var startCmd = &cobra.Command{
	Use:   "start",
	Short: "Start the Telegram bot",
	Long:  `Запуск Telegram-бота, який відповідає на команди та повідомлення.`,
	Run: func(cmd *cobra.Command, args []string) {
		runBot()
	},
}

func init() {
	rootCmd.AddCommand(startCmd)
}

func runBot() {
	token := os.Getenv("TELE_TOKEN")
	if token == "" {
		log.Fatal("TELE_TOKEN is not set")
	}

	pref := tele.Settings{
		Token:  token,
		Poller: &tele.LongPoller{Timeout: 10 * time.Second},
	}

	bot, err := tele.NewBot(pref)
	if err != nil {
		log.Fatal(err)
	}

	// команда /start
	bot.Handle("/start", func(c tele.Context) error {
		return c.Send("Привіт 👋 Я твій Telegram-бот на Go!")
	})

	// команда /help
	bot.Handle("/help", func(c tele.Context) error {
		return c.Send("Доступні команди:\n/start - запуск бота\n/help - список команд")
	})

	// echo на будь-який текст
	bot.Handle(tele.OnText, func(c tele.Context) error {
		return c.Send(fmt.Sprintf("Ви написали: %s", c.Text()))
	})

	log.Println("✅ Bot is running...")
	bot.Start()
}
