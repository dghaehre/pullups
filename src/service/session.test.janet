(use joy)
(use judge)
(use ./session)
(import ./user :as user)
(use ../test/setup)
(import ../storage :as st)

(deftest: with-db "session" [_]
  (st/create-contest "test-contest")
  (st/create-user "myname" 1)
  (test (get (user/make-private 1 "dghaehre" "test") :username) "dghaehre")
  (let [res (login "dghaehre" "test")]
    (test (string? (get res :token)) true)
    (test (number? (get res :user-id)) true))
  (test (protect (login "dghaehre" "sdfftest")) [false "invalid password"])
  (test (protect (login "sdfsdf" "sdfftest"))
    [false
     "No user found with that username"]))
  
