(use joy)
(use judge)
(use ./setup)
(import ../storage :as st)


(deftest: with-db "session storage" [_]
  (st/create-contest "test-contest")
  (st/create-user "myname" 1)
  (st/insert-session 1 "toke"))
