(use joy)
(use judge)
(use ./test/setup)
(import ./storage :as st)


(deftest: with-db "get contests by user" [_]
  (st/create-contest "test-contest")
  (st/create-user "myname" 1)
  (test (st/get-contests-by-user 1) @[@{:id 1 :name "test-contest"}]))

(deftest: with-db "get-today-amount" [_]
  (test (st/get-today-amount 0) 0)
  (test (st/get-today-amount 23) 0)
  (st/create-contest "test-contest")
  (st/create-user "myname" 1)
  (test (st/get-today-amount 1) 0)
  (test (-> (st/insert-recording 12 1)
            (get :id))
    1)
  (test (st/get-today-amount 1) 12))
