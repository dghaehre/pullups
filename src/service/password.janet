(use joy)
(import cipher)

(defn secure-password [password]
  (assert (string? password))
  (assert (not (nil? (dyn :encryption-key))))
  (cipher/hash-password (dyn :encryption-key) password))

(defn verify-password [password hashed]
  (cipher/verify-password (dyn :encryption-key) hashed password))

(comment
  (do
    (def key (cipher/password-key))
    (setdyn :encryption-key key)
    (verify-password "paword" (secure-password "password"))))
