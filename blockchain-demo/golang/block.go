package main

import (
	"encoding/hex"
	"time"
)

type Block struct {
	Height    int64
	Timestamp int64
	PrevHash  []byte
	Data      []byte
	Hash      []byte
	Nonce     int64
}

func NewBlock(data string, prevBlock *Block) *Block {
	block := &Block{
		Height:    prevBlock.Height + 1,
		Timestamp: time.Now().Unix(),
		PrevHash:  prevBlock.Hash,
		Data:      []byte(data),
	}

	block.Nonce, block.Hash = NewPOW(block).Run()

	return block
}

func NewGenesisBlock() *Block {
	return NewBlock("Genesis Block", &Block{Height: -1})
}

type BlockJson struct {
	Height    int64  `json:"height"`
	Timestamp string `json:"timestamp"`
	PrevHash  string `json:"prev_hash"`
	Data      string `json:"data"`
	Hash      string `json:"hash"`
	Nonce     int64  `json:"nonce"`
}

func (b *Block) Json() *BlockJson {
	return &BlockJson{
		Height:    b.Height,
		Timestamp: time.Unix(b.Timestamp, 0).Format("2006-01-02 15:04:05"),
		PrevHash:  hex.EncodeToString(b.PrevHash),
		Data:      string(b.Data),
		Hash:      hex.EncodeToString(b.Hash),
		Nonce:     b.Nonce,
	}
}
