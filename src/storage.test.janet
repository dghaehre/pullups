(use joy)
(use judge)
(use ./utils)
(use ./test/setup)
(import ./storage :as st)


(deftest: with-db "get contests by user" [_]
  (st/create-contest "test-contest")
  (st/create-user "myname" 1)
  (test (st/get-contests-by-user 1) @[@{:id 1 :name "test contest"}]))

(deftest: with-db "get-today-amount" [_]
  (test (st/get-today-amount 0) 0)
  (test (st/get-today-amount 23) 0)
  (st/create-contest "test-contest")
  (st/create-user "myname" 1)
  (test (st/get-today-amount 1) 0)
  (test (-> (st/insert-recording 12 1)
            (get :id))
    1)
  (test (st/get-today-amount 1) 12)
  (test (st/get-today-amount 2) 0))


# Seems a bit wierd, but if you create a contest: "test-contest" the
# name will actually be "test contest". Its just easier...
(deftest: with-db "cname" [_]
  (st/create-contest "a b")
  (test (from-cname "a b") "a b")
  (test (-> (st/get-contest "a-b") (get :id)) 1)
  (test (-> (st/create-contest "test-contest") (get :name)) "test contest")
  (test (-> (st/get-contest "test-contest") (get :name)) "test contest")
  (test (-> (st/get-contest "test contest") (get :name)) "test contest"))
