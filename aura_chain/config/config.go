package config

import (
	"os"
)

type Config struct {
	ServerPort    string
	StoragePath   string
	LogLevel      string
}

func Load() *Config {
	return &Config{
		ServerPort:    getEnv("AURA_CHAIN_PORT", "8090"),
		StoragePath:   getEnv("AURA_CHAIN_STORAGE", "./data/blockchain"),
		LogLevel:      getEnv("AURA_CHAIN_LOG_LEVEL", "info"),
	}
}

func getEnv(key, defaultVal string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return defaultVal
}
