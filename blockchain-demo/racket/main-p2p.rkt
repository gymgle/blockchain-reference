#lang racket

(require "main-helper.rkt")


(define args (vector->list (current-command-line-arguments)))

(when (not (= 3 (length args)))
  (begin
    (printf "Usage; main-p2p.rkt db.data port ip1:port1, ip2:port2....")
    (newline)
    (exit)))

(define (string-to-peer-info s)
  (let ([s (string-split s ":")])
    (peer-info (car s) (string->number (cadr s)))))

(define db-filename (car args))

(define port (string->number (cadr args)))

(define valid-peers
  (map string-to-peer-info (string-split (caddr args) ",")))

(define wallet-a (make-wallet))

(define (initialize-new-blockchain)
  (begin
    (define coin-base (make-wallet))
    (printf "Making genesis transaction...\n")
    (define genesis-t (make-transaction coin-base wallet-a 100 '()))
    (define utxo (list (make-transaction-io 100 wallet-a)))
    (printf "Mining genesis block...\n")
    (define b (init-blockchain genesis-t "1337cafe" utxo)) b))

(define db-blockchain
  (if (file-exists? db-filename)
      (file->struct db-filename)
      (initialize-new-blockchain)))

(define peer-context
  (peer-context-data "Test peer"
                     port
                     (list->set valid-peers)
                     '()
                     db-blockchain))

(define (get-blockchain)
  (peer-context-data-blockchain peer-context))

(run-peer peer-context)

(define (export-loop)
  (begin
    (sleep 10)
    (struct->file (get-blockchain) db-filename)
    (printf "Exported blockchain to '~a'...\n" db-filename)
    (export-loop)))

(thread export-loop)

(define (mine-loop)
  (let ([newer-blockchain
         (send-money-blockchain (get-blockchain)
                                wallet-a
                                wallet-a
                                1
                                (file->contract "contract.script"))])
    (set-peer-context-data-blockchain! peer-context newer-blockchain)
    (printf "Mined a block!")
    (sleep 5)
    (mine-loop)))

(mine-loop)                                
