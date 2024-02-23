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
  (def login-res (login "dghaehre" "test"))
  (test (string? (get login-res :token)) true)
  (test (number? (get login-res :user-id)) true)
  (test (protect (login "dghaehre" "sdfftest")) [false "invalid password"])
  (test (protect (login "sdfsdf" "sdfftest"))
    [false
     "No user found with that username"])
  
  # Tesing auth macro
  (defn-auth testing [req user-id]
    [:h1 user-id])
  # access denied
  (test (-> (testing {:session {:token 1
                                :user-id 1}})
            (get :status))
    302)
  # access granted
  (test (testing {:session {:token (get login-res :token)
                            :user-id 1}})
    [:h1 1]))
  
