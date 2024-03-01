(use joy)
(use judge)
(use ./test/setup)
(import ./storage :as st)


(deftest: with-db "get contests by user" [_]
  (st/create-contest "test-contest")
  (st/create-user "myname" 1)
  (test (st/get-contests-by-user 1) @[@{:id 1 :name "test-contest"}]))
