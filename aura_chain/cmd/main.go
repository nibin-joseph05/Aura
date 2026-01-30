package main

import (
	"log"

	"aura_chain/config"
	"aura_chain/internal/blockchain"
	"aura_chain/internal/server"
	"aura_chain/internal/storage"
)

func main() {
	log.Println("[SYSTEM] Aura Chain starting...")

	cfg := config.Load()

	store, err := storage.NewFileStorage(cfg.StoragePath)
	if err != nil {
		log.Fatalf("[SYSTEM] Failed to initialize storage: %v", err)
	}
	defer store.Close()

	chain, err := blockchain.New(store)
	if err != nil {
		log.Fatalf("[SYSTEM] Failed to initialize blockchain: %v", err)
	}

	log.Printf("[SYSTEM] Blockchain initialized with %d blocks", chain.Length())
	log.Printf("[SYSTEM] Chain valid: %v", chain.IsValid())

	srv := server.New(chain)
	if err := srv.Start(cfg.ServerPort); err != nil {
		log.Fatalf("[SYSTEM] Server failed: %v", err)
	}
}
