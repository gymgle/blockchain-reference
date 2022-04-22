#lang racket

(require "transaction-io.rkt")
(require "utils.rkt")
(require (only-in file/sha1 hex-string->bytes))
(require "wallet.rkt")
(require crypto)
(require crypto/all)
(require racket/serialize)

(use-all-factories!)


(struct transaction
  (signature from to value inputs outputs)
  #:prefab)

(define (make-transaction from to value inputs)
  (transaction
   ""
   from
   to
   value
   inputs
   '()))

(define (sign-transaction from to value)
  (let ([privkey (wallet-private-key from)]
        [pubkey (wallet-public-key from)])
    (bytes->hex-string
     (digest/sign
      (datum->pk-key (hex-string->bytes privkey) 'PrivateKeyInfo)
      'sha1
      (bytes-append
       (string->bytes/utf-8 (~a (serialize from)))
       (string->bytes/utf-8 (~a (serialize to)))
       (string->bytes/utf-8 (number->string value)))))))


(define (process-transaction t)
  (letrec
      ([inputs (transaction-inputs t)]
       [outputs (transaction-outputs t)]
       [value (transaction-value t)]
       [inputs-sum
        (foldr + 0 (map (lambda (i) (transaction-io-value i)) inputs))]
       [leftover (- inputs-sum value)]
       [new-outputs
        (list
         (make-transaction-io value (transaction-to t))
         (make-transaction-io leftover (transaction-from t)))])
    (transaction
     (sign-transaction (transaction-from t)
                       (transaction-to t)
                       (transaction-value t))
     (transaction-from t)
     (transaction-to t)
     value
     inputs
     (append new-outputs outputs))))

(define (valid-transaction-signature? t)
  (let ([pubkey (wallet-public-key (transaction-from t))])
    (digest/verify
     (datum->pk-key (hex-string->bytes pubkey) 'SubjectPublicKeyInfo)
     'sha1
     (bytes-append
      (string->bytes/utf-8 (~a (serialize (transaction-from t))))
      (string->bytes/utf-8 (~a (serialize (transaction-to t))))
      (string->bytes/utf-8 (number->string (transaction-value t))))
     (hex-string->bytes (transaction-signature t)))))

(define (valid-transaction? t)
  (let ([sum-inputs (foldr + 0 (map (lambda (t) (transaction-io-value t)) (transaction-inputs t)))]
        [sum-outputs (foldr + 0 (map (lambda (t) (transaction-io-value t)) (transaction-outputs t)))])
    (and
     (valid-transaction-signature? t)
     (true-for-all? valid-transaction-io? (transaction-outputs t))
     (>= sum-inputs sum-outputs))))

(provide (all-from-out "transaction-io.rkt")
         (struct-out transaction)
         make-transaction
         process-transaction
         valid-transaction?)
