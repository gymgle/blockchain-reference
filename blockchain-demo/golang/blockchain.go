package main

type BlockChain struct {
	Blocks []*Block
}

func NewBlockChain() *BlockChain {
	return &BlockChain{Blocks: []*Block{NewGenesisBlock()}}
}

func (b *BlockChain) AddBlock(data string) []byte {
	prevBlock := b.Blocks[len(b.Blocks)-1]
	newBlock := NewBlock(data, prevBlock)

	b.Blocks = append(b.Blocks, newBlock)

	return newBlock.Hash
}
