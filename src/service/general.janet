(use joy)
(use judge)
(use ../test/setup)
(import ../storage :as st)

(defn valid-contest-name?
  "Is given name valid?"
  [name]
  (let [not-valid-names @["user"
                          "private"
                          "admin"
                          "blog"
                          "about"
                          "terms"
                          "logout"
                          "login"]]
    (and
      (< 2 (length name))
      (empty? (filter |(= name $0) not-valid-names)))))

(defn available-contest-name? [name]
  (and (valid-contest-name? name) (not (st/contest-exist? name))))
