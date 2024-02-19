(use joy)
(use judge)
(use ../test/setup)
(import ../storage :as st)

(defn valid-contest-name?
  "Is given name valid?"
  [name]
  (let [not-valid-names @["admin" "blog" "about" "terms" "login"]]
    (and
      (< 2 (length name))
      (empty? (filter |(= name $0) not-valid-names)))))

(defn available-contest-name? [name]
  (and (valid-contest-name? name) (not (st/contest-exist? name))))

(test (valid-contest-name? "admin") false)
(test (valid-contest-name? "champion") true)

(deftest: with-db "valid contest name?" [_]
  (test (available-contest-name? "some other stuff") true)
  (test (available-contest-name? "something") true)
  (test (available-contest-name? "admin") false)
  (st/create-contest "something")
  (test (available-contest-name? "something") false))
