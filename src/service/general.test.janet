(use joy)
(use judge)
(use ../test/setup)
(use ./general)
(import ../storage :as st)

(test (valid-contest-name? "admin") false)
(test (valid-contest-name? "champion") true)

(deftest: with-db "valid contest name?" [_]
  (test (available-contest-name? "some other stuff") true)
  (test (available-contest-name? "something") true)
  (test (available-contest-name? "admin") false)
  (test (available-contest-name? "logout") false)
  (st/create-contest "something")
  (test (available-contest-name? "something") false))
