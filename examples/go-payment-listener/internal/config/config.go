package config

import (
	"strings"

	"github.com/spf13/viper"
)

type Config struct {
	Horizon struct {
		URL           string `mapstructure:"url"`
		TargetAccount string `mapstructure:"target_account"`
		StartCursor   string `mapstructure:"start_cursor"`
	} `mapstructure:"horizon"`
	Logging struct {
		Level  string `mapstructure:"level"`
		Format string `mapstructure:"format"`
	} `mapstructure:"logging"`
	Metrics struct {
		Enabled bool `mapstructure:"enabled"`
		Port    int  `mapstructure:"port"`
	} `mapstructure:"metrics"`
}

func Load(path string) (*Config, error) {
	v := viper.New()
	v.SetConfigFile(path)
	v.AutomaticEnv()
	v.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	if err := v.ReadInConfig(); err != nil {
		return nil, err
	}

	var cfg Config
	if err := v.Unmarshal(&cfg); err != nil {
		return nil, err
	}

	return &cfg, nil
}
