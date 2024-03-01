(use joy)
(use judge)
(use ./user)
(use ../test/setup)
(use ../utils)
(import ./session :as session)
(import ../storage :as st)


(test (protect (make-private 1 "" "test")) [false "Username cannot be empty"])
(test (protect (make-private 1 "admin" "test")) [false "Username cannot be admin"])
(test (protect (make-private 1 "test" "test"))
  [false
   "Username must be at least 5 characters long"])
(test (protect (validate-username "testt")) [true nil])

(deftest: with-db "make username private" [_]
  (test (protect (make-private 1 "dghaehre" "test")) [false "No user found with id: 1"])
  (st/create-contest "test-contest")
  (st/create-user "myname" 1)
  (test (get (make-private 1 "dghaehre" "test") :username) "dghaehre")
  (st/create-user "othername" 1)
  (test (protect (make-private 2 "dghaehre" "test"))
    [false "Username already taken"]))

(deftest: with-db "record" [_]
  # Record for public user
  (st/create-contest "test-contest")
  (st/create-user "myname" 1)
  (test (get (record 1 (time-by-change nil) "test-contest" 100) :amount) 100)
  (test (st/get-today-amount 1) 100)

  # Make user private
  (make-private 1 "username" "password")
  (test (protect (record 1 (time-by-change nil) "test-contest" 200)) [false "not allowed: user is private"])

  # with wrong auth
  (def wrong-auth {:session {:token 1 :user-id 1}})
  (test (protect (record 1 (time-by-change nil) "test-contest" 200 wrong-auth)) [false "not allowed: user is private"])

  (def login-res (session/login "username" "password"))
  (def auth {:session login-res})
  (test (-> (record 1 (time-by-change nil) "test-contest" 200 auth)
            (get :amount))
    200))

