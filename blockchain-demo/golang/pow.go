package main

import (
	"bytes"
	"crypto/sha256"
	"math"
	"math/big"
	"strconv"
)

const targetBits = 20

type pow struct {
	block  *Block
	target *big.Int
}

func NewPOW(b *Block) *pow {
	target := big.NewInt(1)
	target.Lsh(target, uint(256-targetBits))

	return &pow{
		block:  b,
		target: target,
	}
}

func (p *pow) Run() (int64, []byte) {
	var (
		hash    []byte
		hashInt big.Int
		nonce   int64
	)

	for nonce < math.MaxInt64 {
		hash = p.tryHash(nonce)
		hashInt.SetBytes(hash)

		if hashInt.Cmp(p.target) == -1 {
			break
		}

		nonce++
	}

	return nonce, hash
}

func (p *pow) tryHash(nonce int64) []byte {
	headers := bytes.Join([][]byte{
		[]byte(strconv.FormatInt(p.block.Height, 10)),
		[]byte(strconv.FormatInt(p.block.Timestamp, 10)),
		p.block.PrevHash,
		p.block.Data,
		[]byte(strconv.FormatInt(nonce, 10)),
	}, nil)
	hash := sha256.Sum256(headers)

	return hash[:]
}
