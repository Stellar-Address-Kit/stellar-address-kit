package listener

import (
	"context"
	"time"

	"github.com/Boxkit-Labs/stellar-address-kit/examples/go-payment-listener/internal/metrics"
	"github.com/rs/zerolog"
	"github.com/stellar/go/clients/horizonclient"
	"github.com/stellar/go/protocols/horizon/operations"
)

type PaymentListener struct {
	client        *horizonclient.Client
	targetAccount string
	cursor        string
	log           zerolog.Logger
}

func NewPaymentListener(client *horizonclient.Client, account, cursor string, log zerolog.Logger) *PaymentListener {
	return &PaymentListener{
		client:        client,
		targetAccount: account,
		cursor:        cursor,
		log:           log,
	}
}

func (l *PaymentListener) Start(ctx context.Context) error {
	l.log.Info().
		Str("account", l.targetAccount).
		Str("cursor", l.cursor).
		Msg("starting horizon payment stream")

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
			err := l.stream(ctx)
			if err != nil {
				l.log.Error().Err(err).Msg("stream error, retrying in 5s...")
				time.Sleep(5 * time.Second)
			}
		}
	}
}

func (l *PaymentListener) stream(ctx context.Context) error {
	request := horizonclient.OperationRequest{
		Cursor:         l.cursor,
		IncludeFailed:  false,
		Join:           "transactions",
	}

	return l.client.StreamOperations(ctx, request, func(op operations.Operation) {
		payment, ok := op.(operations.Payment)
		if !ok || payment.To != l.targetAccount {
			return
		}

		l.handlePayment(payment)
		l.cursor = payment.PagingToken()
	})
}

func (l *PaymentListener) handlePayment(payment operations.Payment) {
	result := ExtractRouting(payment)
	severity := MapResultToSeverity(result)

	event := l.log.With().
		Str("tx_hash", payment.TransactionHash).
		Str("amount", payment.Amount).
		Str("severity", string(severity)).
		Str("source", string(result.RoutingSource)).
		Interface("warnings", result.Warnings).
		Logger()

	// Update Prometheus metrics
	metrics.PaymentsTotal.WithLabelValues(string(severity)).Inc()
	metrics.RoutingSourceTotal.WithLabelValues(string(result.RoutingSource)).Inc()

	switch severity {
	case SeverityError:
		event.Error().
			Bool("alert", true).
			Interface("error", result.DestinationError).
			Msg("unroutable payment detected")
	case SeverityWarn:
		event.Warn().Msg("payment routed with compliance warnings")
	default:
		event.Info().
			Str("routing_id", result.RoutingID.String()).
			Msg("payment successfully routed")
	}
}
