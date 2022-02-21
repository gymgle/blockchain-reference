package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func (b *BlockChain) HandlerGetBlockChain(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	res := make([]*BlockJson, len(b.Blocks))

	for i := 0; i < len(b.Blocks); i++ {
		res[i] = b.Blocks[i].Json()
	}

	data, err := json.Marshal(res)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
	} else {
		fmt.Fprintf(w, "%s\n", data)
	}
}

func (b *BlockChain) HandlerMineBlock(w http.ResponseWriter, r *http.Request) {
	data := r.URL.Query().Get("data")
	hash := b.AddBlock(data)

	fmt.Fprintf(w, "%x\n", hash)
}

func (b *BlockChain) Serve() {
	port := ":8080"

	fmt.Println("start http server at", port)
	fmt.Println()
	fmt.Println("/blockchain     [ GET ] HandlerGetBlockChain \"get all block json data\"")
	fmt.Println("/mineblockchain [ GET ] HandlerMineBlock     \"mine a block with data\"")

	http.HandleFunc("/blockchain", b.HandlerGetBlockChain)
	http.HandleFunc("/mineblockchain", b.HandlerMineBlock)
	http.ListenAndServe(port, nil)
}
