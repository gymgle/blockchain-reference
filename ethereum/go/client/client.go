package main

import (
	"fmt"
	"log"

	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	// connect to the infura gateway if not have an existing client
	client, err := ethclient.Dial("https://cloudflare-eth.com")

	// or connect to the IPC endpoint file if a local instance of geth running
	// client, err := ethclient.Dial("/home/user/.ethereum/geth.ipc")

	// or connect to RPC host on default 8545
	// client, err := ethclient.Dial("http://localhost:8545")

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("we have a connection")
	_ = client // we'll use this in the upcoming sections
}
