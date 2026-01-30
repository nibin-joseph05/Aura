package block

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"time"
)

type Block struct {
	Index        int64  `json:"index"`
	Timestamp    int64  `json:"timestamp"`
	Data         string `json:"data"`
	PreviousHash string `json:"previousHash"`
	Hash         string `json:"hash"`
	Nonce        int64  `json:"nonce"`
}

func NewBlock(index int64, data string, previousHash string) *Block {
	block := &Block{
		Index:        index,
		Timestamp:    time.Now().Unix(),
		Data:         data,
		PreviousHash: previousHash,
		Nonce:        0,
	}
	block.Hash = block.CalculateHash()
	return block
}

func (b *Block) CalculateHash() string {
	record := struct {
		Index        int64
		Timestamp    int64
		Data         string
		PreviousHash string
		Nonce        int64
	}{
		Index:        b.Index,
		Timestamp:    b.Timestamp,
		Data:         b.Data,
		PreviousHash: b.PreviousHash,
		Nonce:        b.Nonce,
	}

	bytes, _ := json.Marshal(record)
	hash := sha256.Sum256(bytes)
	return hex.EncodeToString(hash[:])
}

func GenesisBlock() *Block {
	return NewBlock(0, "Genesis Block - Aura SOS Chain", "0")
}

func (b *Block) ToJSON() ([]byte, error) {
	return json.Marshal(b)
}

func FromJSON(data []byte) (*Block, error) {
	var block Block
	err := json.Unmarshal(data, &block)
	return &block, err
}
