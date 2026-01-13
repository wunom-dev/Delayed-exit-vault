;; =====================================================
;; DelayedExitVault
;; Two-step withdrawal vault with enforced cooldown
;; =====================================================

;; -----------------------------
;; Data Variables
;; -----------------------------

(define-data-var admin principal tx-sender)
(define-data-var exit-delay uint u144) ;; ~1 day @ 10min blocks
(define-data-var paused bool false)

;; -----------------------------
;; Data Maps
;; -----------------------------

(define-map balances principal uint)

(define-map exit-requests
  principal
  {
    amount: uint,
    request-block: uint
  }
)

;; -----------------------------
;; Errors
;; -----------------------------

(define-constant ERR-PAUSED (err u100))
(define-constant ERR-NO-BALANCE (err u101))
(define-constant ERR-EXIT-PENDING (err u102))
(define-constant ERR-NOT-READY (err u103))
(define-constant ERR-NOT-AUTHORIZED (err u104))

;; -----------------------------
;; Helpers
;; -----------------------------

(define-read-only (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; -----------------------------
;; Deposit
;; -----------------------------

(define-public (deposit (amount uint))
  (begin
    ;; Fix 1: Use asserts! directly for cleaner logic
    (asserts! (not (var-get paused)) ERR-PAUSED)
    (asserts! (> amount u0) ERR-NO-BALANCE)

    ;; Fix 2: Wrap transfer in try! to ensure the Response is handled
    ;; and the function continues to the next line only on success.
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

    (map-set balances tx-sender
      (+ amount (default-to u0 (map-get? balances tx-sender)))
    )

    (ok true)
  )
)

;; -----------------------------
;; Exit Request
;; -----------------------------

(define-public (request-exit (amount uint))
  (begin
    (asserts! (not (var-get paused)) ERR-PAUSED)

    (let ((bal (default-to u0 (map-get? balances tx-sender))))
      (asserts! (>= bal amount) ERR-NO-BALANCE)
      (asserts!
        (is-none (map-get? exit-requests tx-sender))
        ERR-EXIT-PENDING
      )

      (map-set exit-requests tx-sender {
        amount: amount,
        request-block: stacks-block-height
      })

      (ok true)
    )
  )
)

;; -----------------------------
;; Finalize Exit
;; -----------------------------

(define-public (finalize-exit)
  (let (
    (req (map-get? exit-requests tx-sender))
    (user tx-sender)
  )
    (match req r
      (begin
        (asserts!
          (>= stacks-block-height (+ (get request-block r) (var-get exit-delay)))
          ERR-NOT-READY
        )

        ;; Update balance
        (map-set balances user
          (- (default-to u0 (map-get? balances user))
             (get amount r))
        )

        (map-delete exit-requests user)

        ;; Fix 3: as-contract context switch
        ;; We must wrap the transfer so the contract is the sender
        (as-contract (stx-transfer? (get amount r) tx-sender user))
      )
      ERR-NO-BALANCE
    )
  )
)

;; -----------------------------
;; Admin Controls
;; -----------------------------

(define-public (set-exit-delay (delay uint))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (var-set exit-delay delay)
    (ok true)
  )
)

(define-public (pause (flag bool))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (var-set paused flag)
    (ok true)
  )
)

;; -----------------------------
;; Read-only Views
;; -----------------------------

(define-read-only (get-balance (user principal))
  (default-to u0 (map-get? balances user))
)

(define-read-only (get-exit-request (user principal))
  (map-get? exit-requests user)
)

(define-read-only (get-exit-delay)
  (var-get exit-delay)
)