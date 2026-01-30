package storage

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"

	"aura_chain/internal/block"
)

type Storage interface {
	SaveBlock(b *block.Block) error
	LoadBlock(index int64) (*block.Block, error)
	LoadAllBlocks() ([]*block.Block, error)
	Close() error
}

type FileStorage struct {
	basePath string
}

func NewFileStorage(path string) (*FileStorage, error) {
	if err := os.MkdirAll(path, 0755); err != nil {
		return nil, err
	}
	return &FileStorage{basePath: path}, nil
}

func (s *FileStorage) SaveBlock(b *block.Block) error {
	filename := filepath.Join(s.basePath, fmt.Sprintf("block_%d.json", b.Index))
	data, err := json.MarshalIndent(b, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(filename, data, 0644)
}

func (s *FileStorage) LoadBlock(index int64) (*block.Block, error) {
	filename := filepath.Join(s.basePath, fmt.Sprintf("block_%d.json", index))
	data, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}
	return block.FromJSON(data)
}

func (s *FileStorage) LoadAllBlocks() ([]*block.Block, error) {
	files, err := os.ReadDir(s.basePath)
	if err != nil {
		return nil, err
	}

	var indices []int64
	for _, f := range files {
		if strings.HasPrefix(f.Name(), "block_") && strings.HasSuffix(f.Name(), ".json") {
			numStr := strings.TrimPrefix(strings.TrimSuffix(f.Name(), ".json"), "block_")
			if num, err := strconv.ParseInt(numStr, 10, 64); err == nil {
				indices = append(indices, num)
			}
		}
	}

	sort.Slice(indices, func(i, j int) bool { return indices[i] < indices[j] })

	blocks := make([]*block.Block, 0, len(indices))
	for _, idx := range indices {
		b, err := s.LoadBlock(idx)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, b)
	}

	return blocks, nil
}

func (s *FileStorage) Close() error {
	return nil
}
