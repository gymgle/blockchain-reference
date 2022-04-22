#lang racket

(require file/sha1)
(require racket/serialize)

(struct transaction-io
  (transaction-hash value owner timestamp)
  #:prefab)

(define (calculate-transaction-io-hash value owner timestamp)
  (bytes->hex-string (sha256-bytes (bytes-append
                                    (string->bytes/utf-8 (number->string value))
                                    (string->bytes/utf-8 (~a (serialize owner)))
                                    (string->bytes/utf-8 (number->string timestamp))))))

(define (make-transaction-io value owner)
  (let ([timestamp (current-milliseconds)])
    (transaction-io
     (calculate-transaction-io-hash value owner timestamp)
     value
     owner
     timestamp)))

(define (valid-transaction-io? t-in)
  (equal? (transaction-io-transaction-hash t-in)
          (calculate-transaction-io-hash
           (transaction-io-value t-in)
           (transaction-io-owner t-in)
           (transaction-io-timestamp t-in))))

(provide (struct-out transaction-io) make-transaction-io valid-transaction-io?)
