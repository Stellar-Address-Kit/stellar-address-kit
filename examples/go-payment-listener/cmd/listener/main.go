package main

import (
	"context"
	"flag"
	"os"
	"os/signal"
	"syscall"

	"github.com/Boxkit-Labs/stellar-address-kit/examples/go-payment-listener/internal/config"
	"github.com/Boxkit-Labs/stellar-address-kit/examples/go-payment-listener/internal/listener"
	"github.com/Boxkit-Labs/stellar-address-kit/examples/go-payment-listener/internal/metrics"
	"github.com/rs/zerolog"
	"github.com/stellar/go/clients/horizonclient"
)

func main() {
	configPath := flag.String("config", "config.example.yaml", "path to config file")
	flag.Parse()

	cfg, err := config.Load(*configPath)
	if err != nil {
		panic("failed to load config: " + err.Error())
	}

	// Setup Logger
	log := zerolog.New(os.Stdout).With().Timestamp().Logger()
	if cfg.Logging.Level == "debug" {
		zerolog.SetGlobalLevel(zerolog.DebugLevel)
	}

	// Setup Metrics
	if cfg.Metrics.Enabled {
		metrics.Register()
		go func() {
			log.Info().Int("port", cfg.Metrics.Port).Msg("metrics server starting")
			if err := metrics.Serve(cfg.Metrics.Port); err != nil {
				log.Error().Err(err).Msg("metrics server failed")
			}
		}()
	}

	// Setup Horizon Client
	client := &horizonclient.Client{
		HorizonURL: cfg.Horizon.URL,
	}

	// Setup Graceful Shutdown
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	l := listener.NewPaymentListener(
		client,
		cfg.Horizon.TargetAccount,
		cfg.Horizon.StartCursor,
		log,
	)

	if err := l.Start(ctx); err != nil && err != context.Canceled {
		log.Fatal().Err(err).Msg("listener failed")
	}

	log.Info().Msg("shutting down gracefully")
}
