package blockchain

import (
	"errors"
	"sync"

	"aura_chain/internal/block"
	"aura_chain/internal/storage"
)

type Chain struct {
	blocks  []*block.Block
	storage storage.Storage
	mutex   sync.RWMutex
}

func New(store storage.Storage) (*Chain, error) {
	chain := &Chain{
		blocks:  make([]*block.Block, 0),
		storage: store,
	}

	if err := chain.load(); err != nil {
		genesis := block.GenesisBlock()
		chain.blocks = append(chain.blocks, genesis)
		if err := store.SaveBlock(genesis); err != nil {
			return nil, err
		}
	}

	return chain, nil
}

func (c *Chain) load() error {
	blocks, err := c.storage.LoadAllBlocks()
	if err != nil {
		return err
	}
	if len(blocks) == 0 {
		return errors.New("no blocks found")
	}
	c.blocks = blocks
	return nil
}

func (c *Chain) AddBlock(data string) (*block.Block, error) {
	c.mutex.Lock()
	defer c.mutex.Unlock()

	lastBlock := c.blocks[len(c.blocks)-1]
	newBlock := block.NewBlock(lastBlock.Index+1, data, lastBlock.Hash)

	if err := c.storage.SaveBlock(newBlock); err != nil {
		return nil, err
	}

	c.blocks = append(c.blocks, newBlock)
	return newBlock, nil
}

func (c *Chain) GetBlock(index int64) (*block.Block, error) {
	c.mutex.RLock()
	defer c.mutex.RUnlock()

	if index < 0 || index >= int64(len(c.blocks)) {
		return nil, errors.New("block not found")
	}
	return c.blocks[index], nil
}

func (c *Chain) GetLatestBlock() *block.Block {
	c.mutex.RLock()
	defer c.mutex.RUnlock()
	return c.blocks[len(c.blocks)-1]
}

func (c *Chain) IsValid() bool {
	c.mutex.RLock()
	defer c.mutex.RUnlock()

	for i := 1; i < len(c.blocks); i++ {
		current := c.blocks[i]
		previous := c.blocks[i-1]

		if current.Hash != current.CalculateHash() {
			return false
		}

		if current.PreviousHash != previous.Hash {
			return false
		}
	}
	return true
}

func (c *Chain) Length() int64 {
	c.mutex.RLock()
	defer c.mutex.RUnlock()
	return int64(len(c.blocks))
}
