package server

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"

	"aura_chain/internal/blockchain"
	"aura_chain/internal/transaction"
)

type Server struct {
	chain  *blockchain.Chain
	router *mux.Router
}

type AddBlockRequest struct {
	EventID   string  `json:"eventId"`
	UserID    string  `json:"userId"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type AddBlockResponse struct {
	Success    bool   `json:"success"`
	BlockHash  string `json:"blockHash"`
	BlockIndex int64  `json:"blockIndex"`
	Message    string `json:"message,omitempty"`
}

type BlockResponse struct {
	Index        int64  `json:"index"`
	Timestamp    int64  `json:"timestamp"`
	Data         string `json:"data"`
	Hash         string `json:"hash"`
	PreviousHash string `json:"previousHash"`
}

type ValidateResponse struct {
	Valid  bool  `json:"valid"`
	Length int64 `json:"length"`
}

func New(chain *blockchain.Chain) *Server {
	s := &Server{
		chain:  chain,
		router: mux.NewRouter(),
	}
	s.routes()
	return s
}

func (s *Server) routes() {
	s.router.HandleFunc("/health", s.healthHandler).Methods("GET")
	s.router.HandleFunc("/block", s.addBlockHandler).Methods("POST")
	s.router.HandleFunc("/block/{index}", s.getBlockHandler).Methods("GET")
	s.router.HandleFunc("/validate", s.validateHandler).Methods("GET")
	s.router.HandleFunc("/latest", s.latestBlockHandler).Methods("GET")
}

func (s *Server) healthHandler(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

func (s *Server) addBlockHandler(w http.ResponseWriter, r *http.Request) {
	var req AddBlockRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	tx := transaction.NewSOSTransaction(req.EventID, req.UserID, req.Latitude, req.Longitude)
	block, err := s.chain.AddBlock(tx.ToJSON())
	if err != nil {
		log.Printf("[BLOCKCHAIN] Failed to add block: %v", err)
		json.NewEncoder(w).Encode(AddBlockResponse{Success: false, Message: err.Error()})
		return
	}

	log.Printf("[BLOCKCHAIN] Block added: index=%d hash=%s", block.Index, block.Hash)
	json.NewEncoder(w).Encode(AddBlockResponse{
		Success:    true,
		BlockHash:  block.Hash,
		BlockIndex: block.Index,
	})
}

func (s *Server) getBlockHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	index, err := strconv.ParseInt(vars["index"], 10, 64)
	if err != nil {
		http.Error(w, "Invalid index", http.StatusBadRequest)
		return
	}

	block, err := s.chain.GetBlock(index)
	if err != nil {
		http.Error(w, "Block not found", http.StatusNotFound)
		return
	}

	json.NewEncoder(w).Encode(BlockResponse{
		Index:        block.Index,
		Timestamp:    block.Timestamp,
		Data:         block.Data,
		Hash:         block.Hash,
		PreviousHash: block.PreviousHash,
	})
}

func (s *Server) validateHandler(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(ValidateResponse{
		Valid:  s.chain.IsValid(),
		Length: s.chain.Length(),
	})
}

func (s *Server) latestBlockHandler(w http.ResponseWriter, r *http.Request) {
	block := s.chain.GetLatestBlock()
	json.NewEncoder(w).Encode(BlockResponse{
		Index:        block.Index,
		Timestamp:    block.Timestamp,
		Data:         block.Data,
		Hash:         block.Hash,
		PreviousHash: block.PreviousHash,
	})
}

func (s *Server) Start(port string) error {
	log.Printf("[SERVER] Starting on port %s", port)
	return http.ListenAndServe(":"+port, s.router)
}
